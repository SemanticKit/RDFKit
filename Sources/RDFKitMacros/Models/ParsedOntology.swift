import Foundation

/// Parsed ontology data.

struct ParsedOntology {
    let namespace: String
    let prefixes: [ParsedEntity]
    let entities: [ParsedEntity]

    // MARK:
    let datatypes: [ParsedEntity]
    let individuals: [ParsedEntity]
    let properties: [ParsedEntity]

    init(
        namespace: String,
        prefixes: [ParsedEntity] = [],
        entities: [ParsedEntity] = [],
        datatypes: [ParsedEntity] = [],
        individuals: [ParsedEntity] = [],
        properties: [ParsedEntity] = []
    ) {
        self.namespace = namespace
        self.prefixes = prefixes
        self.entities = entities
        self.datatypes = datatypes
        self.individuals = individuals
        self.properties = properties
    }
}
