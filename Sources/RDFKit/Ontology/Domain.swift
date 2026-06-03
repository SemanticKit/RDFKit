import Foundation

/// Declares an RDFS domain inside property declaration content.
public struct Domain: PropertyContent {
    /// The referenced domain class.
    public let value: OntologyTermReference

    /// Creates a domain declaration from a local name in the enclosing ontology namespace.
    public init(_ localName: String) {
        self.value = OntologyTermReference(localName)
    }

    /// Creates a domain declaration from an IRI-backed value.
    public init<TermValue: IRIRepresentable>(_ value: TermValue) {
        self.value = OntologyTermReference(value)
    }

    /// Creates a domain declaration from an IRI-backed type.
    public init<TermType: TypeIRIRepresentable>(_ value: TermType.Type) {
        self.value = OntologyTermReference(value)
    }
}

extension Domain: OntologyFactContent {
    /// Adds this domain relationship to the enclosing declaration facts.
    func addFacts(to facts: inout OntologyDeclarationFacts, in environment: OntologyEnvironment) {
        facts.domains.insert(value.iri(in: environment))
    }
}
