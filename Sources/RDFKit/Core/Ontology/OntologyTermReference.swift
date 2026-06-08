import Foundation

/// A term reference stored inside authored ontology content.
public struct OntologyTermReference: Equatable, Hashable, Sendable {
    let reference: Reference

    /// Creates a term reference from a local name.
    public init(_ localName: String) {
        self.reference = .localName(LocalName(localName))
    }

    /// Creates a term reference from an IRI-backed value.
    public init<TermValue: IRIRepresentable>(_ term: TermValue) {
        self.reference = .term(TermReference(term))
    }

    /// Creates a term reference from authored content.
    public init<TermType: Content>(_ term: TermType.Type) {
        self.reference = .symbolicType(String(describing: TermType.self))
    }

    /// A stored term reference form.
    enum Reference: Equatable, Hashable, Sendable {
        /// An explicitly IRI-backed term reference.
        case term(TermReference)

        /// A local name.
        case localName(LocalName)

        /// A symbolic Swift metatype reference used by declaration content.
        case symbolicType(String)
    }
}
