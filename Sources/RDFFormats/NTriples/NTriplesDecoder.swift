import IRIKit
import RDFCore

/// Decodes RDF 1.2 N-Triples documents into a ``Graph``.
///
/// The decoder reads a document with the grammar of RDF 1.2 N-Triples §5.3
/// as the specification publishes it, translated into ``NTriplesGrammar``.
/// It is where the IRIs written in a document become ``IRI`` values: every
/// `IRIREF` is unescaped and validated as an absolute IRI before it enters
/// the runtime.
///
///     let graph = try NTriplesDecoder().decode(
///         "<http://example/s> <http://example/p> \"hello\"@en--ltr .\n"
///     )
public struct NTriplesDecoder: Sendable {
    /// Creates an N-Triples decoder.
    public init() {}

    /// Decodes an N-Triples document.
    ///
    /// - Throws: ``SyntaxError`` when the document does not match the
    ///   N-Triples grammar.
    public func decode(_ document: String) throws -> Graph {
        let syntax: NTriplesGrammar.NtriplesDoc
        do {
            syntax = try NTriplesGrammar.NtriplesDoc.parse(document)
        } catch {
            throw SyntaxError(error)
        }
        // ntriplesDoc ::= statement? (EOL statement)* EOL?
        var graph: Graph = []
        for statement in [syntax.statement].compactMap({ $0 }) + syntax.eolAndStatements.map(\.statement) {
            // statement ::= directive | triple; a version directive
            // produces no triple.
            if case .triple(let triple) = statement {
                graph.insert(try Graph.Element(triple))
            }
        }
        return graph
    }
}
