import IRIKit
import RDFCore

/// Decodes RDF 1.2 Turtle documents into a ``Graph``.
///
/// The decoder reads a document with the grammar of RDF 1.2 Turtle §6.5 as
/// the specification publishes it, translated into ``TurtleGrammar``,
/// including triple terms (`<<( s p o )>>`), reified triples
/// (`<< s p o ~ r >>`), annotations (`s p o ~ r {| … |}`), base directions
/// on language-tagged strings (`"text"@en--ltr`) and the `VERSION`
/// directive, and gives its productions the actions of §7.4. It is where the
/// IRIs written in a document become ``IRI`` values: relative references are
/// resolved against the base IRI (RFC 3986 §5.2) and prefixed names are
/// expanded before the IRI enters the runtime.
///
///     let graph = try TurtleDecoder(base: "http://example/doc").decode("""
///         PREFIX : <http://example/>
///         :s :p :o ~ :r {| :source :q |} .
///         """)
public struct TurtleDecoder: Sendable {
    /// The IRI a document's relative references resolve against until a
    /// `BASE` directive changes it, usually the document's own IRI.
    public let base: IRI?

    /// Creates a Turtle decoder.
    ///
    /// - Parameter base: The base IRI for relative references. Without one,
    ///   a document can still set a base with `@base` or `BASE`.
    public init(base: IRI? = nil) {
        self.base = base
    }

    /// Decodes a Turtle document.
    ///
    /// - Throws: ``SyntaxError`` when the document does not match the Turtle
    ///   grammar, uses an undeclared prefix, or names an IRI that is not
    ///   valid once resolved.
    public func decode(_ document: String) throws -> Graph {
        let syntax: TurtleGrammar.TurtleDoc
        do {
            syntax = try TurtleGrammar.TurtleDoc.parse(document)
        } catch {
            throw SyntaxError(error)
        }
        var reading = TurtleDecoding(base: base?.rawValue)
        for statement in syntax.statements {
            try reading.read(statement)
        }
        return reading.graph
    }
}
