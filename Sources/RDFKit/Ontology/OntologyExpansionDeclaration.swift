import Foundation

/// One ontology declaration selected for expansion.
struct OntologyExpansionDeclaration: Equatable, Sendable {
    /// The declaration IRI.
    let iri: IRI

    /// The authored local name.
    let localName: LocalName

    /// The declaration role.
    let role: OntologyDeclarationRole

    /// Facts authored in the declaration body.
    let facts: OntologyDeclarationFacts
}
