import IRIKit
import RDFCore

/// Decodes RDF 1.2 N-Triples documents into a ``Graph``.
///
/// The decoder follows the grammar in RDF 1.2 N-Triples §7. It is where the
/// IRIs written in a document become ``IRI`` values: every `IRIREF` is
/// unescaped and validated as an absolute IRI before it enters the runtime.
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
        var parser = NTriplesParser(document)
        return try parser.parseDocument()
    }
}

/// `ntriplesDoc ::= statement? (EOL statement)* EOL?`: the statements and
/// lines of a document. Each term reads itself (`SubjectTerm(nTriples:)`,
/// `ObjectTerm(nTriples:)`, `IRI(nTriples:)`, `Literal(nTriples:)`).
struct NTriplesParser {
    var scanner: Scanner
    var graph: Graph = []

    init(_ document: String) {
        scanner = Scanner(document)
    }

    mutating func parseDocument() throws -> Graph {
        while true {
            scanner.skipLineSpace()
            if scanner.isAtEnd { break }
            if scanner.peek(is: "\n") || scanner.peek(is: "\r") {
                scanner.advance()
                continue
            }
            if scanner.peek(spells: "VERSION") {
                try parseVersion()
            } else {
                graph.insert(try parseTriple())
            }
            try parseEndOfLine()
        }
        return graph
    }

    /// `versionDirective ::= 'VERSION' versionSpecifier`
    mutating func parseVersion() throws {
        _ = scanner.consume("VERSION")
        scanner.skipLineSpace()
        _ = try scanner.scanVersionSpecifier()
    }

    /// Spaces and tabs, then an optional comment, then a line end or the end
    /// of the document.
    mutating func parseEndOfLine() throws {
        scanner.skipLineSpace()
        guard scanner.isAtEnd || scanner.peek(is: "\n") || scanner.peek(is: "\r") else {
            throw scanner.error("expected the end of the line")
        }
    }

    /// `triple ::= subject predicate object '.'`
    mutating func parseTriple() throws -> Graph.Element {
        let subject = try SubjectTerm(nTriples: &scanner)
        scanner.skipLineSpace()
        let predicate = try IRI(nTriples: &scanner)
        scanner.skipLineSpace()
        let object = try ObjectTerm(nTriples: &scanner)
        scanner.skipLineSpace()
        guard scanner.consume(".") else { throw scanner.error("expected '.' after a triple") }
        return Graph.Element(subject: subject, predicate: predicate, object: object)
    }
}
