import Foundation

/// The RDF Schema vocabulary namespace.
public struct RDFS: Equatable, Hashable, Sendable {
    /// Creates an RDFS vocabulary DSL value.
    public init() {}
}

extension RDFS: StandardsVocabulary {
    /// The standards matrix label for RDFS.
    static var standardsLabel: String { "RDFS" }
}
