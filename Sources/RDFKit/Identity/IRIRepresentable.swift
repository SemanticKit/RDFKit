import Foundation

/// A value or type that resolves to one RDF resource IRI.
public protocol IRIRepresentable {
    /// The RDF resource identity represented by this value.
    var iri: IRI { get }
}

/// A type whose identity is available without constructing a value.
public protocol TypeIRIRepresentable {
    /// The RDF resource identity represented by this type.
    static var iri: IRI { get }
}

public func == <Left: TypeIRIRepresentable, Right: IRIRepresentable>(lhs: Left.Type, rhs: Right) -> Bool {
    lhs.iri.rawValue == rhs.iri.rawValue
}

public func == <Left: IRIRepresentable, Right: TypeIRIRepresentable>(lhs: Left, rhs: Right.Type) -> Bool {
    lhs.iri.rawValue == rhs.iri.rawValue
}

public func == <Left: TypeIRIRepresentable, Right: TypeIRIRepresentable>(lhs: Left.Type, rhs: Right.Type) -> Bool {
    lhs.iri.rawValue == rhs.iri.rawValue
}

public func == <Left: IRIRepresentable, Right: IRIRepresentable>(lhs: Left, rhs: Right) -> Bool {
    lhs.iri.rawValue == rhs.iri.rawValue
}
