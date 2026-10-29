import IRIKit
import RDFCore

/// A decoded triple term.
///
/// RDF 1.2 Concepts §3.6 Triple Terms: "A triple term is an RDF triple used as
/// an RDF term within another triple." Triple terms appear only in object
/// position.
public struct TripleTermValue: TripleTerm, Hashable, Sendable {
    /// The subject component.
    public let subject: SubjectTerm

    /// The predicate component.
    public let predicate: IRI

    /// The object component.
    public let object: ObjectTerm

    /// Creates a triple term.
    public init(subject: SubjectTerm, predicate: IRI, object: ObjectTerm) {
        self.subject = subject
        self.predicate = predicate
        self.object = object
    }
}
