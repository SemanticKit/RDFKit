import Foundation

/// A format that imports RDF dataset content into the RDFKit dataset model.
public protocol DatasetDecodingFormat: Sendable {
    /// Decodes RDF dataset content from source text.
    func decodeDataset(_ source: String) throws -> Dataset
}
