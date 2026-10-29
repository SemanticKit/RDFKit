/// An ontology read from the `content` of an `@Ontology` struct.
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

    /// Whether this ontology declares a class or datatype with this local name.
    func declaresType(named name: String) -> Bool {
        declarations.contains { ($0.kind == .class || $0.kind == .datatype) && $0.name == name }
    }
}
