import Foundation
import IRIKit

/// An RDF triple.
///
/// RDF 1.2 Concepts §3.1 Triples: "An RDF triple (often simply called
/// triple) is a 3-tuple that consists of three components: The subject, which
/// is an IRI or a blank node; The predicate, which is an IRI; The object, which
/// is an IRI, a blank node, a literal, or an RDF triple."
///
/// A triple is also a triple term (§3.6): "A triple term is an RDF triple
/// used as an RDF term within another triple." The triples of a ``Graph`` are
/// `Triple<SubjectTerm, ObjectTerm>`, ``Graph/Element``.
public struct Triple<SubjectValue: Subject, ObjectValue: Object>: TripleTerm, Sendable {
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

extension Triple: Equatable where SubjectValue: Equatable, ObjectValue: Equatable {}

extension Triple: Hashable where SubjectValue: Hashable, ObjectValue: Hashable {}

extension Triple: CustomStringConvertible where SubjectValue: CustomStringConvertible, ObjectValue: CustomStringConvertible {
    /// The triple as an N-Triples line writes it, without escaping.
    public var description: String { "\(subject) <\(predicate)> \(object) ." }
}

extension Triple where SubjectValue == SubjectTerm, ObjectValue == ObjectTerm {
    /// The blank nodes in the triple, in the order they occur: the
    /// subject's, then the object's, a node that occurs twice listed twice.
    public var blankNodes: [BlankNode] {
        subject.blankNodes + object.blankNodes
    }

    /// The same triple, each blank node in it replaced by the node `mapping`
    /// gives it. A blank node `mapping` does not name stays as it is.
    public func replacingBlankNodes(_ mapping: [BlankNode: BlankNode]) -> Triple {
        Triple(subject: subject.replacingBlankNodes(mapping), predicate: predicate, object: object.replacingBlankNodes(mapping))
    }
}
