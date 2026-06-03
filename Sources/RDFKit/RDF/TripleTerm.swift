import Foundation

/// An RDF triple term that can appear as the object of another triple.
public struct TripleTerm: RDFObject, Equatable, Hashable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    /// The embedded triple subject.
    public let subject: AnyRDFSubject

    /// The embedded triple predicate.
    public let predicate: IRI

    /// The embedded triple object.
    public let object: AnyRDFObject

    /// Creates a triple term.
    public init(subject: AnyRDFSubject, predicate: IRI, object: AnyRDFObject) {
        self.subject = subject
        self.predicate = predicate
        self.object = object
    }

    /// Creates a triple term with an IRI-backed predicate.
    public init<Predicate: IRIRepresentable>(subject: AnyRDFSubject, predicate: Predicate, object: AnyRDFObject) {
        self.subject = subject
        self.predicate = predicate.iri
        self.object = object
    }

    /// A stable textual representation.
    public var description: String { "<<\(subject) \(predicate) \(object)>>" }

    /// A debugging representation that includes the type name.
    public var debugDescription: String {
        "TripleTerm(subject: \(subject), predicate: \(predicate), object: \(object))"
    }
}
