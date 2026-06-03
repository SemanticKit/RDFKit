import Foundation

/// Declares an RDFS range inside property declaration content.
public struct Range: PropertyContent {
    /// The referenced range class or datatype.
    public let value: TermReference

    /// Creates a range declaration from an IRI-backed value.
    public init<TermValue: IRIRepresentable>(_ value: TermValue) {
        self.value = TermReference(value)
    }

    /// Creates a range declaration from an IRI-backed type.
    public init<TermType: TypeIRIRepresentable>(_ value: TermType.Type) {
        self.value = TermReference(value)
    }
}

extension Range: OntologyFactContent {
    /// Adds this range relationship to the enclosing declaration facts.
    func addFacts(to facts: inout OntologyDeclarationFacts) {
        facts.ranges.insert(value.iri)
    }
}
