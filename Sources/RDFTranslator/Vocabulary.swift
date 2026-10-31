import IRIKit
import OntologyGeneration
import RDFCore
import SwiftSyntax
import SwiftSyntaxBuilder

/// The terms of a vocabulary as its graph states them, read into the model
/// the generators take.
struct Vocabulary {
    let graph: Graph
    let module: String
    let namespace: String
    let terms: [String]
    /// The vocabularies of the targets this one depends on, whose terms it
    /// names by their Swift types.
    var dependencies: [Vocabulary] = []

    static let rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    static let rdfs = "http://www.w3.org/2000/01/rdf-schema#"
    static let owl = "http://www.w3.org/2002/07/owl#"

    /// The vocabularies RDFKit declares, by the Swift name of each.
    static let layers: [String: String] = [rdf: "RDF", rdfs: "RDFS", owl: "OWL"]

    /// The classes whose members are classes.
    static let classTypes: Set<String> = [rdfs + "Class", owl + "Class", rdfs + "Datatype"]

    /// The Swift that the listed terms generate: the protocols of its
    /// classes and properties, the classes and instances of its individuals,
    /// and, for a vocabulary, the description it encodes back to.
    func source() throws -> String {
        let ontology = try self.ontology()
        let declarations = ontology.classes.map { ClassGenerator.generate(class: $0, in: ontology) }
            + ontology.properties.compactMap { PropertyGenerator.generate(property: $0, in: ontology) }
        let individuals = try Individuals(vocabulary: self).declarations()
        let description = ontology.classes.isEmpty && ontology.properties.isEmpty ? [] : try Description(vocabulary: self).declarations()
        let file = SourceFileSyntax {
            // An individual's literal values are values of the Swift types
            // of their datatypes, which XSD declares (D6).
            for module in ["IRIKit", "RDFCore", "RDFKit"] + (individuals.isEmpty ? [] : ["XSD"]) + dependencies.map(\.module) {
                ImportDeclSyntax(path: [ImportPathComponentSyntax(name: .identifier(module))])
            }
            for declaration in declarations + individuals + description { declaration }
        }
        return file.formatted().description + "\n"
    }

    /// The listed classes and properties, read into the model the
    /// generators take.
    func ontology() throws -> ParsedOntology {
        var classes: [ParsedEntity] = []
        var properties: [ParsedEntity] = []
        for term in try terms.filter({ try !isIndividual($0) }) {
            let entity = try self.entity(term)
            if entity.kind == "Class" { classes.append(entity) } else { properties.append(entity) }
        }
        return ParsedOntology(name: module, namespace: namespace, classes: classes, properties: properties)
    }

    /// Whether a term is an individual: an instance of none of the classes
    /// whose instances are classes or properties, which RDF, RDFS and OWL
    /// declare.
    func isIndividual(_ term: String) throws -> Bool {
        let subject = SubjectTerm.iri(try IRI(validating: term))
        let types = graph.filter { $0.subject == subject && $0.predicate.rawValue == Self.rdf + "type" }.compactMap(\.object.iriValue)
        return !types.isEmpty && !types.contains { type in Self.layers.keys.contains { type.hasPrefix($0) } }
    }

    /// The vocabulary, this one or a dependency, that lists a term.
    func vocabulary(listing iri: String) -> Vocabulary? {
        if terms.contains(iri) { return self }
        return dependencies.lazy.compactMap { $0.vocabulary(listing: iri) }.first
    }

    /// A term's class or property declaration: its types, superclasses,
    /// domain and range as the Swift types that declare them, and its label
    /// and comment. A statement naming a term no Swift type declares is
    /// left out.
    func entity(_ term: String) throws -> ParsedEntity {
        let subject = SubjectTerm.iri(try IRI(validating: term))
        let statements = graph.filter { $0.subject == subject }
        guard !statements.isEmpty else {
            throw TranslationError(description: "the documents state nothing about <\(term)>")
        }
        func objects(_ predicate: String) -> [ObjectTerm] {
            statements.filter { $0.predicate.rawValue == predicate }.map(\.object).sorted { $0.description < $1.description }
        }
        let types = objects(Self.rdf + "type").compactMap(\.iriValue)
        let isClass = types.contains(where: Self.classTypes.contains)
        var annotations: [ParsedAnnotation] = []
        for type in types {
            if let name = swiftName(type) { annotations.append(ParsedAnnotation(name: "Type", value: name)) }
        }
        let related = isClass ? [("SubClassOf", Self.rdfs + "subClassOf")] : [("Domain", Self.rdfs + "domain"), ("Range", Self.rdfs + "range")]
        for (form, predicate) in related {
            for object in objects(predicate) {
                if let iri = object.iriValue, let name = swiftName(iri) { annotations.append(ParsedAnnotation(name: form, value: name)) }
            }
        }
        if let label = text(objects(Self.rdfs + "label")) { annotations.append(ParsedAnnotation(name: "Label", value: label)) }
        if let comment = text(objects(Self.rdfs + "comment")) { annotations.append(ParsedAnnotation(name: "Comment", value: comment)) }
        return ParsedEntity(name: localName(term), kind: isClass ? "Class" : "Property", annotations: annotations)
    }

    /// The Swift type that declares a term: `RDFS.Resource`, or
    /// `FOAF.Person` for a term of this vocabulary's units.
    func swiftName(_ iri: String) -> String? {
        if let vocabulary = vocabulary(listing: iri) { return "\(vocabulary.module).\(localName(iri))" }
        for (namespace, layer) in Self.layers where iri.hasPrefix(namespace) {
            return "\(layer).\(iri.dropFirst(namespace.count))"
        }
        return nil
    }

    func localName(_ iri: String) -> String {
        String(iri[(iri.lastIndex(where: { $0 == "#" || $0 == "/" }).map(iri.index(after:)) ?? iri.startIndex)...])
    }

    /// The text of a label or comment: the one with no language tag, or in
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
