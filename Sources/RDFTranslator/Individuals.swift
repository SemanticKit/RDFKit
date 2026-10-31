import IRIKit
import OntologyGeneration
import RDFCore
import SwiftSyntax
import SwiftSyntaxBuilder

/// The individuals a target's documents state, as instances of their
/// classes (rule 18).
///
/// The individuals of one set of asserted classes share a final class that
/// conforms to those classes' protocols, and to the protocol of each
/// property of their own vocabulary or another whose domain is the root
/// (D2, D4). Its stored properties are the requirements of those protocols.
/// The individuals are built together, so that their values can refer to
/// each other, cycles included (D3):
///
///     public final class PersonIndividual: FOAF.Person, FOAF.Name, Encodable { … }
///
///     nonisolated(unsafe) public let (alice, bob): (PersonIndividual, PersonIndividual) = { … }()
///
/// The class is `Encodable`: its keys are the IRIs of its properties, its
/// classes are its `@type`, and an individual's IRI, its `@id`, is derived
/// from the declaration it is when an encoder asks for it (rule 17).
struct Individuals {
    let vocabulary: Vocabulary
    /// The classes and properties of each vocabulary, by its Swift
    /// namespace.
    private let ontologies: [String: (vocabulary: Vocabulary, ontology: ParsedOntology)]

    init(vocabulary: Vocabulary) {
        self.vocabulary = vocabulary
        var ontologies: [String: (Vocabulary, ParsedOntology)] = [:]
        for owner in vocabulary.all where ontologies[owner.swiftNamespace] == nil {
            if let ontology = try? owner.ontology() { ontologies[owner.swiftNamespace] = (owner, ontology) }
        }
        self.ontologies = ontologies
    }

    /// Whether an individual has a literal value, a value of a Swift type
    /// XSD declares.
    var hasLiterals: Bool {
        vocabulary.terms.filter(vocabulary.isIndividual).contains { term in
            vocabulary.statements(about: term).contains { statement in
                guard case .literal = statement.object, vocabulary.swiftName(statement.predicate.rawValue) != nil else { return false }
                return !vocabulary.schema.isAnnotationProperty(statement.predicate.rawValue)
            }
        }
    }

    /// One individual, as the documents state it.
    struct Individual {
        let name: String
        let iri: String
        let classes: [String]
        let statements: [Graph.Element]
        /// The statements of annotation properties, its documentation (D8).
        let annotations: [Graph.Element]
    }

    /// A stored property of an individual's class: the property's
    /// requirement and its IRI.
    struct Member {
        let iri: String
        let entity: ParsedEntity
    }

    func declarations() throws -> [DeclSyntax] {
        let individuals = try vocabulary.terms.filter(vocabulary.isIndividual).map(individual)
        guard !individuals.isEmpty else { return [] }
        var sets: [[String]] = []
        for individual in individuals where !sets.contains(individual.classes) { sets.append(individual.classes) }
        var declarations: [DeclSyntax] = []
        for classes in sets {
            let members = individuals.filter { $0.classes == classes }
            declarations.append(DeclSyntax(try classDeclaration(classes, individuals: members)))
        }
        declarations.append(DeclSyntax(try instances(individuals)))
        return declarations
    }

    // MARK: - Reading

    /// The words Swift reserves, which an individual's name is escaped from
    /// with backticks: rdf:nil is `` `nil` ``.
    static let keywords: Set<String> = ["nil", "true", "false", "self", "Self", "class", "struct", "enum", "protocol", "let", "var", "func", "in", "is", "as", "do", "if", "for", "while", "return", "import", "init", "default", "case", "switch", "where", "throw", "try", "repeat", "break", "continue", "extension", "operator", "static", "public", "private", "internal", "super", "Any", "Type"]

