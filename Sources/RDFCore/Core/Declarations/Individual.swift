import IRIKit

/// Declares a named individual. The `@Ontology` macro generates a static
/// constant of the ontology for it, the one instance of a final class that
/// conforms to the protocols of its classes: `Individual("nil")` becomes
/// `RDF.nil`.
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
