import IRIKit
import RDFCore
import SwiftSyntax
import SwiftSyntaxBuilder

/// What a vocabulary's documents state, as the Swift that encodes it back:
/// `ontology`, a value whose `encode(to:)` writes every statement of the
/// documents, about its terms and about anything else they describe, the
/// ontology itself included.
///
///     public let ontology = OntologyDescription()
///
///     let document = try NTriplesEncoder().encode(FOAF.ontology)
///
/// Each subject is a node, keyed by its IRI (`@id`) and the IRIs of its
/// predicates; a blank node is written where it is the object, as a node
/// with no `@id`. The IRI of a term a translated vocabulary declares is
/// derived from that declaration when the encoder asks for it (rule 17);
/// only an IRI no translated vocabulary declares is written as it is.
struct Description {
    let vocabulary: Vocabulary

    func declarations() throws -> [DeclSyntax] {
        let graph = vocabulary.graph
        var subjects: [SubjectTerm] = []
        var references: [BlankNode: Int] = [:]
        for triple in graph {
            if !subjects.contains(triple.subject) { subjects.append(triple.subject) }
            if case .blankNode(let node) = triple.object { references[node, default: 0] += 1 }
        }
        if let shared = references.first(where: { $0.value > 1 }) {
            throw TranslationError(description: "\(shared.key) is the object of \(shared.value) statements; a blank node is written where it is the object")
        }
        let keys = Keys(graph)
        let topLevel = subjects.filter { subject in
            if case .blankNode(let node) = subject { return references[node] == nil }
            return true
        }
        return [
            DeclSyntax(try structure(topLevel, keys: keys)),
            DeclSyntax(VariableDeclSyntax(
                leadingTrivia: Individuals.documentation(["\(vocabulary.module) as its documents state it, every statement of them."]),
                modifiers: [DeclModifierSyntax(name: .keyword(.public))],
                bindingSpecifier: .keyword(.let),
                bindings: [PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(identifier: .identifier("ontology")),
                    initializer: InitializerClauseSyntax(value: Individuals.call(Individuals.reference("OntologyDescription"), []))
                )]
            )),
        ]
    }

    /// The coding key of each predicate: its local name, numbered when two
    /// predicates share one.
    struct Keys {
        var names: [IRI: String] = [:]
        var order: [IRI] = []

        init(_ graph: Graph) {
            var used: Set<String> = ["id"]
            for triple in graph where names[triple.predicate] == nil {
                let iri = triple.predicate.rawValue
                let local = String(iri[(iri.lastIndex(where: { $0 == "#" || $0 == "/" }).map(iri.index(after:)) ?? iri.startIndex)...])
                var name = local.isEmpty || local.first!.isNumber ? "p" + local : local
                name = String(name.map { $0.isLetter || $0.isNumber || $0 == "_" ? $0 : "_" })
                var candidate = name
                var number = 2
                while used.contains(candidate) {
                    candidate = "\(name)\(number)"
                    number += 1
                }
                used.insert(candidate)
                names[triple.predicate] = candidate
                order.append(triple.predicate)
            }
        }
    }

    /// `public struct OntologyDescription: Encodable { … }`.
    private func structure(_ subjects: [SubjectTerm], keys: Keys) throws -> StructDeclSyntax {
        StructDeclSyntax(
            leadingTrivia: Individuals.documentation(["The statements of the documents \(vocabulary.module) is translated from."]),
            modifiers: [DeclModifierSyntax(name: .keyword(.public))],
            name: .identifier("OntologyDescription"),
            inheritanceClause: InheritanceClauseSyntax {
                InheritedTypeSyntax(type: TypeSyntax("Encodable"))
                InheritedTypeSyntax(type: TypeSyntax("Sendable"))
            },
            memberBlock: try MemberBlockSyntax {
                Individuals.codingKeys([("id", ExprSyntax(StringLiteralExprSyntax(content: "@id")))] + keys.order.map { predicate in
                    (keys.names[predicate]!, vocabulary.iriExpression(of: predicate.rawValue))
                })
                InitializerDeclSyntax(
                    modifiers: [DeclModifierSyntax(name: .keyword(.public))],
                    signature: FunctionSignatureSyntax(parameterClause: FunctionParameterClauseSyntax(parameters: [])),
                    body: CodeBlockSyntax(statements: [])
                )
                try encode(subjects, keys: keys)
            }
        )
    }

    /// `encode(to:)`: one node per subject.
    private func encode(_ subjects: [SubjectTerm], keys: Keys) throws -> FunctionDeclSyntax {
        var statements: [CodeBlockItemSyntax] = [
            Self.variable("subjects", Individuals.call(Individuals.member(Individuals.reference("encoder"), "unkeyedContainer"), [])),
        ]
        for subject in subjects {
            statements.append(Self.scope(try node(subject, in: "subjects", keys: keys)))
        }
        return FunctionDeclSyntax(
            leadingTrivia: Individuals.documentation(["Writes every statement of the documents."]),
            modifiers: [DeclModifierSyntax(name: .keyword(.public))],
            name: .identifier("encode"),
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax {
                    FunctionParameterSyntax(firstName: .identifier("to"), secondName: .identifier("encoder"), type: TypeSyntax("any Encoder"))
                },
                effectSpecifiers: FunctionEffectSpecifiersSyntax(throwsClause: ThrowsClauseSyntax(throwsSpecifier: .keyword(.throws)))
            ),
            body: CodeBlockSyntax(statements: CodeBlockItemListSyntax(statements))
        )
    }

    /// A subject as a node in the list `container`: its `@id`, then the
    /// objects of each of its predicates.
    private func node(_ subject: SubjectTerm, in container: String, keys: Keys) throws -> [CodeBlockItemSyntax] {
        let keyed = Individuals.call(Individuals.member(Individuals.reference(container), "nestedContainer"), [
            ("keyedBy", ExprSyntax(MemberAccessExprSyntax(base: Individuals.reference("CodingKeys"), declName: DeclReferenceExprSyntax(baseName: .keyword(.self))))),
        ])
        var statements = [Self.variable("node", keyed)]
        if case .iri(let iri) = subject {
            statements.append(Self.item(Self.encode(in: "node", vocabulary.iriExpression(of: iri.rawValue), forKey: "id")))
        }
        let triples = vocabulary.graph.filter { $0.subject == subject }
        var predicates: [IRI] = []
        for triple in triples where !predicates.contains(triple.predicate) { predicates.append(triple.predicate) }
        for predicate in predicates {
            var scoped = [Self.variable("objects", Individuals.call(Individuals.member(Individuals.reference("node"), "nestedUnkeyedContainer"), [
                ("forKey", ExprSyntax(MemberAccessExprSyntax(name: .identifier(keys.names[predicate]!)))),
            ]))]
            for triple in triples where triple.predicate == predicate {
                scoped += try object(triple.object, keys: keys)
            }
            statements.append(Self.scope(scoped))
        }
        return statements
    }

    /// An object in the list `objects`: a node named by an IRI, a blank
    /// node with its own statements, or a literal.
    private func object(_ object: ObjectTerm, keys: Keys) throws -> [CodeBlockItemSyntax] {
        switch object {
        case .iri(let iri):
            return [Self.scope([
                Self.variable("node", Individuals.call(Individuals.member(Individuals.reference("objects"), "nestedContainer"), [
                    ("keyedBy", ExprSyntax(MemberAccessExprSyntax(base: Individuals.reference("CodingKeys"), declName: DeclReferenceExprSyntax(baseName: .keyword(.self))))),
                ])),
                Self.item(Self.encode(in: "node", vocabulary.iriExpression(of: iri.rawValue), forKey: "id")),
            ])]
        case .blankNode(let node):
            return [Self.scope(try self.node(.blankNode(node), in: "objects", keys: keys))]
        case .literal(let literal):
            return [Self.item(TryExprSyntax(expression: Individuals.call(Individuals.member(Individuals.reference("objects"), "encode"), [(nil, self.literal(literal))])))]
        case .tripleTerm:
            throw TranslationError(description: "\(object): triple terms are not translated yet")
        }
    }

    /// A literal: a string for a simple literal, otherwise the `Literal` the
    /// encoder writes as it is (rule 20), its datatype's IRI derived from
    /// the declaration of the datatype when a vocabulary declares it.
    private func literal(_ literal: Literal) -> ExprSyntax {
        let lexical = ExprSyntax(StringLiteralExprSyntax(content: literal.lexicalForm))
        if let language = literal.languageTag {
            var arguments: [(label: String?, value: ExprSyntax)] = [(nil, lexical), ("languageTag", ExprSyntax(StringLiteralExprSyntax(content: language)))]
            if let direction = literal.baseDirection {
                arguments.append(("baseDirection", ExprSyntax(MemberAccessExprSyntax(name: .identifier(direction.rawValue)))))
            }
            return ExprSyntax(TryExprSyntax(expression: Individuals.call(Individuals.reference("Literal"), arguments)))
        }
        if let datatype = literal.datatype {
            let derived = vocabulary.iriExpression(of: datatype.rawValue)
            let iri = derived.is(StringLiteralExprSyntax.self)
                ? derived
                : ExprSyntax(Individuals.call(Individuals.reference("IRI"), [("stringLiteral", derived)]))
            return ExprSyntax(Individuals.call(Individuals.reference("Literal"), [
                (nil, lexical),
                ("datatype", iri),
            ]))
        }
        return lexical
    }

    // MARK: - Syntax

    /// `try node.encode(value, forKey: .key)`.
    private static func encode(in container: String, _ value: ExprSyntax, forKey key: String) -> TryExprSyntax {
        TryExprSyntax(expression: Individuals.call(Individuals.member(Individuals.reference(container), "encode"), [
            (nil, value),
            ("forKey", ExprSyntax(MemberAccessExprSyntax(name: .identifier(key)))),
        ]))
    }

    /// `var name = value`.
    private static func variable(_ name: String, _ value: some ExprSyntaxProtocol) -> CodeBlockItemSyntax {
        CodeBlockItemSyntax(item: .decl(DeclSyntax(VariableDeclSyntax(
            bindingSpecifier: .keyword(.var),
            bindings: [PatternBindingSyntax(
                pattern: IdentifierPatternSyntax(identifier: .identifier(name)),
                initializer: InitializerClauseSyntax(value: value)
            )]
        ))))
    }

    private static func item(_ expression: some ExprSyntaxProtocol) -> CodeBlockItemSyntax {
        CodeBlockItemSyntax(item: .expr(ExprSyntax(expression)))
    }

    /// `do { … }`, so that each node's containers have a scope of their own.
    private static func scope(_ statements: [CodeBlockItemSyntax]) -> CodeBlockItemSyntax {
        CodeBlockItemSyntax(item: .stmt(StmtSyntax(DoStmtSyntax(body: CodeBlockSyntax(statements: CodeBlockItemListSyntax(statements))))))
    }
}
