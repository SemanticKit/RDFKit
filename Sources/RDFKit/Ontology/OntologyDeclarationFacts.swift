import Foundation

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

    /// Creates empty declaration facts.
    init() {}

    /// Creates declaration facts from declaration body content.
    init(content: any Content, environment: OntologyEnvironment) {
        self.init()
        addFacts(in: content, environment: environment)
    }

    /// Adds facts authored in declaration body content.
    mutating func addFacts(in content: any Content, environment: OntologyEnvironment) {
        if let factContent = content as? any OntologyFactContent {
            factContent.addFacts(to: &self, in: environment)
        }
    }
}
