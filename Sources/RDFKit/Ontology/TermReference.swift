import Foundation

/// An IRI-backed reference to a term used inside ontology declaration content.
public struct TermReference: Content, IRIRepresentable, Identifiable, Equatable, Hashable, Sendable {
    private let reference: any IRIReference

    /// The referenced term IRI.
    public var iri: IRI { reference.iri }

    /// Creates a term reference from an IRI-backed value.
    public init<TermValue: IRIRepresentable>(_ term: TermValue) {
        self.reference = ValueIRIReference(iri: term.iri)
    }

    /// Creates a term reference from an IRI-backed type.
    public init<TermType: TypeIRIRepresentable>(_ term: TermType.Type) {
        self.reference = TypeIRIReference<TermType>()
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

/// A protocol-backed IRI reference used by ontology declaration content.
protocol IRIReference: Sendable {
    /// The referenced RDF resource identity.
    var iri: IRI { get }
}

/// A concrete IRI value reference.
struct ValueIRIReference: IRIReference {
    /// The referenced RDF resource identity.
    let iri: IRI
}

/// A type-level IRI reference.
struct TypeIRIReference<TermType: TypeIRIRepresentable>: IRIReference {
    /// Creates a type-level IRI reference.
    init() {}

    /// The referenced RDF resource identity.
    var iri: IRI { TermType.iri }
}
