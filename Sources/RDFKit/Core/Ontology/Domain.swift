import Foundation

/// Declares an RDFS domain inside property declaration content.
public struct Domain: Content {
    /// The referenced domain class.
    let value: OntologyTermReference

    /// Creates a domain declaration from a local name.
    public init(_ localName: String) {
        self.value = OntologyTermReference(localName)
    }

    /// Creates a domain declaration from an IRI-backed value.
    public init<TermValue: IRIRepresentable>(_ value: TermValue) {
        self.value = OntologyTermReference(value)
    }

    /// Creates a domain declaration from authored content.
    public init<TermType: Content>(_ value: TermType.Type) {
        self.value = OntologyTermReference(value)
    }
}
