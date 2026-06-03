import Foundation

/// A declaration materialized from ontology DSL content.
public struct OntologyDeclaration: Identifiable, Equatable, Hashable, Sendable, Codable, Comparable, CustomStringConvertible {
    /// The declaration IRI.
    public let iri: IRI

    /// The authored local name.
    public let localName: LocalName

    /// The declaration role.
    public let role: OntologyDeclarationRole

    /// Facts authored in the declaration body.
    public let facts: OntologyDeclarationFacts

    /// Creates a materialized ontology declaration.
    public init(iri: IRI, localName: LocalName, role: OntologyDeclarationRole, facts: OntologyDeclarationFacts) {
        self.iri = iri
        self.localName = localName
        self.role = role
        self.facts = facts
    }

    /// The declaration identity.
    public var id: IRI { iri }

    /// A stable textual representation.
    public var description: String { "\(role): \(iri)" }

    public static func < (lhs: OntologyDeclaration, rhs: OntologyDeclaration) -> Bool {
        lhs.iri < rhs.iri
    }
}
