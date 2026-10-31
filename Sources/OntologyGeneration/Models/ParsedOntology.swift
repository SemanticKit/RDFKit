/// An ontology's body as the macro reads it.
public struct ParsedOntology {
    /// The name of the ontology's Swift type, `RDF` in `struct RDF: Ontology`.
    public let name: String
    /// The namespace of the ontology's terms.
    public let namespace: String
    /// The ontology's classes, in declaration order.
    public let classes: [ParsedEntity]
    /// The ontology's properties, in declaration order.
    public let properties: [ParsedEntity]

    public init(name: String, namespace: String, classes: [ParsedEntity], properties: [ParsedEntity]) {
        self.name = name
        self.namespace = namespace
        self.classes = classes
        self.properties = properties
    }
}
