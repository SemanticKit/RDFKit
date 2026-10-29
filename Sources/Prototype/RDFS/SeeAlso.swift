
import IRIKit

// MARK: - SeeAlso

public struct SeeAlso: DocumentationProperty, Sendable {
    /// The address of the external document.
    public var seeAlso: IRI

    public init(_ document: IRI) {
        self.seeAlso = document
    }
}

// MARK: Generated Type Metadata

extension SeeAlso: Entity {
    public static let metadata: any ContentMetadata = Property.PropertyMetadata(
        id: "http://www.w3.org/2000/01/rdf-schema#seeAlso",
        name: "seeAlso",
        label: "seeAlso",
        comment: "Further information about the subject resource."
    )
}
