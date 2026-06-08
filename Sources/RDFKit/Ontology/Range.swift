import Foundation

/// Declares an RDFS range inside property declaration content.
public struct Range: Content {
    /// The referenced range class or datatype.
    public let value: OntologyTermReference

    /// Creates a range declaration from a local name in the enclosing ontology namespace.
    public init(_ localName: String) {
        self.value = OntologyTermReference(localName)
    }

    /// Creates a range declaration from an ontology-scoped value in the enclosing ontology namespace.
    public init<TermValue: OntologyScopedTerm>(_ value: TermValue) {
        self.value = OntologyTermReference(value)
    }

    /// Creates a range declaration from an IRI-backed value.
    public init<TermValue: IRIRepresentable>(_ value: TermValue) {
        self.value = OntologyTermReference(value)
    }

    /// Creates a range declaration from an ontology-scoped type in the enclosing ontology namespace.
    public init<TermType: OntologyScopedTerm>(_ value: TermType.Type) {
        self.value = OntologyTermReference(value)
    }

    /// Creates a range declaration from an IRI-backed type.
    public init<TermType: TypeIRIRepresentable>(_ value: TermType.Type) {
        self.value = OntologyTermReference(value)
    }
}
