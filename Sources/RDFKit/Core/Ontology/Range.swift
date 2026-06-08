import Foundation

/// Declares an RDFS range as authored content.
public struct Range: Content {
    /// The referenced range class or datatype.
    let value: OntologyTermReference

    /// Creates a range declaration from a local name.
    public init(_ localName: String) {
        self.value = OntologyTermReference(localName)
    }

    /// Creates a range declaration from an IRI-backed value.
    public init<TermValue: IRIRepresentable>(_ value: TermValue) {
        self.value = OntologyTermReference(value)
    }

    /// Creates a range declaration from authored content.
    public init<TermType: Content>(_ value: TermType.Type) {
        self.value = OntologyTermReference(value)
    }
}
