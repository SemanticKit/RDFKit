
import IRIKit

// MARK: - Comment

public struct Comment: DocumentationProperty, Sendable {
    public var comment: String

    public init(_ value: String) {
        self.comment = value
    }
}


// MARK: Generated Type Metadata

extension Comment: Entity {
    public static let metadata: any ContentMetadata = Property.PropertyMetadata(
        id: "http://www.w3.org/2000/01/rdf-schema#comment",
        name: "comment",
        label: "comment",
        comment: "A description of the subject resource."
    )
}
