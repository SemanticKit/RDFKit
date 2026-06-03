import Foundation

/// Declares an RDFS isDefinedBy reference inside ontology declaration content.
public struct IsDefinedBy: ClassContent, PropertyContent, DatatypeContent, IndividualContent, AnnotationContent {
    /// The defining resource.
    private let value: OntologyTermReference?

    /// Creates an isDefinedBy declaration for the enclosing ontology.
    public init() {
        self.value = nil
    }

    /// Creates an isDefinedBy declaration from a local name in the enclosing ontology namespace.
    public init(_ localName: String) {
        self.value = OntologyTermReference(localName)
    }

    /// Creates an isDefinedBy declaration from an IRI-backed value.
    public init<TermValue: IRIRepresentable>(_ value: TermValue) {
        self.value = OntologyTermReference(value)
    }

    /// Creates an isDefinedBy declaration from an IRI-backed type.
    public init<TermType: TypeIRIRepresentable>(_ value: TermType.Type) {
        self.value = OntologyTermReference(value)
    }

    /// Creates an isDefinedBy declaration from a vocabulary value.
    public init<VocabularyValue: Vocabulary>(_ value: VocabularyValue) {
        self.value = OntologyTermReference(value)
    }
}

extension IsDefinedBy: OntologyFactContent {
    /// Adds this defining resource reference to the enclosing declaration facts.
    func addFacts(to facts: inout OntologyDeclarationFacts, in environment: OntologyEnvironment) {
        facts.isDefinedBy.insert(value?.iri(in: environment) ?? environment.iri)
    }
}
