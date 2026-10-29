import IRIKit

/// An ontology entity declared in the DSL.
///
/// The Swift type is the entity's identity inside the runtime. Types refer to
/// each other as types, never through an IRI or a string. The entity's IRI
/// lives only in ``metadata``, a static projection that the `@Ontology` macro
/// computes from the ontology's namespace and that is read only at the
/// boundary (serialization, translation into SPARQL or SHACL, dereferencing).
public protocol Entity: Node, ContentElement {
    /// The boundary projection of this entity: its IRI and documentation.
    static var metadata: any ContentMetadata { get }
}
