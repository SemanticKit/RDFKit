import Foundation

/// Declares an RDFS isDefinedBy reference inside ontology declaration content.
public struct IsDefinedBy: ClassContent, PropertyContent, DatatypeContent, IndividualContent, AnnotationContent {
    /// The defining resource.
    public let value: TermReference

    /// Creates an isDefinedBy declaration from an IRI-backed value.
    public init<TermValue: IRIRepresentable>(_ value: TermValue) {
        self.value = TermReference(value)
    }

    /// Creates an isDefinedBy declaration from a vocabulary value.
    public init<VocabularyValue: Vocabulary>(_ value: VocabularyValue) {
        self.value = TermReference(value)
    }
}
