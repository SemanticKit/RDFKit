import Foundation

/// Declares an RDFS comment inside ontology declaration content.
public struct Comment: ClassContent, PropertyContent, DatatypeContent, IndividualContent, AnnotationContent {
    /// The comment text.
    public let value: String

    /// Creates a comment declaration.
    public init(_ value: String) {
        self.value = value
    }
}
