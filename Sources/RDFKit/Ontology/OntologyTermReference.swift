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
        self.reference = .ontologyScoped(OntologyScopedReference(TermValue.self))
    }

    /// Creates a term reference from an IRI-backed value.
    public init<TermValue: IRIRepresentable>(_ term: TermValue) {
        self.reference = .term(TermReference(term))
    }

    /// Creates a term reference from an IRI-backed type.
    public init<TermType: TypeIRIRepresentable>(_ term: TermType.Type) {
        self.reference = .term(TermReference(term))
    }

    /// Creates a term reference from an ontology-scoped type in the enclosing ontology namespace.
    public init<TermType: OntologyScopedTerm>(_ term: TermType.Type) {
        self.reference = .ontologyScoped(OntologyScopedReference(TermType.self))
    }

    /// Returns the referenced term IRI in an ontology environment.
    func iri(in environment: OntologyEnvironment) -> IRI {
        switch reference {
        case let .term(reference):
            reference.iri
        case let .localName(localName):
            QualifiedName(namespace: environment.namespace, localName: localName).iri
        case let .ontologyScoped(reference):
            reference.iri(in: environment)
        }
    }

    /// A stored term reference.
    private enum Reference: Equatable, Hashable, Sendable {
        /// An explicitly IRI-backed term reference.
        case term(TermReference)

        /// A local name scoped to the enclosing ontology namespace.
        case localName(LocalName)

        /// An ontology-scoped term reference.
        case ontologyScoped(OntologyScopedReference)
    }
}

/// An ontology-scoped term reference that can resolve locally for its owning ontology.
private struct OntologyScopedReference: Equatable, Hashable, Sendable {
    /// The referenced term local name.
    let localName: LocalName

    /// The ontology type that owns the referenced term.
    let ownerTypeName: String

    /// Resolves the referenced term against its own ontology.
    let resolvedIRI: @Sendable () -> IRI

    /// Creates an ontology-scoped reference for a term type.
    init<TermType: OntologyScopedTerm>(_ term: TermType.Type) {
        self.localName = TermType.localName
        self.ownerTypeName = String(describing: TermType.OntologyValue.self)
        self.resolvedIRI = { TermType.iri }
    }

    /// Returns this reference in an ontology environment.
    func iri(in environment: OntologyEnvironment) -> IRI {
        if environment.ownerTypeName == nil || environment.ownerTypeName == ownerTypeName {
            return QualifiedName(namespace: environment.namespace, localName: localName).iri
        }

        return resolvedIRI()
    }

    static func == (lhs: OntologyScopedReference, rhs: OntologyScopedReference) -> Bool {
        lhs.localName == rhs.localName && lhs.ownerTypeName == rhs.ownerTypeName
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(localName)
        hasher.combine(ownerTypeName)
    }
}
