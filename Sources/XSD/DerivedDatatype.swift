/// An XML Schema datatype derived by restriction from another (§3.4): its
/// value space is the subset of its base's that its definition's facets
/// allow.
///
/// The hierarchy is the type system's: the translated definition of
/// `xsd:byte` declares `typealias Base = short`, and a literal of `xsd:byte`
/// is in the lexical space of `byte` when it satisfies the facets of every
/// definition from the primitive, `xsd:decimal`, down to `byte`.
public protocol DerivedDatatype: SimpleType where Base.Primitive == Primitive {
    /// The datatype this one is derived from by restriction.
    associatedtype Base: SimpleType
}

extension DerivedDatatype {
    /// The facets of the definitions from the primitive down to the base.
    static var baseConstraints: [Facet] { Base.constraints }
}
