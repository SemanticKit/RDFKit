import IRIKit
import OntologyGeneration
import RDFCore
import SwiftSyntax
import SwiftSyntaxBuilder

/// A vocabulary's documents, read into the model the generators take.
///
/// Its terms are the subjects its documents state something about that no
/// vocabulary it builds on declares. What each term is, a class, a property
/// or an individual, is what the published semantics entail from the
/// statements of all of them (`Schema`): nothing here names a term.
struct Vocabulary {
    let graph: Graph
    /// The Swift module the vocabulary's declarations are in.
    let module: String
    /// The Swift namespace the declarations are nested in when a module
    /// holds more than one vocabulary, `RDFS` in RDFKit.
    let namespace: String?
    /// The vocabularies this one builds on: those of the targets it depends
    /// on, and the others of its own target.
    var dependencies: [Vocabulary] = []
    /// What the statements of this vocabulary and those it builds on entail.
    var schema = Schema([])
    /// The vocabulary's terms: the subjects it owns, each with a local name
    /// of its own (`Catalog`).
    var terms: [String] = []
    private(set) var termSet: Set<String> = []
    /// The Swift name of every term of this vocabulary and those it builds
    /// on.
    var names: [String: String] = [:]

    init(graph: Graph, module: String, namespace: String?) {
        self.graph = graph
        self.module = module
        self.namespace = namespace
    }

    /// The name terms are qualified with: the namespace, or the module.
    var swiftNamespace: String { namespace ?? module }

    /// The subjects of the documents, in the order they are first stated.
    var subjects: [String] {
        var seen: Set<String> = []
        return graph.compactMap { triple -> String? in
            guard case .iri(let iri) = triple.subject, seen.insert(iri.rawValue).inserted else { return nil }
            return iri.rawValue
        }
    }

    /// The namespace most of the vocabulary's subjects are in.
    var dominantNamespace: String? {
        var counts: [String: Int] = [:]
        for subject in subjects { counts[Self.namespace(of: subject), default: 0] += 1 }
        return counts.max { ($0.value, $1.key) < ($1.value, $0.key) }?.key
    }

    /// The terms of the subjects the vocabulary owns: those whose local
    /// names are Swift identifiers, and of those whose local names are the
    /// same, the one in its dominant namespace, so that each term's Swift
    /// name is its own.
    mutating func own(_ owned: [String]) {
        let candidates = owned.filter { Self.isIdentifier(localName($0)) }
        let dominant = dominantNamespace
        let byName = Dictionary(grouping: candidates, by: localName)
        terms = candidates.filter { term in
            let rivals = byName[localName(term)] ?? []
            return rivals.count == 1 || Self.namespace(of: term) == dominant || !rivals.contains { Self.namespace(of: $0) == dominant } && rivals.first == term
        }
        termSet = Set(terms)
    }

    /// Every vocabulary this one names terms of: itself and those it builds
    /// on.
    var all: [Vocabulary] { [self] + dependencies }

    // MARK: - Swift

    /// The Swift that the vocabulary's documents generate: the protocols of
    /// its classes and properties, the classes and instances of its
    /// individuals, and, for a vocabulary that is its own module, the
    /// description it encodes back to.
    func source() throws -> String {
        let ontology = try self.ontology()
        var declarations = ontology.classes.map { ClassGenerator.generate(class: $0, in: ontology) }
            + ontology.properties.compactMap { PropertyGenerator.generate(property: $0, in: ontology) }
            + namespaceDeclarations()
        if let namespace {
            declarations = [
                DeclSyntax(EnumDeclSyntax(
                    leadingTrivia: Individuals.documentation(["The terms of the \(namespace) vocabulary."]),
                    modifiers: [DeclModifierSyntax(name: .keyword(.public))],
                    name: .identifier(namespace),
                    memberBlock: MemberBlockSyntax {}
                )),
                DeclSyntax(ExtensionDeclSyntax(
                    extendedType: TypeSyntax(stringLiteral: namespace),
                    memberBlock: MemberBlockSyntax { for declaration in declarations { declaration } }
                )),
            ]
        }
        let individuals = Individuals(vocabulary: self)
        let instances = try individuals.declarations()
        let description = namespace == nil && !(ontology.classes.isEmpty && ontology.properties.isEmpty) ? try Description(vocabulary: self).declarations() : []
        // An individual's literal values are values of the Swift types of
        // their datatypes, which XSD declares (D6).
        var modules = ["IRIKit", "RDFCore", "RDFKit"] + (individuals.hasLiterals ? ["XSD"] : []) + dependencies.map(\.module)
        modules = modules.reduce(into: []) { if !$0.contains($1) && $1 != module { $0.append($1) } }
        let file = SourceFileSyntax {
            for module in modules {
                ImportDeclSyntax(path: [ImportPathComponentSyntax(name: .identifier(module))])
            }
            for declaration in declarations + instances + description { declaration }
        }
        return file.formatted().description + "\n"
    }

