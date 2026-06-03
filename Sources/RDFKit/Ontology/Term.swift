import Foundation

/// A declared ontology term with RDF identity.
public protocol Term: IRIRepresentable, Identifiable, RDFSubject, RDFObject where ID == IRI {}

extension Term {
    /// The term identity.
    public var id: IRI { iri }

    /// A stable textual representation.
    public var description: String { iri.description }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.iri == rhs.iri
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(iri)
    }
}

/// A declared ontology class.
public protocol Class: Term {}

/// A declared ontology property.
public protocol Property: Term, RDFPredicate {}

/// A declared ontology datatype.
public protocol Datatype: Term {}

/// A declared ontology individual.
public protocol Individual: Term {}
