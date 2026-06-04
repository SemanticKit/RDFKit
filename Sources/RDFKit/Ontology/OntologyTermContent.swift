import Foundation

/// Ontology DSL content that contributes term identities.
protocol OntologyTermContent: Content {
    /// Returns the term IRIs contributed by this content.
    func termIRIs(in environment: OntologyEnvironment, role: OntologyDeclarationRole?) throws -> [IRI]
}

extension Content {
    /// Returns term IRIs contributed by term content and direct term-role values.
    func materializedTermIRIs(in environment: OntologyEnvironment, role: OntologyDeclarationRole?) throws -> [IRI] {
        var collected: [IRI] = []
        var foundRoleTerm = false

        if let termContent = self as? any OntologyTermContent {
            collected.append(contentsOf: try termContent.termIRIs(in: environment, role: role))
        }
        if let term = self as? any RDFClass, role == nil || role == .class {
            collected.append(term.iri)
            foundRoleTerm = true
        }
        if let term = self as? any RDFProperty, role == nil || role == .property {
            collected.append(term.iri)
            foundRoleTerm = true
        }
        if let term = self as? any RDFDatatype, role == nil || role == .datatype {
            collected.append(term.iri)
            foundRoleTerm = true
        }
        if let term = self as? any RDFIndividual, role == nil || role == .individual {
            collected.append(term.iri)
            foundRoleTerm = true
        }
        if let term = self as? any Term, role == nil, !foundRoleTerm {
            collected.append(term.iri)
        }

        return collected
    }
}
