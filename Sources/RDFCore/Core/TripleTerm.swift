import IRIKit

/// A triple term.
///
/// RDF 1.2 Concepts §3.6 Triple Terms: "A triple term is an RDF triple used as
/// an RDF term within another triple." ``Triple`` conforms: a triple term is a
/// triple.
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
