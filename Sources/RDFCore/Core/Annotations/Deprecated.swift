import IRIKit

/// Marks the declared term as deprecated.
///
/// `owl:deprecated`
///
///     Deprecated()
public struct Deprecated: Annotation {
    public static let metadata: any ContentMetadata = RDFMetadata(
        id: "http://www.w3.org/2002/07/owl#deprecated",
        name: "deprecated",
        label: "deprecated",
        comment: "The annotation property that indicates that a given entity has been deprecated."
    )

    public init() {}
}
