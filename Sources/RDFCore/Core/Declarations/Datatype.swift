import IRIKit

/// Declares an RDFS datatype. The `@Ontology` macro generates a value type for it.
///
/// `rdfs:Datatype`
///
///     Datatype("HTML") {
///         SubClassOf(RDFS.Literal)
///     }
public struct Datatype: Declaration {
    public static let metadata: any ContentMetadata = RDFMetadata(
        id: "http://www.w3.org/2000/01/rdf-schema#Datatype",
        name: "Datatype",
        label: "Datatype",
        comment: "The class of RDF datatypes."
    )

    public let localName: String
    public let content: Entities

    public init(_ localName: String, @ContentBuilder _ content: () -> Entities) {
        self.localName = localName
        self.content = content()
    }
}
