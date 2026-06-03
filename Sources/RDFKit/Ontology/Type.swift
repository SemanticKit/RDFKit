import Foundation

/// Declares an RDF type relationship inside ontology declaration content.
public struct Type: ClassContent, PropertyContent, DatatypeContent, IndividualContent {
    /// The referenced RDF type.
    public let value: TermReference

    /// Creates a type declaration from an IRI-backed value.
    public init<TermValue: IRIRepresentable>(_ value: TermValue) {
        self.value = TermReference(value)
    }

    /// Creates a type declaration from an IRI-backed type.
    public init<TermType: TypeIRIRepresentable>(_ value: TermType.Type) {
        self.value = TermReference(value)
    }
}
