import Foundation

public extension RDF {
    /// The RDF vocabulary expressed as protocol-first ontology DSL content.
    static var ontology: StandardVocabularyOntology<AliasGroup> {
        StandardVocabularyOntology(vocabulary: "RDF", namespace: namespace) {
            Alias("rdf", namespace)
            Alias("rdfs", RDFS.namespace)
            Alias("owl", OWL.namespace)
        }
    }

    /// Matrix-backed ontology content for the RDF vocabulary.
    static var content: StandardVocabularyContent {
        ontology.content
    }
}
