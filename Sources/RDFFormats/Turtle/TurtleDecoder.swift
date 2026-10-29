import IRIKit
import RDFCore

/// Decodes RDF 1.2 Turtle documents into triples.
///
/// The decoder follows the grammar in RDF 1.2 Turtle §7.3, including triple
/// terms (`<<( s p o )>>`), reified triples (`<< s p o ~ r >>`), annotations
/// (`s p o ~ r {| … |}`), base directions on language-tagged strings
/// (`"text"@en--ltr`) and the `VERSION` directive. It is where the IRIs
/// written in a document become ``IRI`` values: relative references are
/// resolved against the base IRI (RFC 3986 §5.2) and prefixed names are
/// expanded before the IRI enters the runtime.
///
///     let triples = try TurtleDecoder(base: "http://example/doc").decode("""
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
    public func decode(_ document: String) throws -> [DecodedTriple] {
        var parser = try TurtleParser(document, base: base?.rawValue)
        return try parser.parseDocument()
    }
}
