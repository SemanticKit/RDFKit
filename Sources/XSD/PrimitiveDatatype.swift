import RDFCore

/// A primitive XML Schema datatype (§3.3): one whose value space and
/// lexical mapping the specification defines directly, not by restricting
/// another datatype.
public protocol PrimitiveDatatype: SimpleType where Primitive == Self {
    /// The value space.
    associatedtype Value: FacetMeasurable

    /// The lexical mapping of the primitive, for a literal in its lexical
    /// space.
    ///
    /// - Throws: ``RDFCore/DatatypeError/illTyped`` for any other literal.
    static func lexicalMapping(_ lexicalForm: String) throws(DatatypeError) -> Value

    /// The lexical representations of a value, its canonical
    /// representation (the canonical mapping) first.
    static func representations(of value: Value) -> [String]
}
