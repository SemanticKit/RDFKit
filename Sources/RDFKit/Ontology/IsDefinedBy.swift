import Foundation

/// Declares an RDFS isDefinedBy reference inside ontology declaration content.
public struct IsDefinedBy: Content {
    /// The defining resource.
    private let value: OntologyTermReference?

    /// Creates an isDefinedBy declaration for the enclosing ontology.
    public init() {
        self.value = nil
    }

    /// Creates an isDefinedBy declaration from a local name.
    public init(_ localName: String) {
        self.value = OntologyTermReference(localName)
    }

    /// Creates an isDefinedBy declaration from an IRI-backed value.
    public init<TermValue: IRIRepresentable>(_ value: TermValue) {
        self.value = OntologyTermReference(value)
    }

}
