import Foundation

/// A declared ontology term with RDF identity.
public protocol Term: IRIRepresentable, Identifiable, Subject, Object where ID == IRI {}

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
