import IRIKit

// MARK: - Label Type

public struct Label: DocumentationProperty, Sendable {
    /// The label text.
    public var text: String

    public init(_ text: String) {
        self.text = text
    }
}


// MARK: Generated Type Metadata

extension Label: Entity {
    // Label IS a property — uses Property.Metadata for its own creation
    public static let metadata: any ContentMetadata = Property.PropertyMetadata(
        id: "http://www.w3.org/2000/01/rdf-schema#label",
        name: "label",
        label: "label",
        comment: "A human-readable name for the subject."
    )
}
