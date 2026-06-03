import Foundation

/// Declares an RDFS seeAlso reference inside ontology declaration content.
public struct SeeAlso: ClassContent, PropertyContent, DatatypeContent, IndividualContent, AnnotationContent {
    /// The referenced resource.
    public let value: TermReference

    /// Creates a seeAlso declaration from an IRI-backed value.
    public init<TermValue: IRIRepresentable>(_ value: TermValue) {
        self.value = TermReference(value)
    }

    /// Creates a seeAlso declaration from a vocabulary value.
    public init<VocabularyValue: Vocabulary>(_ value: VocabularyValue) {
        self.value = TermReference(value)
    }
}

extension SeeAlso: OntologyFactContent {
    /// Adds this seeAlso reference to the enclosing declaration facts.
    func addFacts(to facts: inout OntologyDeclarationFacts, in environment: OntologyEnvironment) {
        facts.seeAlso.insert(value.iri)
    }
}
