import Foundation

/// A bundled Turtle resource used to build a standards vocabulary matrix.
struct BundledVocabularyResource: Sendable {
    /// The standards vocabulary label.
    let label: String

    /// The standards vocabulary namespace.
    let namespace: Namespace

    /// The bundled resource name without extension.
    let name: String

    /// The bundled resource subdirectory, when the resource is copied as a directory.
    let subdirectory: String?
}
