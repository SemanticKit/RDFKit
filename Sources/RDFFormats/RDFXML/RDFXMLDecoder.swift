import IRIKit
import RDFCore

/// Decodes RDF 1.2 XML Syntax documents into triples.
///
/// The decoder reads the document's XML Information Set and applies the
/// grammar of RDF 1.2 XML Syntax, including `rdf:parseType` `"Resource"`,
/// `"Literal"`, `"Collection"` and `"Triple"`, `rdf:ID` (with reification
/// of property elements), `rdf:nodeID`, `rdf:li` container membership,
/// `xml:base`, `xml:lang`, `its:dir` and the `rdf:annotation` and
/// `rdf:annotationNodeID` reifiers. It is where the IRIs written in a
/// document become ``IRI`` values: relative references are resolved against
/// the in-scope base IRI (Resolving IRIs) before the IRI enters the runtime.
///
///     let triples = try RDFXMLDecoder(base: "http://example/doc").decode("""
///         <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
///                  xmlns:ex="http://example/">
///           <rdf:Description rdf:about="#s" ex:p="o"/>
///         </rdf:RDF>
///         """)
public struct RDFXMLDecoder: Sendable {
    /// The IRI a document's relative references resolve against until an
    /// `xml:base` attribute changes it, usually the document's own IRI.
    public let base: IRI?

    /// Creates an RDF/XML decoder.
    ///
    /// - Parameter base: The base IRI for relative references. Without one,
    ///   a document can still set a base with `xml:base`.
    public init(base: IRI? = nil) {
        self.base = base
    }

    /// Decodes an RDF/XML document.
    ///
    /// - Throws: ``SyntaxError`` when the document is not namespace
    ///   well-formed XML, does not match the RDF/XML grammar, or names an
    ///   IRI that is not valid once resolved.
    public func decode(_ document: String) throws -> Graph {
        var parser = try RDFXMLParser(document, base: base?.rawValue)
        return try parser.parseDocument()
    }
}
