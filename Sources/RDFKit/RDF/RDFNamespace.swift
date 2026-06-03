import Foundation

/// The RDF vocabulary namespace.
public struct RDF: Equatable, Hashable, Sendable {
    /// Creates an RDF vocabulary DSL value.
    public init() {}
}

extension RDF: StandardsVocabulary {
    /// The standards matrix label for RDF.
    static var standardsLabel: String { "RDF" }
}
