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
