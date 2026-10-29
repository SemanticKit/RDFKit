import IRIKit

/// Declares an RDFS class. The `@Ontology` macro generates a Swift type for it.
///
/// `rdfs:Class`
///
///     Class("Animal") {
///         Type(RDFS.Class)
///         Label("Animal")
///     }
public struct Class: Declaration {
    public static let metadata: any ContentMetadata = RDFMetadata(
        id: "http://www.w3.org/2000/01/rdf-schema#Class",
        name: "Class",
        label: "Class",
        comment: "The class of classes."
    )

    public let localName: String
    public let content: Content

    public init(_ localName: String, @ContentBuilder _ content: () -> Content) {
        self.localName = localName
        self.content = content()
    }
}
