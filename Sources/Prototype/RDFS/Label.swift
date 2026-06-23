import IRIKit

// MARK: - Label Type

public struct Label: DocumentationProperty, Sendable {
    public typealias ID = IRI

    public var id: ID

    public init(_ value: String) {
        // TODO: Temporary to shut the compiler up.
        self.id = try! IRI(validating: value)
    }
}


// MARK: Generated Type Metadata

extension Label: Entity {
    // Label IS a property — uses Property.Metadata for its own creation
    public static let metadata: any ContentMetadata = Property.PropertyMetadata(
        id: "http://www.w3.org/2000/01/rdf-schema#label",
        name: "label",
        type: "http://www.w3.org/1999/02/22-rdf-syntax-ns#Property",
        domain: "http://www.w3.org/2000/01/rdf-schema#Resource",
        range: "http://www.w3.org/2000/01/rdf-schema#Literal",
        label: "label",
        comment: "A human-readable name for the subject."
    )
}
