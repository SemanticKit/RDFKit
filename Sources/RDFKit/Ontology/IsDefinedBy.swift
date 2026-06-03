import Foundation

/// Declares an RDFS isDefinedBy reference inside ontology declaration content.
public struct IsDefinedBy: ClassContent, PropertyContent, DatatypeContent, IndividualContent, AnnotationContent {
    /// The defining resource.
    private let value: TermReference?

    /// Creates an isDefinedBy declaration for the enclosing ontology.
    public init() {
        self.value = nil
    }

    /// Creates an isDefinedBy declaration from an IRI-backed value.
    public init<TermValue: IRIRepresentable>(_ value: TermValue) {
        self.value = TermReference(value)
    }

    /// Creates an isDefinedBy declaration from a vocabulary value.
    public init<VocabularyValue: Vocabulary>(_ value: VocabularyValue) {
        self.value = TermReference(value)
    }
}

extension IsDefinedBy: OntologyFactContent {
    /// Adds this defining resource reference to the enclosing declaration facts.
    func addFacts(to facts: inout OntologyDeclarationFacts, in environment: OntologyEnvironment) {
        facts.isDefinedBy.insert(value?.iri ?? environment.iri)
    }
}
