/// A declaration form of the DSL: `Class("Animal") { ... }`.
///
/// A declaration names a term inside its ontology and carries the term's
/// annotations as ``content``. The `@Ontology` macro reads declarations from
/// source and generates one Swift type per term. The local name is the
/// spelling of that generated type, never an identity: no IRI is built from it
/// at runtime.
///
/// Conforming types are the declaration forms themselves (``Class``,
/// ``Property``, ``Datatype``, ``Individual``). Inside an `@Ontology`
/// `var body` they are qualified as `RDFCore.Class` when the body is
/// expanded, so an ontology may declare a term of the same name (`RDFS.Class`).
public protocol Declaration: Entity {
    /// The name the term was declared with, the spelling of its generated type.
    var localName: String { get }

    /// The annotations and nested content of the declaration.
    var content: Entities { get }

    /// Declares a term with its annotations.
    init(_ localName: String, @ContentBuilder _ content: () -> Entities)
}

extension Declaration {
    /// Declares a term without annotations.
    public init(_ localName: String) {
        self.init(localName) {}
    }
}