    /// The namespaces the vocabulary's terms are in: the one most of them
    /// are in, `namespace`, and any other, named for the last segment of its
    /// IRI.
    var namespaces: [String] {
        var found: [String] = []
        for term in terms where !found.contains(Self.namespace(of: term)) { found.append(Self.namespace(of: term)) }
        return found.sorted { ($0 == dominantNamespace ? 0 : 1, $0) < ($1 == dominantNamespace ? 0 : 1, $1) }
    }

    /// The Swift name of the declaration of a namespace of the vocabulary.
    func namespaceName(_ namespace: String) -> String {
        guard namespace != dominantNamespace else { return "namespace" }
        let segment = namespace.dropLast().split(whereSeparator: { $0 == "/" || $0 == "#" }).last.map(String.init) ?? ""
        let name = String(segment.map { $0.isLetter || $0.isNumber ? $0 : "_" })
        return (name.first?.isLetter == true ? name : "namespace" + name) + "Namespace"
    }

    /// `public var namespace: String { "…" }`, once for each namespace the
    /// document declares terms in: the declaration an IRI is derived from
    /// when a coder asks for it, with the term's name (rule 17).
    func namespaceDeclarations() -> [DeclSyntax] {
        namespaces.map { namespace in
            DeclSyntax(VariableDeclSyntax(
                leadingTrivia: Individuals.documentation(["The namespace the documents declare these terms in."]),
                modifiers: [DeclModifierSyntax(name: .keyword(.public))] + (self.namespace == nil ? [] : [DeclModifierSyntax(name: .keyword(.static))]),
                bindingSpecifier: .keyword(.var),
                bindings: [PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(identifier: .identifier(namespaceName(namespace))),
                    typeAnnotation: TypeAnnotationSyntax(type: TypeSyntax("String")),
                    accessorBlock: AccessorBlockSyntax(accessors: .getter(CodeBlockItemListSyntax {
                        StringLiteralExprSyntax(content: namespace)
                    }))
                )]
            ))
        }
    }

    /// The IRI of a term as Swift derives it when asked: its vocabulary's
    /// declaration of its namespace, and its name, `FOAF.namespace + "knows"`.
    func iriExpression(of iri: String) -> ExprSyntax {
        guard let owner = vocabulary(declaring: iri) else { return ExprSyntax(StringLiteralExprSyntax(content: iri)) }
        return ExprSyntax(InfixOperatorExprSyntax(
            leftOperand: MemberAccessExprSyntax(
                base: DeclReferenceExprSyntax(baseName: .identifier(owner.swiftNamespace)),
                name: .identifier(owner.namespaceName(Self.namespace(of: iri)))
            ),
            operator: BinaryOperatorExprSyntax(operator: .binaryOperator("+")),
            rightOperand: StringLiteralExprSyntax(content: localName(iri))
        ))
    }

    /// The vocabulary's classes and properties, and the schema, by the
    /// Swift names of its terms.
    func ontology() throws -> ParsedOntology {
        var classes: [ParsedEntity] = []
        var properties: [ParsedEntity] = []
        for term in terms {
            if schema.isClass(term) {
                classes.append(entity(term, kind: "Class"))
            } else if schema.isProperty(term) {
                properties.append(entity(term, kind: "Property"))
            }
        }
        let known = all.flatMap(\.terms) + Array(schema.universal) + Array(schema.empty)
        return ParsedOntology(
            name: swiftNamespace,
            namespace: "",
            classes: classes,
            properties: properties,
            schema: SwiftSchema(schema, terms: known, swiftName: swiftName)
        )
    }

    /// Whether a term is an individual: an instance of some class that is
    /// neither a class nor a property.
    func isIndividual(_ term: String) -> Bool {
        !schema.isClass(term) && !schema.isProperty(term) && !assertedTypes(of: term).isEmpty
    }

    func assertedTypes(of term: String) -> [String] {
        statements(about: term).filter { $0.predicate.rawValue == schema.type }.compactMap(\.object.iriValue)
    }

    func statements(about term: String) -> [Graph.Element] {
        graph.filter { if case .iri(let iri) = $0.subject { return iri.rawValue == term } else { return false } }
    }

    /// A term's class or property declaration: its types, superclasses,
    /// domain and range as the Swift types that declare them, and its
    /// annotations as documentation (D8). A statement naming a term no
    /// vocabulary declares is left out: the term is then what the RDFS
    /// entailment patterns make of it, a resource.
    func entity(_ term: String, kind: String) -> ParsedEntity {
        let statements = statements(about: term)
        func objects(_ predicate: String) -> [String] {
            statements.filter { $0.predicate.rawValue == predicate }.compactMap(\.object.iriValue).sorted()
        }
        var annotations: [ParsedAnnotation] = []
        for type in objects(schema.type) {
            if let name = swiftName(type) { annotations.append(ParsedAnnotation(name: "Type", value: name)) }
        }
        if kind == "Class" {
            for object in objects(schema.subClassOf) {
                if let name = swiftName(object) { annotations.append(ParsedAnnotation(name: "SubClassOf", value: name)) }
            }
        } else {
            // The domain and range the statements entail, a superproperty's
            // included, of those a vocabulary declares the most specific.
            for (form, predicate) in [("Domain", schema.domain), ("Range", schema.range)] {
                let declared = schema.objects(of: term, predicate).filter { swiftName($0) != nil }.sorted()
                if let most = schema.mostSpecific(of: declared), let name = swiftName(most) {
                    annotations.append(ParsedAnnotation(name: form, value: name))
                }
            }
        }
        var predicates: [String] = []
        for statement in statements where !predicates.contains(statement.predicate.rawValue) && schema.isAnnotationProperty(statement.predicate.rawValue) {
            predicates.append(statement.predicate.rawValue)
        }
        for predicate in predicates {
            let values = statements.filter { $0.predicate.rawValue == predicate }.map(\.object)
            if let value = text(values) {
                annotations.append(ParsedAnnotation(name: "Annotation", value: "\(localName(predicate)): \(value)"))
            }
        }
        return ParsedEntity(name: localName(term), kind: kind, annotations: annotations)
    }

    /// The Swift type that declares a term: `RDFS.Resource`, or
    /// `FOAF.Person`.
    func swiftName(_ iri: String) -> String? {
        names[iri]
    }

    /// The vocabulary that declares a term.
    func vocabulary(declaring iri: String) -> Vocabulary? {
        all.first { $0.termSet.contains(iri) }
    }

    func localName(_ iri: String) -> String {
        String(iri[(iri.lastIndex(where: { $0 == "#" || $0 == "/" }).map(iri.index(after:)) ?? iri.startIndex)...])
    }

    static func namespace(of iri: String) -> String {
        String(iri[..<(iri.lastIndex(where: { $0 == "#" || $0 == "/" }).map(iri.index(after:)) ?? iri.startIndex)])
    }

    /// Whether a local name can be a Swift identifier as it is.
    static func isIdentifier(_ name: String) -> Bool {
        guard let first = name.first, first.isLetter || first == "_" else { return false }
        return name.allSatisfy { $0.isLetter || $0.isNumber || $0 == "_" }
    }

    /// The text of an annotation: the literal with no language tag, or in
    /// English, or the first.
    func text(_ objects: [ObjectTerm]) -> String? {
        let literals = objects.compactMap { object -> Literal? in
            if case .literal(let literal) = object { return literal }
            return nil
        }
        let chosen = literals.first { $0.languageTag == nil } ?? literals.first { $0.languageTag?.lowercased().hasPrefix("en") == true } ?? literals.first
        return chosen?.lexicalForm.split(whereSeparator: \.isNewline).map { $0.trimmingCharacters(in: .whitespaces) }.joined(separator: " ")
    }
}

extension ObjectTerm {
    var iriValue: String? {
        if case .iri(let iri) = self { return iri.rawValue }
        return nil
    }
}

extension Schema {
    /// The schema the statements of these graphs entail.
    init(_ graphs: [Graph]) {
        var triples: [Triple] = []
        for graph in graphs {
            for triple in graph {
                guard case .iri(let subject) = triple.subject, case .iri(let object) = triple.object else { continue }
                triples.append(Triple(subject.rawValue, triple.predicate.rawValue, object.rawValue))
            }
        }
        self.init(triples)
    }
}
