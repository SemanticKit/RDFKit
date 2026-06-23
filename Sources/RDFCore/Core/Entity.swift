import IRIKit

/// An ontology entity declared in the DSL.
///
/// Represents the declared thing itself, not an instance of it.
/// Contains class-level metadata derived from the DSL declarations.
public protocol Entity: Node {
    /// The class-level metadata for this entity.
    associatedtype ID: Identifiable
    associatedtype Metadata: Codable & Identifiable

    /// The class-level metadata.
    static var metadata: any ContentMetadata { get }

    /// The instance-level identifier.
    var id: ID { get }
}
