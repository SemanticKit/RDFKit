import Foundation

/// Declares an RDF type relationship inside ontology declaration content.
public struct Type: ClassContent, PropertyContent, DatatypeContent, IndividualContent {
    /// The referenced RDF type.
    public let value: OntologyTermReference

    /// Creates a type declaration from a local name in the enclosing ontology namespace.
    public init(_ localName: String) {
        self.value = OntologyTermReference(localName)
    }

    /// Creates a type declaration from an IRI-backed value.
    public init<TermValue: IRIRepresentable>(_ value: TermValue) {
        self.value = OntologyTermReference(value)
    }

    /// Creates a type declaration from an IRI-backed type.
    public init<TermType: TypeIRIRepresentable>(_ value: TermType.Type) {
        self.value = OntologyTermReference(value)
    }
}

extension Type: OntologyFactContent {
    /// Adds this type relationship to the enclosing declaration facts.
    func addFacts(to facts: inout OntologyDeclarationFacts, in environment: OntologyEnvironment) {
        facts.types.insert(value.iri(in: environment))
    }
}
