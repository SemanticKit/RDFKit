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

public func == <Right: Term>(lhs: IRI, rhs: Right) -> Bool {
    lhs == rhs.iri
}

public func == <Left: Term>(lhs: Left, rhs: IRI) -> Bool {
    lhs.iri == rhs
}

public func == <Right: TypeIRIRepresentable>(lhs: IRI, rhs: Right.Type) -> Bool {
    lhs == rhs.iri
}

public func == <Left: TypeIRIRepresentable>(lhs: Left.Type, rhs: IRI) -> Bool {
    lhs.iri == rhs
}

public func == <Left: TypeIRIRepresentable, Right: Term>(lhs: Left.Type, rhs: Right) -> Bool {
    lhs.iri == rhs.iri
}

public func == <Left: Term, Right: TypeIRIRepresentable>(lhs: Left, rhs: Right.Type) -> Bool {
    lhs.iri == rhs.iri
}

public func == <Left: TypeIRIRepresentable, Right: TypeIRIRepresentable>(lhs: Left.Type, rhs: Right.Type) -> Bool {
    lhs.iri == rhs.iri
}
