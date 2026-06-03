import Foundation

/// The OWL vocabulary namespace.
public struct OWL: Equatable, Hashable, Sendable {
    /// Creates an OWL vocabulary DSL value.
    public init() {}
}

extension OWL: StandardsVocabulary {
    /// The standards matrix label for OWL.
    static var standardsLabel: String { "OWL" }
}
