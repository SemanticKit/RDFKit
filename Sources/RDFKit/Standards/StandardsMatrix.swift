import Foundation

/// The RDF/RDFS/OWL standards matrix derived from bundled Turtle resources.
public struct StandardsMatrix: Equatable, Sendable {
    /// Matrix rows keyed by term IRI.
    public let entries: [VocabularyMatrixEntry]

    /// Creates a standards matrix.
    public init(entries: [VocabularyMatrixEntry]) {
        self.entries = entries.sorted()
    }

    /// Returns entries belonging to a vocabulary namespace label.
    public func entries(in namespace: String) -> [VocabularyMatrixEntry] {
        entries.filter { $0.namespace == namespace }
    }

    /// Returns the entry for an IRI.
    public func entry(for iri: IRI) -> VocabularyMatrixEntry? {
        entries.first { $0.iri.rawValue == iri.rawValue }
    }

    /// Builds the standards matrix from bundled RDF, RDFS, and OWL Turtle resources.
    public static func bundled() throws -> StandardsMatrix {
        let specs: [(label: String, namespace: Namespace, file: String)] = [
            ("RDF", RDF.namespace, "rdf"),
            ("RDFS", RDFS.namespace, "rdfs"),
            ("OWL", OWL.namespace, "owl")
        ]
        var graph = Graph()
        for spec in specs {
            let text = try bundledTurtle(named: spec.file)
            graph = graph.merging(with: try Graph(turtle: text))
        }
        var rows: [VocabularyMatrixEntry] = []
        for spec in specs {
            let subjects = graph.triples.compactMap { triple -> IRI? in
                guard let iri = triple.subject.node as? IRI else { return nil }
                guard iri.rawValue.hasPrefix(spec.namespace.rawValue) else { return nil }
                guard iri.rawValue.count > spec.namespace.rawValue.count else { return nil }
                return iri
            }
            for iri in Set(subjects).sorted() {
                rows.append(row(for: iri, namespaceLabel: spec.label, namespace: spec.namespace, graph: graph))
            }
        }
        return StandardsMatrix(entries: rows)
    }

    private static func bundledTurtle(named name: String) throws -> String {
        #if SWIFT_PACKAGE
        guard let url = Bundle.module.url(forResource: name, withExtension: "ttl", subdirectory: "Turtle") else {
            throw RDFTermError.invalidIRI(name)
        }
        #else
        guard let url = Bundle.main.url(forResource: name, withExtension: "ttl", subdirectory: "Turtle") else {
            throw RDFTermError.invalidIRI(name)
        }
        #endif
        return try String(contentsOf: url, encoding: .utf8)
    }

    private static func row(for iri: IRI, namespaceLabel: String, namespace: Namespace, graph: Graph) -> VocabularyMatrixEntry {
        let localName = LocalName(String(iri.rawValue.dropFirst(namespace.rawValue.count)))
        let directTypes = iriObjects(subject: iri, predicate: RDF.type, graph: graph)
        let subclassChain = transitiveObjects(from: iri, predicate: RDFS.subClassOf, graph: graph)
        let subpropertyChain = transitiveObjects(from: iri, predicate: RDFS.subPropertyOf, graph: graph)
        let domain = iriObjects(subject: iri, predicate: RDFS.domain, graph: graph)
        let range = iriObjects(subject: iri, predicate: RDFS.range, graph: graph)
        let labels = literalObjects(subject: iri, predicate: RDFS.label, graph: graph)
        let comments = literalObjects(subject: iri, predicate: RDFS.comment, graph: graph)
        let seeAlso = iriObjects(subject: iri, predicate: RDFS.seeAlso, graph: graph)
        let isDefinedBy = iriObjects(subject: iri, predicate: RDFS.isDefinedBy, graph: graph)
        let role = roleFor(directTypes: directTypes, subclassChain: subclassChain)
        let edges = dependencyEdges(
            directTypes: directTypes,
            subclassChain: subclassChain,
            subpropertyChain: subpropertyChain,
            domain: domain,
            range: range,
            seeAlso: seeAlso,
            isDefinedBy: isDefinedBy
        )
        return VocabularyMatrixEntry(
            namespace: namespaceLabel,
            localName: localName,
            iri: iri,
            role: role,
            directTypes: directTypes,
            subclassChain: subclassChain,
            subpropertyChain: subpropertyChain,
            domain: domain,
            range: range,
            labels: labels,
            comments: comments,
            seeAlso: seeAlso,
            isDefinedBy: isDefinedBy,
            dependencyEdges: edges,
            requiredSwiftProtocols: protocols(for: role, domain: domain, range: range, subpropertyChain: subpropertyChain)
        )
    }

