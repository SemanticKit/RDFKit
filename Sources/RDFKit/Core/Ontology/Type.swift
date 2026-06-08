import Foundation

/// Declares an RDF type relationship as authored content.
public struct Type: Content {
    /// The referenced RDF type.
    let value: OntologyTermReference

    /// Creates a type declaration from a local name.
    public init(_ localName: String) {
        self.value = OntologyTermReference(localName)
    }

    /// Creates a type declaration from an IRI-backed value.
    public init<TermValue: IRIRepresentable>(_ value: TermValue) {
        self.value = OntologyTermReference(value)
    }

    /// Creates a type declaration from authored content.
    public init<TermType: Content>(_ value: TermType.Type) {
        self.value = OntologyTermReference(value)
    }
}
