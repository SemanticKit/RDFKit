import Foundation

/// Resolves declaration facts authored in ontology DSL content.
enum ContentFactResolver {
    /// Returns declaration facts keyed by declaration IRI.
    static func facts<ContentValue: Content>(in content: ContentValue) -> [IRI: OntologyDeclarationFacts] {
        let environment = ContentNamespaceResolver.environment(in: content)
        var facts: [IRI: OntologyDeclarationFacts] = [:]
        collect(in: content, environment: environment, facts: &facts)
        return facts
    }

    private static func collect(in content: any Content, environment: OntologyEnvironment, facts: inout [IRI: OntologyDeclarationFacts]) {
        if let declaration = content as? any NamespaceScopedDeclaration {
            let iri = declaration.iri(in: environment)
            facts[iri] = declarationFacts(in: declaration.bodyContent, environment: environment)
        }
        if let environmentContent = content as? any EnvironmentResolvedContent {
            collect(in: environmentContent.resolve(in: environment), environment: environment, facts: &facts)
        }
        if let group = content as? ContentGroup {
            for element in group.elements {
                collect(in: element, environment: environment, facts: &facts)
            }
        }
    }

    /// Returns declaration facts authored directly in declaration body content.
    static func declarationFacts(in content: any Content, environment: OntologyEnvironment) -> OntologyDeclarationFacts {
        var facts = OntologyDeclarationFacts()
        collectFacts(in: content, environment: environment, facts: &facts)
        return facts
    }

    private static func collectFacts(in content: any Content, environment: OntologyEnvironment, facts: inout OntologyDeclarationFacts) {
        if let factContent = content as? any OntologyFactContent {
            factContent.addFacts(to: &facts)
        }
        if let environmentContent = content as? any EnvironmentResolvedContent {
            collectFacts(in: environmentContent.resolve(in: environment), environment: environment, facts: &facts)
        }
        if let group = content as? ContentGroup {
            for element in group.elements {
                collectFacts(in: element, environment: environment, facts: &facts)
            }
        }
    }
}

/// Declaration facts authored in ontology DSL content.
struct OntologyDeclarationFacts: Equatable, Sendable {
    /// The rdf:type values.
    var types: Set<IRI> = []

    /// The rdfs:subClassOf values.
    var superclasses: Set<IRI> = []

    /// The rdfs:subPropertyOf values.
    var superproperties: Set<IRI> = []

    /// The rdfs:domain values.
    var domains: Set<IRI> = []

    /// The rdfs:range values.
    var ranges: Set<IRI> = []

    /// The rdfs:label values.
    var labels: Set<String> = []

    /// The rdfs:comment values.
    var comments: Set<String> = []

    /// The rdfs:seeAlso values.
    var seeAlso: Set<IRI> = []

    /// The rdfs:isDefinedBy values.
    var isDefinedBy: Set<IRI> = []

    /// The owl:deprecated value.
    var deprecated: Bool?
}
