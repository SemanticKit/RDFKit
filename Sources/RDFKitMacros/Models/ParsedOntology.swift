/// An ontology's body as the macro reads it.
struct ParsedOntology {
    /// The namespace of the ontology's terms.
    let namespace: String
    /// The ontology's classes, in declaration order.
    let classes: [ParsedEntity]
}
