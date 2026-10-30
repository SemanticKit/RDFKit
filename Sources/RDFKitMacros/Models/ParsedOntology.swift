/// An ontology read from the `var body` of an `@Ontology` struct.
struct ParsedOntology {
    /// A declaration of a term that an earlier declaration of the same name
    /// gave another form: `Property("name")` after `Class("name")`.
    struct Redeclaration {
        /// The later declaration, where the diagnostic points.
        let declaration: ParsedEntity
        /// The form the term was first declared with.
        let firstKind: ParsedEntity.Kind
    }

    /// The name of the struct the macro is attached to, such as `Fauna`.
    let typeName: String

    /// The access modifier, with a trailing space, that the ontology struct
    /// is declared with when it is `public` or `package`, and empty
    /// otherwise: members of an extension cannot be more visible than the
    /// ontology's types they use.
    let access: String

    /// The namespace from `Namespace("...")`, as written.
    let namespace: String

    /// One declaration per declared term, in the source order of each
    /// term's first declaration. Every declaration of a term with the same
    /// form is merged into it, so it holds all their annotations.
    let declarations: [ParsedEntity]

    /// Declarations of a term already declared with another form, which
    /// are reported and generate nothing.
    let redeclarations: [Redeclaration]

    var properties: [ParsedEntity] {
        declarations.filter { $0.kind == .property }
    }

    /// The declaration of the term with this local name.
    func declaration(named name: String) -> ParsedEntity? {
        declarations.first { $0.name == name }
    }
}
