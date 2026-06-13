import Foundation
import IRIKit

/// An RDF triple with subject, predicate, and object components.
///
/// RDF 1.2 defines triples recursively: a triple may be used as the object of
/// another triple. Conforming to `Object` exposes that participation through
/// protocol conformance instead of a separate wrapper type.
public struct Triple<SubjectValue: Subject, ObjectValue: Object>: Object {
    public typealias Predicate = IRI

    /// The triple subject.
    public let subject: SubjectValue

    /// The triple predicate.
    public let predicate: IRI

    /// The triple object.
    public let object: ObjectValue

    /// Creates a triple.
    public init(subject: SubjectValue, predicate: IRI, object: ObjectValue) {
        self.subject = subject
        self.predicate = predicate
        self.object = object
    }
}
