import IRIKit

/// Declares a named individual.
///
/// `owl:NamedIndividual`
///
///     Individual("nil") {
///         Type<RDF.List>()
///     }
public struct Individual: Declaration {
    public static let metadata: any ContentMetadata = RDFMetadata(
        id: "http://www.w3.org/2002/07/owl#NamedIndividual",
        name: "NamedIndividual",
        label: "NamedIndividual",
        comment: "The class of named individuals."
    )

    public let localName: String
    public let content: Content

    public init(_ localName: String, @ContentBuilder _ content: () -> Content) {
        self.localName = localName
        self.content = content()
    }
}
