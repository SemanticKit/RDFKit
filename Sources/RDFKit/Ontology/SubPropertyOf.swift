import Foundation

/// Declares an RDFS superproperty inside property declaration content.
public struct SubPropertyOf: PropertyContent {
    /// The referenced superproperty.
    public let value: OntologyTermReference

    /// Creates a superproperty declaration from a local name in the enclosing ontology namespace.
    public init(_ localName: String) {
        self.value = OntologyTermReference(localName)
    }

    /// Creates a superproperty declaration from an IRI-backed value.
    public init<TermValue: IRIRepresentable>(_ value: TermValue) {
        self.value = OntologyTermReference(value)
    }

    /// Creates a superproperty declaration from an IRI-backed type.
    public init<TermType: TypeIRIRepresentable>(_ value: TermType.Type) {
        self.value = OntologyTermReference(value)
    }
}

extension SubPropertyOf: OntologyFactContent {
    /// Adds this superproperty relationship to the enclosing declaration facts.
    func addFacts(to facts: inout OntologyDeclarationFacts, in environment: OntologyEnvironment) {
        facts.superproperties.insert(value.iri(in: environment))
    }
}
