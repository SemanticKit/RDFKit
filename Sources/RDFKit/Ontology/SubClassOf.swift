import Foundation

/// Declares an RDFS superclass inside class declaration content.
public struct SubClassOf: ClassContent, DatatypeContent {
    /// The referenced superclass.
    public let value: OntologyTermReference

    /// Creates a superclass declaration from a local name in the enclosing ontology namespace.
    public init(_ localName: String) {
        self.value = OntologyTermReference(localName)
    }

    /// Creates a superclass declaration from an IRI-backed value.
    public init<TermValue: IRIRepresentable>(_ value: TermValue) {
        self.value = OntologyTermReference(value)
    }

    /// Creates a superclass declaration from an IRI-backed type.
    public init<TermType: TypeIRIRepresentable>(_ value: TermType.Type) {
        self.value = OntologyTermReference(value)
    }
}

extension SubClassOf: OntologyFactContent {
    /// Adds this superclass relationship to the enclosing declaration facts.
    func addFacts(to facts: inout OntologyDeclarationFacts, in environment: OntologyEnvironment) {
        facts.superclasses.insert(value.iri(in: environment))
    }
}
