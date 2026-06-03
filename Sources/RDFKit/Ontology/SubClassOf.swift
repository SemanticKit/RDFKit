import Foundation

/// Declares an RDFS superclass inside class declaration content.
public struct SubClassOf: ClassContent, DatatypeContent {
    /// The referenced superclass.
    public let value: TermReference

    /// Creates a superclass declaration from an IRI-backed value.
    public init<TermValue: IRIRepresentable>(_ value: TermValue) {
        self.value = TermReference(value)
    }

    /// Creates a superclass declaration from an IRI-backed type.
    public init<TermType: TypeIRIRepresentable>(_ value: TermType.Type) {
        self.value = TermReference(value)
    }
}
