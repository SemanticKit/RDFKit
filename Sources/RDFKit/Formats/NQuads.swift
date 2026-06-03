import Foundation

/// N-Quads RDF dataset format.
public struct NQuads: DatasetDecodingFormat, DatasetEncodingFormat {
    /// Creates an N-Quads format.
    public init() {}

    /// Decodes N-Quads source into a dataset.
    public func decodeDataset(_ source: String) throws -> Dataset {
        var decoder = NQuadsDecoder(text: source)
        return try decoder.decodeDataset()
    }

    /// Encodes a dataset as N-Quads source.
    public func encodeDataset(_ dataset: Dataset) throws -> String {
        let encoder = NQuadsEncoder()
        return encoder.encode(dataset: dataset)
    }
}
