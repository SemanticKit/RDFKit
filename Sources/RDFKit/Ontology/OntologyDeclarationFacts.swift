import Foundation

/// Declaration facts authored in ontology DSL content.
public struct OntologyDeclarationFacts: Equatable, Hashable, Sendable, Codable {
    /// The rdf:type values.
    public internal(set) var types: Set<IRI> = []

    /// The rdfs:subClassOf values.
    public internal(set) var superclasses: Set<IRI> = []

    /// The rdfs:subPropertyOf values.
    public internal(set) var superproperties: Set<IRI> = []

    /// The rdfs:domain values.
    public internal(set) var domains: Set<IRI> = []

    /// The rdfs:range values.
    public internal(set) var ranges: Set<IRI> = []

    /// The rdfs:label values.
    public internal(set) var labels: Set<String> = []

    /// The rdfs:comment values.
    public internal(set) var comments: Set<String> = []

    /// The rdfs:seeAlso values.
    public internal(set) var seeAlso: Set<IRI> = []

    /// The rdfs:isDefinedBy values.
    public internal(set) var isDefinedBy: Set<IRI> = []

    /// The owl:deprecated value.
    public internal(set) var deprecated: Bool?

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
