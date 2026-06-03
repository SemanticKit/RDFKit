import Foundation

public extension OWL {
    /// The OWL vocabulary expressed as protocol-first ontology DSL content.
    static var ontology: StandardVocabularyOntology<AliasGroup> {
        StandardVocabularyOntology(vocabulary: "OWL", namespace: namespace) {
            Alias("rdf", RDF.namespace)
            Alias("rdfs", RDFS.namespace)
            Alias("owl", namespace)
        }
    }

    /// Matrix-backed ontology content for the OWL vocabulary.
    static var content: StandardVocabularyContent {
        ontology.content
    }
}
