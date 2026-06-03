import Foundation

/// Declares an RDFS superproperty inside property declaration content.
public struct SubPropertyOf: PropertyContent {
    /// The referenced superproperty.
    public let value: TermReference

    /// Creates a superproperty declaration from an IRI-backed value.
    public init<TermValue: IRIRepresentable>(_ value: TermValue) {
        self.value = TermReference(value)
    }

    /// Creates a superproperty declaration from an IRI-backed type.
    public init<TermType: TypeIRIRepresentable>(_ value: TermType.Type) {
        self.value = TermReference(value)
    }
}
