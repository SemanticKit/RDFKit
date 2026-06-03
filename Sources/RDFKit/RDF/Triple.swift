import Foundation

/// An RDF triple with subject, predicate, and object terms.
public protocol RDFTriple: Hashable, CustomStringConvertible, Sendable {
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

/// The default RDFKit triple value.
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
