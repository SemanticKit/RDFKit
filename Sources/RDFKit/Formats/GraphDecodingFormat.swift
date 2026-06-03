import Foundation

/// A format that imports RDF graph content into the RDFKit graph model.
public protocol GraphDecodingFormat: Sendable {
    /// Decodes RDF graph content from source text.
    func decodeGraph(_ source: String) throws -> Graph
}
