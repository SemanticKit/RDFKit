import Foundation

/// Declares OWL deprecation metadata inside ontology declaration content.
public struct OWLDeprecated: ClassContent, PropertyContent, DatatypeContent, IndividualContent, AnnotationContent {
    /// Whether the declaration is deprecated.
    public let value: Bool

    /// Creates a deprecation declaration.
    public init(_ value: Bool = true) {
        self.value = value
    }
}

extension OWLDeprecated: OntologyFactContent {
    /// Adds this deprecation marker to the enclosing declaration facts.
    func addFacts(to facts: inout OntologyDeclarationFacts) {
        facts.deprecated = value
    }
}
