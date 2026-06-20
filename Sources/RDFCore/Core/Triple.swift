import Foundation
import IRIKit

/// An RDF triple.
///
/// RDF 1.2 Concepts §3.1 Triples: "An RDF triple (often simply called
/// triple) is a 3-tuple that consists of three components: The subject, which
/// is an IRI or a blank node; The predicate, which is an IRI; The object, which
/// is an IRI, a blank node, a literal, or an RDF triple."
public struct Triple<SubjectValue: Subject, ObjectValue: Object>: Sendable {
    public typealias Predicate = IRI

    /// The subject component.
    public let subject: SubjectValue

    /// The predicate component.
    public let predicate: IRI

    /// The object component.
    public let object: ObjectValue

    /// Creates a triple.
    public init(subject: SubjectValue, predicate: IRI, object: ObjectValue) {
        self.subject = subject
        self.predicate = predicate
        self.object = object
    }
}

/// A triple term.
///
/// RDF 1.2 Concepts §3.6 Triple Terms: "A triple term is an RDF triple used as
/// an RDF term within another triple."
public protocol TripleTerm: Object {
    associatedtype SubjectValue: Subject
    associatedtype ObjectValue: Object

    /// The subject component.
    var subject: SubjectValue { get }

    /// The predicate component.
    var predicate: IRI { get }

    /// The object component.
    var object: ObjectValue { get }
}
