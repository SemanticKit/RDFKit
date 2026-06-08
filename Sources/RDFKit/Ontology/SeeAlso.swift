import Foundation

/// Declares an RDFS seeAlso reference inside ontology declaration content.
public struct SeeAlso: Content {
    /// The referenced resource.
    let value: OntologyTermReference

    /// Creates a seeAlso declaration from a local name.
    public init(_ localName: String) {
        self.value = OntologyTermReference(localName)
    }

    /// Creates a seeAlso declaration from an IRI-backed value.
    public init<TermValue: IRIRepresentable>(_ value: TermValue) {
        self.value = OntologyTermReference(value)
    }

}
