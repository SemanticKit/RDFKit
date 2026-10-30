import IRIKit

/// Declares an RDF property. The `@Ontology` macro generates a term type for
/// it and a requirement on the protocol of its `Domain`, typed by its `Range`:
/// many values by default, at most one when the property is typed
/// `OWL.FunctionalProperty`.
///
/// `rdf:Property`
///
///     Property("hasHabitat") {
///         Domain(Fauna.Animal)
///         Range(Fauna.Habitat)
///     }
public struct Property: Declaration {
    public static let metadata: any ContentMetadata = RDFMetadata(
        id: "http://www.w3.org/1999/02/22-rdf-syntax-ns#Property",
        name: "Property",
        label: "Property",
        comment: "The class of RDF properties."
    )

    public let localName: String
    public let content: Entities

    public init(_ localName: String, @ContentBuilder _ content: () -> Entities) {
        self.localName = localName
        self.content = content()
    }
}
