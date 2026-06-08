import Foundation

/// A value that provides one RDF resource IRI.
public protocol IRIRepresentable {
    /// The RDF resource identity represented by this value.
    var iri: IRI { get }
}

/// Returns whether two IRI-backed values provide the same RDF resource IRI.
public func == <Left: IRIRepresentable, Right: IRIRepresentable>(lhs: Left, rhs: Right) -> Bool {
    lhs.iri.rawValue == rhs.iri.rawValue
}
