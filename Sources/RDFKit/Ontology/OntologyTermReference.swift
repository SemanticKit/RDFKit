import Foundation

/// A term reference resolved against an ontology environment.
public struct OntologyTermReference: Equatable, Hashable, Sendable {
    private let reference: Reference

    /// Creates a term reference from a local name in the enclosing ontology namespace.
    public init(_ localName: String) {
        self.reference = .localName(LocalName(localName))
    }

    /// Creates a term reference from an ontology-scoped value in the enclosing ontology namespace.
    public init<TermValue: OntologyScopedTerm>(_ term: TermValue) {
        self.reference = .localName(TermValue.localName)
    }

    /// Creates a term reference from an IRI-backed value.
    public init<TermValue: IRIRepresentable>(_ term: TermValue) {
        self.reference = .term(TermReference(term))
    }

    /// Creates a term reference from a vocabulary value.
    public init<VocabularyValue: Vocabulary>(_ vocabulary: VocabularyValue) {
        self.reference = .term(TermReference(vocabulary))
    }

    /// Creates a term reference from an IRI-backed type.
    public init<TermType: TypeIRIRepresentable>(_ term: TermType.Type) {
        self.reference = .term(TermReference(term))
    }

    /// Creates a term reference from an ontology-scoped type in the enclosing ontology namespace.
    public init<TermType: OntologyScopedTerm>(_ term: TermType.Type) {
        self.reference = .localName(TermType.localName)
    }

    /// Returns the referenced term IRI in an ontology environment.
    func iri(in environment: OntologyEnvironment) -> IRI {
        switch reference {
        case let .term(reference):
            reference.iri
        case let .localName(localName):
            QualifiedName(namespace: environment.namespace, localName: localName).iri
        }
    }

    /// A stored term reference.
    private enum Reference: Equatable, Hashable, Sendable {
        /// An explicitly IRI-backed term reference.
        case term(TermReference)

        /// A local name scoped to the enclosing ontology namespace.
        case localName(LocalName)
    }
}
