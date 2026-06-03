import Foundation

/// Declares an RDFS domain inside property declaration content.
public struct Domain: PropertyContent {
    /// The referenced domain class.
    public let value: TermReference

    /// Creates a domain declaration from an IRI-backed value.
    public init<TermValue: IRIRepresentable>(_ value: TermValue) {
        self.value = TermReference(value)
    }

    /// Creates a domain declaration from an IRI-backed type.
    public init<TermType: TypeIRIRepresentable>(_ value: TermType.Type) {
        self.value = TermReference(value)
    }
}

extension Domain: OntologyFactContent {
    /// Adds this domain relationship to the enclosing declaration facts.
    func addFacts(to facts: inout OntologyDeclarationFacts) {
        facts.domains.insert(value.iri)
    }
}