    /// An individual: an instance of each of its asserted classes that a
    /// vocabulary declares, or, when none does, of the root (rdfs4).
    private func individual(_ term: String) throws -> Individual {
        let statements = vocabulary.statements(about: term)
        var classes = vocabulary.assertedTypes(of: term).compactMap(vocabulary.swiftName).sorted()
        if classes.isEmpty, let root = vocabulary.swiftName(vocabulary.schema.root) { classes = [root] }
        let local = vocabulary.localName(term)
        return Individual(
            name: Self.keywords.contains(local) ? "`\(local)`" : local,
            iri: term,
            classes: classes,
            statements: statements.filter { $0.predicate.rawValue != vocabulary.schema.type && !vocabulary.schema.isAnnotationProperty($0.predicate.rawValue) },
            annotations: statements.filter { vocabulary.schema.isAnnotationProperty($0.predicate.rawValue) }
        )
    }

    /// A Swift type's vocabulary, ontology and entity: `FOAF.Person`.
    private func declaration(of swiftName: String) throws -> (vocabulary: Vocabulary, ontology: ParsedOntology, entity: ParsedEntity)? {
        guard let dot = swiftName.firstIndex(of: ".") else { return nil }
        let namespace = String(swiftName[..<dot])
        let local = String(swiftName[swiftName.index(after: dot)...])
        guard let (owner, ontology) = ontologies[namespace] else { return nil }
        guard let entity = (ontology.classes + ontology.properties).first(where: { $0.name == local }) else { return nil }
        return (owner, ontology, entity)
    }

    /// The classes a class is a subclass of, itself included, as far as
    /// translated vocabularies declare them (rdfs9, rdfs11).
    private func superclasses(of classes: [String]) throws -> [String] {
        var found: [String] = []
        var pending = classes
        while let next = pending.popLast() {
            guard !found.contains(next) else { continue }
            found.append(next)
            if let declared = try declaration(of: next) {
                pending += declared.entity.annotations.filter { $0.name == "SubClassOf" }.map(\.value)
            }
        }
        return found
    }

    /// The protocols an individual's class conforms to and its stored
    /// properties.
    private func members(of classes: [String], individuals: [Individual]) throws -> (conformances: [String], members: [Member]) {
        var conformances = classes
        var members: [Member] = []
        func add(_ entity: ParsedEntity, of owner: Vocabulary) {
            guard !members.contains(where: { $0.entity.name == entity.name }),
                  let iri = owner.terms.first(where: { owner.localName($0) == entity.name }) else { return }
            members.append(Member(iri: iri, entity: entity))
        }
        for type in try superclasses(of: classes) {
            guard let declared = try declaration(of: type) else { continue }
            for property in declared.ontology.properties {
                if case .member(let owner) = PropertyGenerator.placement(of: property, in: declared.ontology), owner == declared.entity.name {
                    add(property, of: declared.vocabulary)
                }
            }
        }
        for predicate in individuals.flatMap({ $0.statements.map(\.predicate.rawValue) }) {
            guard let swiftName = vocabulary.swiftName(predicate), let declared = try declaration(of: swiftName) else { continue }
            switch PropertyGenerator.placement(of: declared.entity, in: declared.ontology) {
            case .ownProtocol:
                let name = declared.entity.name.prefix(1).uppercased() + declared.entity.name.dropFirst()
                if !conformances.contains("\(declared.vocabulary.swiftNamespace).\(name)") {
                    conformances.append("\(declared.vocabulary.swiftNamespace).\(name)")
                }
                add(declared.entity, of: declared.vocabulary)
            case .member, .none:
                continue
            }
        }
        return (conformances, members)
    }

    // MARK: - The class

    private func className(_ classes: [String]) -> String {
        classes.map { String($0[$0.index(after: $0.firstIndex(of: ".")!)...]) }.joined() + "Individual"
    }

