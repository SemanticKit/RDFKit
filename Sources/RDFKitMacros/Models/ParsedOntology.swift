/// An ontology's body as the macro reads it.
struct ParsedOntology {
    /// The name of the ontology's Swift type, `RDF` in `struct RDF: Ontology`.
    let name: String
    /// The namespace of the ontology's terms.
    let namespace: String
    /// The ontology's classes, in declaration order.
    let classes: [ParsedEntity]
    /// The ontology's properties, in declaration order.
    let properties: [ParsedEntity]
}
