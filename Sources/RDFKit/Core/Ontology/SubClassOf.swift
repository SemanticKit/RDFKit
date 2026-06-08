import Foundation

/// Declares an RDFS superclass as authored content.
public struct SubClassOf: Content {
    /// The referenced superclass.
    let value: OntologyTermReference

    /// Creates a superclass declaration from a local name.
    public init(_ localName: String) {
        self.value = OntologyTermReference(localName)
    }

    /// Creates a superclass declaration from an IRI-backed value.
    public init<TermValue: IRIRepresentable>(_ value: TermValue) {
        self.value = OntologyTermReference(value)
    }

    /// Creates a superclass declaration from authored content.
    public init<TermType: Content>(_ value: TermType.Type) {
        self.value = OntologyTermReference(value)
    }
}
