/// Why a literal has no value of a datatype.
public enum DatatypeError: Error, Hashable, Sendable {
    /// The literal's datatype IRI is not the datatype's.
    case otherDatatype

    /// The lexical form is not in the datatype's lexical space: the
    /// literal is ill-typed (RDF 1.2 Concepts §3.4: "Otherwise, the literal
    /// is ill-typed and no literal value can be associated with the
    /// literal").
    case illTyped
}