    private func classDeclaration(_ classes: [String], individuals: [Individual]) throws -> ClassDeclSyntax {
        let (conformances, members) = try self.members(of: classes, individuals: individuals)
        return ClassDeclSyntax(
            leadingTrivia: Self.documentation(["An individual of \(classes.joined(separator: ", ")), as the documents state it."]),
            modifiers: [DeclModifierSyntax(name: .keyword(.public)), DeclModifierSyntax(name: .keyword(.final))],
            name: .identifier(className(classes)),
            inheritanceClause: InheritanceClauseSyntax {
                for type in conformances + ["Encodable"] {
                    InheritedTypeSyntax(type: TypeSyntax(stringLiteral: type))
                }
            },
            memberBlock: MemberBlockSyntax {
                for member in members { storedProperty(member) }
                initializer()
                codingKeys(members)
                encode(classes: classes, members: members, individuals: individuals)
            }
        )
    }

    /// `public var knows: Values<any FOAF.Person> = []`.
    private func storedProperty(_ member: Member) -> VariableDeclSyntax {
        let type = valueType(of: member)
        let empty: ExprSyntax = type.is(OptionalTypeSyntax.self) ? ExprSyntax(NilLiteralExprSyntax()) : ExprSyntax(ArrayExprSyntax(elements: []))
        return VariableDeclSyntax(
            leadingTrivia: ClassGenerator.documentation(of: member.entity),
            modifiers: [DeclModifierSyntax(name: .keyword(.public))],
            bindingSpecifier: .keyword(.var),
            bindings: [PatternBindingSyntax(
                pattern: IdentifierPatternSyntax(identifier: .identifier(member.entity.name)),
                typeAnnotation: TypeAnnotationSyntax(type: type),
                initializer: InitializerClauseSyntax(value: empty)
            )]
        )
    }

    /// `public init() {}`.
    private func initializer() -> InitializerDeclSyntax {
        InitializerDeclSyntax(
            modifiers: [DeclModifierSyntax(name: .keyword(.public))],
            signature: FunctionSignatureSyntax(parameterClause: FunctionParameterClauseSyntax(parameters: [])),
            body: CodeBlockSyntax(statements: [])
        )
    }

    /// The keys an individual encodes with: `@id`, `@type` and its
    /// properties, each named for its property. A property's key is its IRI,
    /// derived when the encoder asks for it from the namespace its
    /// vocabulary declares and its name (rule 17).
    private func codingKeys(_ members: [Member]) -> EnumDeclSyntax {
        EnumDeclSyntax(
            modifiers: [DeclModifierSyntax(name: .keyword(.private))],
            name: .identifier("CodingKeys"),
            inheritanceClause: InheritanceClauseSyntax {
                InheritedTypeSyntax(type: TypeSyntax("CodingKey"))
            },
            memberBlock: MemberBlockSyntax {
                for name in ["id", "type"] + members.map(\.entity.name) {
                    EnumCaseDeclSyntax { EnumCaseElementSyntax(name: .identifier(name)) }
                }
                keyString(members)
                initializer(from: "stringValue", type: "String")
                VariableDeclSyntax(
                    bindingSpecifier: .keyword(.var),
                    bindings: [PatternBindingSyntax(
                        pattern: IdentifierPatternSyntax(identifier: .identifier("intValue")),
                        typeAnnotation: TypeAnnotationSyntax(type: TypeSyntax("Int?")),
                        accessorBlock: AccessorBlockSyntax(accessors: .getter(CodeBlockItemListSyntax { NilLiteralExprSyntax() }))
                    )]
                )
                initializer(from: "intValue", type: "Int")
            }
        )
    }

