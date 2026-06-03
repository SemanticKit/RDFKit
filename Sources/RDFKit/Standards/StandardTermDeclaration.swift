import Foundation

/// A standard RDF/RDFS/OWL term declaration backed by a standards matrix row.
public struct StandardTermDeclaration: Term, OntologyContent, GraphContent, Comparable, Codable, CustomStringConvertible, CustomDebugStringConvertible {
    /// The standards matrix row that defines this term.
    public let entry: VocabularyMatrixEntry

    /// Creates a standard term declaration from a matrix row.
    public init(entry: VocabularyMatrixEntry) {
        self.entry = entry
    }

    /// Creates a standard term declaration by resolving the bundled standards matrix.
    public init(namespace: Namespace, localName: LocalName, vocabulary: String) throws {
        let iri = QualifiedName(namespace: namespace, localName: localName).iri
        let matrix = try StandardsMatrix.bundled()
        guard let entry = matrix.entry(for: iri), entry.namespace == vocabulary else {
            throw RDFTermError.invalidIRI(iri.rawValue)
        }
        self.entry = entry
    }

    /// The raw IRI string.
    public var rawValue: String { iri.rawValue }

    /// The term IRI.
    public var iri: IRI { entry.iri }

    /// The derived vocabulary role.
    public var role: VocabularyRole { entry.role }

    /// The Swift protocols required by this matrix row.
    public var requiredSwiftProtocols: [String] { entry.requiredSwiftProtocols }

    /// A stable textual representation.
    public var description: String { iri.description }

    /// A debugging representation that includes the type name.
    public var debugDescription: String { "StandardTermDeclaration(\(iri.rawValue.debugDescription))" }

    public static func < (lhs: StandardTermDeclaration, rhs: StandardTermDeclaration) -> Bool {
        lhs.iri < rhs.iri
    }

    public static func == (lhs: StandardTermDeclaration, rhs: StandardTermDeclaration) -> Bool {
        lhs.iri == rhs.iri
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(iri)
    }

    /// Writes this matrix row into a graph.
    public func write(to graph: inout Graph) throws {
        try writeIRIEdges(entry.directTypes, predicate: RDF.type, to: &graph)
        try writeIRIEdges(entry.subclassChain, predicate: RDFS.subClassOf, to: &graph)
        try writeIRIEdges(entry.subpropertyChain, predicate: RDFS.subPropertyOf, to: &graph)
        try writeIRIEdges(entry.domain, predicate: RDFS.domain, to: &graph)
        try writeIRIEdges(entry.range, predicate: RDFS.range, to: &graph)
        try writeIRIEdges(entry.seeAlso, predicate: RDFS.seeAlso, to: &graph)
        try writeIRIEdges(entry.isDefinedBy, predicate: RDFS.isDefinedBy, to: &graph)
        try writeLiteralEdges(entry.labels, predicate: RDFS.label, to: &graph)
        try writeLiteralEdges(entry.comments, predicate: RDFS.comment, to: &graph)
    }

    private func writeIRIEdges<Predicate: IRIRepresentable>(_ targets: [IRI], predicate: Predicate, to graph: inout Graph) throws {
        for target in targets {
            try insert(Graph.TripleType(subject: AnyRDFSubject(iri), predicate: predicate, object: AnyRDFObject(target)), into: &graph)
        }
    }

    private func writeLiteralEdges<Predicate: IRIRepresentable>(_ values: [String], predicate: Predicate, to graph: inout Graph) throws {
        for value in values {
            try insert(Graph.TripleType(subject: AnyRDFSubject(iri), predicate: predicate, object: AnyRDFObject(try Literal(value))), into: &graph)
        }
    }

    private func insert(_ triple: Graph.TripleType, into graph: inout Graph) throws {
        if !graph.contains(triple) {
            try graph.insert(triple)
        }
    }
}
