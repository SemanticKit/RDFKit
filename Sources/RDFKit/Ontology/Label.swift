import Foundation

/// Declares an RDFS label inside ontology declaration content.
public struct Label: ClassContent, PropertyContent, DatatypeContent, IndividualContent, AnnotationContent {
    /// The label text.
    public let value: String

    /// Creates a label declaration.
    public init(_ value: String) {
        self.value = value
    }
}

extension Label: OntologyFactContent {
    /// Adds this label to the enclosing declaration facts.
    func addFacts(to facts: inout OntologyDeclarationFacts) {
        facts.labels.insert(value)
    }
}