    /// `var stringValue: String { switch self { case .knows: FOAF.namespace + "knows" … } }`.
    private func keyString(_ members: [Member]) -> VariableDeclSyntax {
        let cases: [(String, ExprSyntax)] = [
            ("id", ExprSyntax(StringLiteralExprSyntax(content: "@id"))),
            ("type", ExprSyntax(StringLiteralExprSyntax(content: "@type"))),
        ] + members.map { ($0.entity.name, vocabulary.iriExpression(of: $0.iri)) }
        return VariableDeclSyntax(
            bindingSpecifier: .keyword(.var),
            bindings: [PatternBindingSyntax(
                pattern: IdentifierPatternSyntax(identifier: .identifier("stringValue")),
                typeAnnotation: TypeAnnotationSyntax(type: TypeSyntax("String")),
                accessorBlock: AccessorBlockSyntax(accessors: .getter(CodeBlockItemListSyntax {
                    SwitchExprSyntax(subject: DeclReferenceExprSyntax(baseName: .keyword(.self))) {
                        for (name, value) in cases {
                            SwitchCaseSyntax(label: .case(SwitchCaseLabelSyntax {
                                SwitchCaseItemSyntax(pattern: ExpressionPatternSyntax(expression: MemberAccessExprSyntax(name: .identifier(name))))
                            })) {
                                value
                            }
                        }
                    }
                }))
            )]
        )
    }

    /// `init?(stringValue: String) { nil }`: an individual is only encoded.
    private func initializer(from label: String, type: String) -> InitializerDeclSyntax {
        InitializerDeclSyntax(
            optionalMark: .postfixQuestionMarkToken(),
            signature: FunctionSignatureSyntax(parameterClause: FunctionParameterClauseSyntax {
                FunctionParameterSyntax(firstName: .identifier(label), type: TypeSyntax(stringLiteral: type))
            }),
            body: CodeBlockSyntax { ReturnStmtSyntax(expression: NilLiteralExprSyntax()) }
        )
    }

