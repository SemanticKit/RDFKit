import IRIKit

/// Declares a named individual: in RDF's own vocabulary, `rdf:nil` is one,
/// translated as the module-level value `RDF.nil`.
///
/// A named individual is a module-level value, never a member of an
/// ontology type, and a macro cannot declare module-level names, so
/// `@Ontology` reports `Individual` in a `var body`: a named individual
/// comes from RDF data that `RDFTranslatorPlugin` translates, or is declared
/// in Swift as an instance of its class.
///
/// `owl:NamedIndividual`
///
///     Individual("nil") {
///         Type(RDF.List)
///     }
public struct Individual: Declaration {
    public static let metadata: any ContentMetadata = RDFMetadata(
        id: "http://www.w3.org/2002/07/owl#NamedIndividual",
        name: "NamedIndividual",
        label: "NamedIndividual",
        comment: "The class of named individuals."
    )

    public let localName: String
    public let content: Entities

    public init(_ localName: String, @ContentBuilder _ content: () -> Entities) {
        self.localName = localName
        self.content = content()
    }
}
