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
}
