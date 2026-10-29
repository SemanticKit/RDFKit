import IRIKit
import RDFCore
import RDFKit

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

/// `ntriplesDoc ::= statement? (EOL statement)* EOL?`
struct NTriplesParser {
    var scanner: Scanner
    var graph: Graph = []

    init(_ document: String) {
        scanner = Scanner(document)
    }

    mutating func parseDocument() throws -> Graph {
        while true {
            skipSpace()
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
        skipSpace()
        guard scanner.peek(is: "\"") || scanner.peek(is: "'") else {
            throw scanner.error("expected a quoted version specifier")
        }
        _ = try scanner.scanString(allowsSingleQuotes: true, allowsLongForms: false)
    }

    /// Spaces and tabs, then an optional comment, then a line end or the end
    /// of the document.
    mutating func parseEndOfLine() throws {
        skipSpace()
        if scanner.peek(is: "#") {
            while let scalar = scanner.peek(), scalar != "\n", scalar != "\r" { scanner.advance() }
        }
        guard scanner.isAtEnd || scanner.peek(is: "\n") || scanner.peek(is: "\r") else {
            throw scanner.error("expected the end of the line")
        }
    }

    /// Skips spaces, tabs and comments, staying on the current line.
    mutating func skipSpace() {
        while let scalar = scanner.peek() {
            if scalar == " " || scalar == "\t" {
                scanner.advance()
            } else if scalar == "#" {
                while let scalar = scanner.peek(), scalar != "\n", scalar != "\r" { scanner.advance() }
            } else {
                return
            }
        }
    }

    /// `triple ::= subject predicate object '.'`
    mutating func parseTriple() throws -> Graph.Element {
        let subject = try parseSubject()
        skipSpace()
        let predicate = try parseIRI()
        skipSpace()
        let object = try parseObject()
        skipSpace()
        guard scanner.consume(".") else { throw scanner.error("expected '.' after a triple") }
        return Graph.Element(subject: subject, predicate: predicate, object: object)
    }

    /// `subject ::= IRIREF | BLANK_NODE_LABEL`
    mutating func parseSubject() throws -> SubjectTerm {
        if scanner.peek(spells: "_:") {
            return .blankNode(try BlankNode(scanner.scanBlankNodeLabel()))
        }
        guard scanner.peek(is: "<"), !scanner.peek(is: "<", at: 1) else {
            throw scanner.error("expected an IRI or blank node as subject")
        }
        return .iri(try parseIRI())
    }

    /// `object ::= IRIREF | BLANK_NODE_LABEL | literal | tripleTerm`
    mutating func parseObject() throws -> ObjectTerm {
        if scanner.peek(spells: "<<(") {
            return .tripleTerm(try parseTripleTerm())
        }
        if scanner.peek(is: "\"") {
            return .literal(try parseLiteral())
        }
        return try parseSubject().object
    }

    /// `tripleTerm ::= '<<(' subject predicate object ')>>'`
    mutating func parseTripleTerm() throws -> Graph.Element {
        _ = scanner.consume("<<(")
        skipSpace()
        let subject = try parseSubject()
        skipSpace()
        let predicate = try parseIRI()
        skipSpace()
        let object = try parseObject()
        skipSpace()
        guard scanner.consume(")>>") else { throw scanner.error("expected ')>>' to close a triple term") }
        return Graph.Element(subject: subject, predicate: predicate, object: object)
    }

    /// `literal ::= STRING_LITERAL_QUOTE ('^^' IRIREF | LANG_DIR)?`
    mutating func parseLiteral() throws -> Literal {
        let start = scanner.index
        let lexicalForm = try scanner.scanString(allowsSingleQuotes: false, allowsLongForms: false).value
        skipSpace()
        if scanner.consume("^^") {
            skipSpace()
            let datatype = try parseIRI()
            do {
                return try Literal(lexicalForm, datatype: datatype)
            } catch {
                throw scanner.error("a language-tagged string cannot be written with '^^'", at: start)
            }
        }
        if scanner.peek(is: "@") {
            let position = scanner.index
            let word = try scanner.scanAtWord()
            let (language, direction) = try scanner.languageAndDirection(word, at: position)
            return try Literal(lexicalForm, languageTag: language, baseDirection: direction)
        }
        return Literal(lexicalForm)
    }

    /// An `IRIREF`, which N-Triples requires to be absolute.
    mutating func parseIRI() throws -> IRI {
        let start = scanner.index
        guard scanner.peek(is: "<") else { throw scanner.error("expected an IRI") }
        let text = try scanner.scanIRIReference()
        do {
            return try IRI(validating: text)
        } catch {
            throw scanner.error("<\(text)> is not an absolute IRI", at: start)
        }
    }
}
