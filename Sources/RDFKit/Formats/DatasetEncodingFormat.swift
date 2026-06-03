import Foundation

/// A format that exports RDFKit dataset content as source text.
public protocol DatasetEncodingFormat: Sendable {
    /// Encodes RDF dataset content as source text.
    func encodeDataset(_ dataset: Dataset) throws -> String
}