    private static func iriObjects<Predicate: IRIRepresentable>(subject: IRI, predicate: Predicate, graph: Graph) -> [IRI] {
        graph.triples.compactMap { triple in
            guard (triple.subject.node as? IRI)?.rawValue == subject.rawValue else { return nil }
            guard triple.predicate.rawValue == predicate.iri.rawValue else { return nil }
            return triple.object.node as? IRI
        }.sorted()
    }

    private static func literalObjects<Predicate: IRIRepresentable>(subject: IRI, predicate: Predicate, graph: Graph) -> [String] {
        graph.triples.compactMap { triple in
            guard (triple.subject.node as? IRI)?.rawValue == subject.rawValue else { return nil }
            guard triple.predicate.rawValue == predicate.iri.rawValue else { return nil }
            return (triple.object.node as? Literal)?.lexicalForm
        }.sorted()
    }

    private static func transitiveObjects<Predicate: IRIRepresentable>(from iri: IRI, predicate: Predicate, graph: Graph) -> [IRI] {
        var visited: Set<IRI> = []
        var queue = iriObjects(subject: iri, predicate: predicate, graph: graph)
        while let next = queue.first {
            queue.removeFirst()
            guard visited.insert(next).inserted else { continue }
            queue.append(contentsOf: iriObjects(subject: next, predicate: predicate, graph: graph))
        }
        return visited.sorted()
    }

    private static func roleFor(directTypes: [IRI], subclassChain: [IRI]) -> VocabularyRole {
        if contains(RDFS.Datatype.iri, in: directTypes) { return .datatype }
        if contains(RDF.Property.iri, in: directTypes) { return .property }
        if contains(OWL.ObjectProperty.iri, in: directTypes) || contains(OWL.DatatypeProperty.iri, in: directTypes) || contains(OWL.AnnotationProperty.iri, in: directTypes) || contains(OWL.OntologyProperty.iri, in: directTypes) { return .property }
        if contains(RDFS.Class.iri, in: directTypes) { return .class }
        if contains(OWL.NamedIndividual.iri, in: directTypes) { return .individual }
        if contains(RDF.Property.iri, in: subclassChain) { return .property }
        return .term
    }

    private static func contains(_ iri: IRI, in values: [IRI]) -> Bool {
        values.contains { $0.rawValue == iri.rawValue }
    }

    private static func dependencyEdges(
        directTypes: [IRI],
        subclassChain: [IRI],
        subpropertyChain: [IRI],
        domain: [IRI],
        range: [IRI],
        seeAlso: [IRI],
        isDefinedBy: [IRI]
    ) -> [VocabularyDependencyEdge] {
        var edges: [VocabularyDependencyEdge] = []
        edges += directTypes.map { VocabularyDependencyEdge(kind: "type", target: $0) }
        edges += subclassChain.map { VocabularyDependencyEdge(kind: "subClassOf", target: $0) }
        edges += subpropertyChain.map { VocabularyDependencyEdge(kind: "subPropertyOf", target: $0) }
        edges += domain.map { VocabularyDependencyEdge(kind: "domain", target: $0) }
        edges += range.map { VocabularyDependencyEdge(kind: "range", target: $0) }
        edges += seeAlso.map { VocabularyDependencyEdge(kind: "seeAlso", target: $0) }
        edges += isDefinedBy.map { VocabularyDependencyEdge(kind: "isDefinedBy", target: $0) }
        return edges.sorted()
    }

    private static func protocols(for role: VocabularyRole, domain: [IRI], range: [IRI], subpropertyChain: [IRI]) -> [String] {
        var names = ["IRIRepresentable", "VocabularyTerm", "Term", "Identifiable"]
        switch role {
        case .class:
            names.append("Class")
        case .property:
            names.append("Property")
        case .datatype:
            names.append("Datatype")
        case .individual:
            names.append("Individual")
        case .term:
            break
        }
        if !domain.isEmpty { names.append("DomainConstrainedProperty") }
        if !range.isEmpty { names.append("RangeConstrainedProperty") }
        if !subpropertyChain.isEmpty { names.append("SubpropertyAwareProperty") }
        return Array(Set(names)).sorted()
    }
}
