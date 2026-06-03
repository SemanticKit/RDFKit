import Foundation

/// Declares an RDFS seeAlso reference inside ontology declaration content.
public struct SeeAlso: ClassContent, PropertyContent, DatatypeContent, IndividualContent, AnnotationContent {
    /// The referenced resource.
    public let value: OntologyTermReference

    /// Creates a seeAlso declaration from a local name in the enclosing ontology namespace.
    public init(_ localName: String) {
        self.value = OntologyTermReference(localName)
    }

    /// Creates a seeAlso declaration from an IRI-backed value.
    public init<TermValue: IRIRepresentable>(_ value: TermValue) {
        self.value = OntologyTermReference(value)
    }

    /// Creates a seeAlso declaration from an IRI-backed type.
    public init<TermType: TypeIRIRepresentable>(_ value: TermType.Type) {
        self.value = OntologyTermReference(value)
    }

    /// Creates a seeAlso declaration from a vocabulary value.
    public init<VocabularyValue: Vocabulary>(_ value: VocabularyValue) {
        self.value = OntologyTermReference(value)
    }
}

extension SeeAlso: OntologyFactContent {
    /// Adds this seeAlso reference to the enclosing declaration facts.
    func addFacts(to facts: inout OntologyDeclarationFacts, in environment: OntologyEnvironment) {
        facts.seeAlso.insert(value.iri(in: environment))
    }
}