    /// `encode(to:)`: the individual's IRI, its classes and its values.
    private func encode(classes: [String], members: [Member], individuals: [Individual]) -> FunctionDeclSyntax {
        FunctionDeclSyntax(
            leadingTrivia: Self.documentation(["Writes the individual: its IRI, its classes and the values of its properties."]),
            modifiers: [DeclModifierSyntax(name: .keyword(.public))],
            name: .identifier("encode"),
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax {
                    FunctionParameterSyntax(firstName: .identifier("to"), secondName: .identifier("encoder"), type: TypeSyntax("any Encoder"))
                },
                effectSpecifiers: FunctionEffectSpecifiersSyntax(throwsClause: ThrowsClauseSyntax(throwsSpecifier: .keyword(.throws)))
            ),
            body: CodeBlockSyntax {
                VariableDeclSyntax(
                    bindingSpecifier: .keyword(.var),
                    bindings: [PatternBindingSyntax(
                        pattern: IdentifierPatternSyntax(identifier: .identifier("container")),
                        initializer: InitializerClauseSyntax(value: Self.call(
                            Self.member(Self.reference("encoder"), "container"),
                            [("keyedBy", ExprSyntax(MemberAccessExprSyntax(base: Self.reference("CodingKeys"), declName: DeclReferenceExprSyntax(baseName: .keyword(.self)))))]
                        ))
                    )]
                )
                identity(individuals)
                Self.encode(ExprSyntax(ArrayExprSyntax {
                    for type in classes {
                        ArrayElementSyntax(expression: (try? iri(ofType: type)).map(vocabulary.iriExpression) ?? ExprSyntax(StringLiteralExprSyntax(content: type)))
                    }
                }), forKey: "type")
                for member in members {
                    Self.encode(
                        valueType(of: member).is(OptionalTypeSyntax.self)
                            ? ExprSyntax(Self.call(Self.reference("Values"), [(nil, ExprSyntax(Self.reference(member.entity.name)))]))
                            : ExprSyntax(Self.reference(member.entity.name)),
                        forKey: member.entity.name
                    )
                }
            }
        )
    }

    /// The type of a stored property, in the ontology that declares it.
    private func valueType(of member: Member) -> TypeSyntax {
        let owner = vocabulary.vocabulary(declaring: member.iri)
        let ontology = owner.flatMap { ontologies[$0.swiftNamespace]?.ontology } ?? ParsedOntology(name: "", namespace: "", classes: [], properties: [])
        return PropertyGenerator.valueType(of: member.entity, in: ontology)
    }

    /// The IRI of a class a translated vocabulary lists.
    private func iri(ofType swiftName: String) throws -> String {
        guard let declared = try declaration(of: swiftName),
              let iri = declared.vocabulary.terms.first(where: { declared.vocabulary.localName($0) == declared.entity.name }) else {
            throw TranslationError(description: "no translated vocabulary lists \(swiftName)")
        }
        return iri
    }

    /// `if self === alice { try container.encode("…#alice", forKey: .id) } else if …`.
    private func identity(_ individuals: [Individual]) -> IfExprSyntax {
        var chain: IfExprSyntax?
        for individual in individuals.reversed() {
            chain = IfExprSyntax(
                conditions: [ConditionElementSyntax(condition: .expression(ExprSyntax(InfixOperatorExprSyntax(
                    leftOperand: DeclReferenceExprSyntax(baseName: .keyword(.self)),
                    operator: BinaryOperatorExprSyntax(operator: .binaryOperator("===")),
                    rightOperand: Self.reference(individual.name)
                ))))],
                body: CodeBlockSyntax {
                    Self.encode(vocabulary.iriExpression(of: individual.iri), forKey: "id")
                },
                elseKeyword: chain == nil ? nil : .keyword(.else),
                elseBody: chain.map { .ifExpr($0) }
            )
        }
        return chain!
    }

    // MARK: - The instances

    /// The individuals, built together:
    /// `nonisolated(unsafe) public let (alice, bob): (PersonIndividual, PersonIndividual) = { … }()`.
    private func instances(_ individuals: [Individual]) throws -> VariableDeclSyntax {
        let types = individuals.map { className($0.classes) }
        let type: TypeSyntax = individuals.count == 1 ? TypeSyntax(stringLiteral: types[0]) : TypeSyntax(TupleTypeSyntax(elements: TupleTypeElementListSyntax {
            for type in types { TupleTypeElementSyntax(type: TypeSyntax(stringLiteral: type)) }
        }))
        let pattern: PatternSyntax = individuals.count == 1 ? PatternSyntax(IdentifierPatternSyntax(identifier: .identifier(individuals[0].name))) : PatternSyntax(TuplePatternSyntax(elements: TuplePatternElementListSyntax {
            for individual in individuals { TuplePatternElementSyntax(pattern: IdentifierPatternSyntax(identifier: .identifier(individual.name))) }
        }))
        let names = individuals.map(\.name)
        var statements: [CodeBlockItemSyntax] = []
        for (individual, type) in zip(individuals, types) {
            statements.append(CodeBlockItemSyntax(item: .decl(DeclSyntax(VariableDeclSyntax(
                bindingSpecifier: .keyword(.let),
                bindings: [PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(identifier: .identifier(individual.name)),
                    initializer: InitializerClauseSyntax(value: Self.call(Self.reference(type), []))
                )]
            )))))
        }
        for individual in individuals {
            statements += try assignments(of: individual, individuals: individuals).map { CodeBlockItemSyntax(item: .expr($0)) }
        }
        let result: ExprSyntax = individuals.count == 1 ? ExprSyntax(Self.reference(names[0])) : ExprSyntax(TupleExprSyntax(elements: LabeledExprListSyntax {
            for name in names { LabeledExprSyntax(expression: Self.reference(name)) }
        }))
        statements.append(CodeBlockItemSyntax(item: .stmt(StmtSyntax(ReturnStmtSyntax(expression: result)))))
        let closure = ClosureExprSyntax(
            signature: ClosureSignatureSyntax(
                parameterClause: .parameterClause(ClosureParameterClauseSyntax(parameters: [])),
                returnClause: ReturnClauseSyntax(type: type)
            ),
            statements: CodeBlockItemListSyntax(statements)
        )
        return VariableDeclSyntax(
            leadingTrivia: Self.documentation(individuals.flatMap { individual in
                ["\(individual.name): <\(individual.iri)>"] + individual.annotations.compactMap { statement in
                    vocabulary.text([statement.object]).map { "  \(vocabulary.localName(statement.predicate.rawValue)): \($0)" }
                }
            }),
            modifiers: [
                DeclModifierSyntax(name: .keyword(.nonisolated), detail: DeclModifierDetailSyntax(detail: .identifier("unsafe"))),
                DeclModifierSyntax(name: .keyword(.public)),
            ],
            bindingSpecifier: .keyword(.let),
            bindings: [PatternBindingSyntax(
                pattern: pattern,
                typeAnnotation: TypeAnnotationSyntax(type: type),
                initializer: InitializerClauseSyntax(value: Self.call(closure, []))
            )]
        )
    }

    /// `alice.name = ["Alice"]` and `alice.knows = [bob]`, one per property
    /// the documents give the individual.
    private func assignments(of individual: Individual, individuals: [Individual]) throws -> [ExprSyntax] {
        var predicates: [String] = []
        for statement in individual.statements where !predicates.contains(statement.predicate.rawValue) {
            predicates.append(statement.predicate.rawValue)
        }
        let members = try self.members(of: individual.classes, individuals: [individual]).members
        return try predicates.compactMap { predicate -> ExprSyntax? in
            guard let member = members.first(where: { $0.iri == predicate }) else { return nil }
            let objects = individual.statements.filter { $0.predicate.rawValue == predicate }.compactMap { value(of: $0.object, individuals: individuals) }
            guard !objects.isEmpty else { return nil }
            let value: ExprSyntax
            if valueType(of: member).is(OptionalTypeSyntax.self) {
                guard objects.count == 1 else {
                    throw TranslationError(description: "<\(individual.iri)> has \(objects.count) values of the functional <\(predicate)>")
                }
                value = objects[0]
            } else {
                value = ExprSyntax(ArrayExprSyntax { for object in objects { ArrayElementSyntax(expression: object) } })
            }
            return ExprSyntax(InfixOperatorExprSyntax(
                leftOperand: Self.member(Self.reference(individual.name), member.entity.name),
                operator: AssignmentExprSyntax(),
                rightOperand: value
            ))
        }
    }

    /// An object as Swift: another individual, or a literal as the Swift
    /// value of its datatype (rule 20).
    private func value(of object: ObjectTerm, individuals: [Individual]) -> ExprSyntax? {
        switch object {
        case .iri(let iri):
            return individuals.first(where: { $0.iri == iri.rawValue }).map { ExprSyntax(Self.reference($0.name)) }
        case .literal(let literal) where literal.datatype == nil:
            return ExprSyntax(StringLiteralExprSyntax(content: literal.lexicalForm))
        default:
            return nil
        }
    }

    // MARK: - Syntax

    static func reference(_ name: String) -> DeclReferenceExprSyntax {
        DeclReferenceExprSyntax(baseName: .identifier(name))
    }

    static func member(_ base: some ExprSyntaxProtocol, _ name: String) -> MemberAccessExprSyntax {
        MemberAccessExprSyntax(base: base, name: .identifier(name))
    }

    static func call(_ callee: some ExprSyntaxProtocol, _ arguments: [(label: String?, value: ExprSyntax)]) -> FunctionCallExprSyntax {
        FunctionCallExprSyntax(
            calledExpression: callee,
            leftParen: .leftParenToken(),
            arguments: LabeledExprListSyntax {
                for argument in arguments {
                    LabeledExprSyntax(label: argument.label, expression: argument.value)
                }
            },
            rightParen: .rightParenToken()
        )
    }

    /// `try container.encode(value, forKey: .key)`.
    static func encode(_ value: ExprSyntax, forKey key: String) -> TryExprSyntax {
        TryExprSyntax(expression: call(member(reference("container"), "encode"), [
            (nil, value),
            ("forKey", ExprSyntax(MemberAccessExprSyntax(name: .identifier(key)))),
        ]))
    }

    static func documentation(_ lines: [String]) -> Trivia {
        Trivia(pieces: lines.flatMap { [TriviaPiece.docLineComment("/// \($0)"), .newlines(1)] })
    }
}
