import Foundation

public extension RDFS {
    /// The RDFS vocabulary expressed as protocol-first ontology DSL content.
    static var ontology: StandardVocabularyOntology<AliasGroup> {
        StandardVocabularyOntology(vocabulary: "RDFS", namespace: namespace) {
            Alias("rdf", RDF.namespace)
            Alias("rdfs", namespace)
            Alias("owl", OWL.namespace)
        }
    }

    /// Matrix-backed ontology content for the RDFS vocabulary.
    static var content: StandardVocabularyContent {
        ontology.content
    }
}
