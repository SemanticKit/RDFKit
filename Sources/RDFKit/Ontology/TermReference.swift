import Foundation

/// An IRI-backed reference to a term used inside ontology declaration content.
public struct TermReference: Content, IRIRepresentable, Identifiable, Equatable, Hashable, Sendable {
    private let value: IRI

    /// The referenced term IRI.
    public var iri: IRI { value }

    /// Creates a term reference from an IRI-backed value.
    public init<TermValue: IRIRepresentable>(_ term: TermValue) {
        self.value = term.iri
    }

    /// The term reference identity.
    public var id: IRI { iri }

    public static func == (lhs: TermReference, rhs: TermReference) -> Bool {
        lhs.iri.rawValue == rhs.iri.rawValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(iri)
    }
}
