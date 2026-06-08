import Foundation

/// Declares an RDFS superproperty as authored content.
public struct SubPropertyOf: Content {
    /// The referenced superproperty.
    let value: OntologyTermReference

    /// Creates a superproperty declaration from a local name.
    public init(_ localName: String) {
        self.value = OntologyTermReference(localName)
    }

    /// Creates a superproperty declaration from an IRI-backed value.
    public init<TermValue: IRIRepresentable>(_ value: TermValue) {
        self.value = OntologyTermReference(value)
    }

    /// Creates a superproperty declaration from authored content.
    public init<TermType: Content>(_ value: TermType.Type) {
        self.value = OntologyTermReference(value)
    }
}
