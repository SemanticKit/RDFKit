import IRIKit

/// A type that can be constructed from an IRI.
///
/// Conforming types can be created from a bare IRI, allowing circular
/// references between ontologies to resolve via IRI identity rather than
/// direct type references. At any boundary, a term collapses to its IRI
/// (via `Identifiable.id`) and can be reconstructed from it via this protocol.
///
/// `IRI` itself is a simple data type and does not conform to this protocol.
public protocol IRIConvertible {
    init(_ iri: IRI)
}

/// A type identified by an IRI, via `Identifiable`.
///
/// Like `Identifiable`, but constrains `ID` to `IRI`. No extra `iri`
/// property — `id` IS the IRI. Term identity is RDF IRI identity, and this
/// protocol makes that constraint explicit in the type system.
///
/// `IRI` itself is a simple data type and does not conform to this protocol;
/// it is the primitive that other types are identified *by*.
public protocol IRIIdentifiable: Identifiable, Equatable where ID == IRI {}

// MARK: - Cross-type equality by IRI identity

/// Two IRI-identified types are equal if their IRIs match, regardless of
/// Swift type.
///
///     RDFS.Class == RDF.Property  // false — different IRIs
///
/// When both operands share a concrete type, Swift prefers the type's own
/// `Equatable.==`. This operator only participates in cross-type comparisons
/// through existentials.
public func == (lhs: any IRIIdentifiable, rhs: any IRIIdentifiable) -> Bool {
    lhs.id == rhs.id
}

public func != (lhs: any IRIIdentifiable, rhs: any IRIIdentifiable) -> Bool {
    lhs.id != rhs.id
}

/// A term is equal to a bare IRI if their identities match.
///
///     RDFS.Class == IRI("http://www.w3.org/2000/01/rdf-schema#Class")  // true
public func == (lhs: any IRIIdentifiable, rhs: IRI) -> Bool {
    lhs.id == rhs
}

public func == (lhs: IRI, rhs: any IRIIdentifiable) -> Bool {
    lhs == rhs.id
}

public func != (lhs: any IRIIdentifiable, rhs: IRI) -> Bool {
    lhs.id != rhs
}

public func != (lhs: IRI, rhs: any IRIIdentifiable) -> Bool {
    lhs != rhs.id
}
