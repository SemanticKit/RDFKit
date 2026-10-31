import Testing

extension Tag {
    @Tag static var property: Self
    @Tag static var characteristic: Self
    /// A class's protocol and its inheritance.
    @Tag static var `class`: Self
    /// The RDF vocabulary.
    @Tag static var rdf: Self
    /// The RDF Schema vocabulary.
    @Tag static var rdfs: Self
    /// The OWL vocabulary.
    @Tag static var owl: Self
    /// The @Ontology macro's code generation.
    @Tag static var codeGeneration: Self
    /// The XML Schema datatypes.
    @Tag static var xsd: Self
    /// The FOAF vocabulary.
    @Tag static var foaf: Self
    /// Values read where a term leaves the runtime (serialization, translation).
    @Tag static var boundary: Self
    /// Tests from the W3C RDF test suites.
    @Tag static var w3c: Self
    /// Reading and writing N-Triples.
    @Tag static var nTriples: Self
    /// Reading Turtle.
    @Tag static var turtle: Self
    /// Reading RDF/XML.
    @Tag static var rdfXML: Self
}
