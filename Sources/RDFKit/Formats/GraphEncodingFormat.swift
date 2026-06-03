import Foundation

/// A format that exports RDFKit graph content as source text.
public protocol GraphEncodingFormat: Sendable {
    /// Encodes RDF graph content as source text.
    func encodeGraph(_ graph: Graph) throws -> String
}
