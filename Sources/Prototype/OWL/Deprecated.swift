import IRIKit

// MARK: - Deprecated

public struct Deprecated: DocumentationProperty, Sendable {
    public init() {}
}


// MARK: Generated Type Metadata

extension Deprecated: Entity {
    public static let metadata: any ContentMetadata = Property.PropertyMetadata(
        id: "http://www.w3.org/2002/07/owl#deprecated",
        name: "deprecated",
        label: "deprecated",
        comment: "The definition of the subject resource is deprecated."
    )
}
