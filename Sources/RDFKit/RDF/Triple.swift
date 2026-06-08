import Foundation

/// An RDF triple with subject, predicate, and object components.
///
/// RDF 1.2 defines triples recursively: a triple may be used as the object of
/// another triple. Conforming to `RDFObject` exposes that participation through
/// protocol conformance instead of a separate wrapper type.
public protocol RDFTriple: RDFObject {
    associatedtype Subject: RDFSubject
    associatedtype Predicate: RDFPredicate
    associatedtype Object: RDFObject

    /// The triple subject.
    var subject: Subject { get }

    /// The triple predicate.
    var predicate: Predicate { get }

    /// The triple object.
    var object: Object { get }
}

extension RDFTriple {
    /// A stable textual representation.
    public var description: String {
        "\(subject) \(predicate) \(object) ."
    }
}

/// A concrete RDF triple value.
///
/// Use this value when the caller needs a stored triple. APIs that only need
/// triple behavior should constrain on `RDFTriple`.
public struct Triple<Subject: RDFSubject, Object: RDFObject>: RDFTriple {
    public typealias Predicate = IRI

    /// The triple subject.
    public let subject: Subject

    /// The triple predicate.
    public let predicate: IRI

    /// The triple object.
    public let object: Object

    /// Creates a triple.
    public init(subject: Subject, predicate: IRI, object: Object) {
        self.subject = subject
        self.predicate = predicate
        self.object = object
    }

    /// Creates a triple with an IRI-backed predicate.
    public init<Predicate: IRIRepresentable>(subject: Subject, predicate: Predicate, object: Object) {
        self.subject = subject
        self.predicate = predicate.iri
        self.object = object
    }
}
