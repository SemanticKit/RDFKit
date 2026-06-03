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
