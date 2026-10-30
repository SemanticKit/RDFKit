/// An ontology read from the `var body` of an `@Ontology` struct.
struct ParsedOntology {
    /// The name of the struct the macro is attached to, such as `Fauna`.
    let typeName: String

    /// The namespace from `Namespace("...")`, as written.
    let namespace: String

    /// Every declaration, in source order.
    let declarations: [ParsedEntity]

    var properties: [ParsedEntity] {
        declarations.filter { $0.kind == .property }
    }

    /// The first declaration of a term with this local name.
    func declaration(named name: String) -> ParsedEntity? {
        declarations.first { $0.name == name }
    }
}
