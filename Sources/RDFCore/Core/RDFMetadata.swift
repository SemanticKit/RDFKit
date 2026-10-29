import IRIKit

/// The metadata the `@Ontology` macro generates for every term.
public struct RDFMetadata: ContentMetadata, Equatable, Hashable {
    public let id: IRI
    public let name: String
    public let label: String?
    public let comment: String?

    public init(id: IRI, name: String, label: String? = nil, comment: String? = nil) {
        self.id = id
        self.name = name
        self.label = label
        self.comment = comment
    }
}
