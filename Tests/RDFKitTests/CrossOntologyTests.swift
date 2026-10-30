import Testing
import RDFCore
import RDFKit

/// A class with a property in its domain, declared in one ontology.
@Ontology
struct ServiceDescription: Ontology {
    var body: some Content {
        Namespace("http://www.w3.org/ns/sparql-service-description#")
        Class("EntailmentRegime") {
            Type(RDFS.Class)
            Label("Entailment Regime")
        }
        Property("name") {
            Domain(ServiceDescription.EntailmentRegime)
            Range(RDFS.Literal)
        }
    }
}

/// A named individual typed with that class, declared in another ontology.
@Ontology
struct Entailment: Ontology {
    var body: some Content {
        Namespace("http://www.w3.org/ns/entailment/")
        Individual("RDFS") {
            Type(ServiceDescription.EntailmentRegime)
            Label("RDFS entailment")
        }
    }
}

@Suite("An individual typed with another ontology's class", .tags(.ontology, .generated))
struct CrossOntologyTests {
    @Test("is an instance of that class and stores its properties")
    func storesTheForeignClassesProperties() {
        let regime: any ServiceDescription.EntailmentRegime = Entailment.RDFS
        #expect(regime.name.isEmpty)
        regime.name = ["RDFS"]
        #expect(Entailment.RDFS.name == ["RDFS"])
    }
}
