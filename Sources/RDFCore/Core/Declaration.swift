/// A declaration form of the DSL: `Class("Animal") { ... }`.
///
/// A declaration names a term inside its ontology and carries the term's
/// annotations as ``content``. The `@Ontology` macro reads declarations from
/// source and generates one Swift type per term. The local name is the
/// spelling of that generated type, never an identity: no IRI is built from it
/// at runtime. A declaration form is a ``ContentElement``, not an ``Entity``:
/// it has no term identity and no metadata. The term it declares is the
/// generated type, and the vocabulary's own classes (`rdfs:Class`,
/// `rdf:Property`, `rdfs:Datatype`, `owl:NamedIndividual`) are the types
/// generated from RDFS.swift, RDF.swift and OWL.swift.
///
/// Conforming types are the declaration forms themselves (``Class``,
/// ``Property``, ``Datatype``, ``Individual``). Inside an `@Ontology`
/// `content()` they are qualified as `RDFCore.Class` when the body is
/// expanded, so an ontology may declare a term of the same name (`RDFS.Class`).
public protocol Declaration: ContentElement {
    /// The name the term was declared with, the spelling of its generated type.
    var localName: String { get }

    /// The annotations and nested content of the declaration.
    var content: Content { get }

    /// Declares a term with its annotations.
    init(_ localName: String, @ContentBuilder _ content: () -> Content)
}

extension Declaration {
    /// Declares a term without annotations.
    public init(_ localName: String) {
        self.init(localName) {}
    }
}
