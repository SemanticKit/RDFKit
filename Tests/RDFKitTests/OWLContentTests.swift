import Testing
@testable import RDFKit
@testable import IRIKit

@Suite struct OWLContentTests {
    private struct OWLOntology: Ontology {
        var content: some Content {
//            Namespace("http://www.w3.org/2002/07/owl#")
            Prefix("rdf", "http://www.w3.org/1999/02/22-rdf-syntax-ns#")
            Prefix("rdfs", "http://www.w3.org/2000/01/rdf-schema#")
            Prefix("owl", "http://www.w3.org/2002/07/owl#")

            Class("Thing") {
                Type(OWL.Class)
                Label("Thing")
                Comment("The class of OWL individuals.")
            }

            Class("Restriction") {
                Type(RDFS.Class)
                SubClassOf(OWL.Class)
                Label("Restriction")
                Comment("The class of property restrictions.")
            }

            Property("allValuesFrom") {
                Type(RDF.Property)
                Domain(OWL.Restriction)
                Range(RDFS.Class)
                Label("allValuesFrom")
                Comment("The property that determines the class that a universal property restriction refers to.")
            }

            Property("backwardCompatibleWith") {
                Type(OWL.AnnotationProperty)
                Type(OWL.OntologyProperty)
                Domain(OWL.Ontology)
                Range(OWL.Ontology)
                Label("backwardCompatibleWith")
                Comment("The annotation property that indicates that a given ontology is backward compatible with another ontology.")
            }

            Property("cardinality") {
                Type(RDF.Property)
                Domain(OWL.Restriction)
                Range(IRI("http://www.w3.org/2001/XMLSchema#nonNegativeInteger"))
                Label("cardinality")
                Comment("The property that determines the cardinality of an exact cardinality restriction.")
            }

            Property("hasKey") {
                Type(RDF.Property)
                Domain(OWL.Class)
                Range(RDF.List)
                Label("hasKey")
                Comment("The property that determines the collection of properties that jointly build a key.")
            }

            Property("inverseOf") {
                Type(RDF.Property)
                Domain(OWL.ObjectProperty)
                Range(OWL.ObjectProperty)
                Label("inverseOf")
                Comment("The property that determines that two given properties are inverse.")
            }

            Property("sourceIndividual") {
                Type(RDF.Property)
                Domain(OWL.NegativePropertyAssertion)
                Range(OWL.Thing)
                Label("sourceIndividual")
                Comment("The property that determines the subject of a negative property assertion.")
            }

            Property("topDataProperty") {
                Type(OWL.DatatypeProperty)
                Domain(OWL.Thing)
                Range(RDFS.Literal)
                Label("topDataProperty")
                Comment("The data property that relates every individual to every data value.")
            }
        }
    }

    @Test func owlOntologyConstructsAuthoredContent() {
        let ontology = OWLOntology()

        print(ontology.content)
    }

    @Test func owlRootClassDeclarationConstructsAuthoredContent() {
        let content = Class("Thing") {
            Type(OWL.Class)
            Label("Thing")
            Comment("The class of OWL individuals.")
        }

        print(content)
    }

    @Test func owlRestrictionClassDeclarationConstructsAuthoredContent() {
        let content = Class("Restriction") {
            Type(RDFS.Class)
            SubClassOf(OWL.Class)
            Label("Restriction")
            Comment("The class of property restrictions.")
        }

        print(content)
    }

    @Test func owlPropertyDeclarationConstructsAuthoredContent() {
        let content = Property("allValuesFrom") {
            Type(RDF.Property)
            Domain(OWL.Restriction)
            Range(RDFS.Class)
            Label("allValuesFrom")
            Comment("The property that determines the class that a universal property restriction refers to.")
        }

        print(content)
    }

    @Test func owlPropertyDeclarationConstructsAuthoredContentWithMultipleTypes() {
        let content = Property("backwardCompatibleWith") {
            Type(OWL.AnnotationProperty)
            Type(OWL.OntologyProperty)
            Domain(OWL.Ontology)
            Range(OWL.Ontology)
            Label("backwardCompatibleWith")
            Comment("The annotation property that indicates that a given ontology is backward compatible with another ontology.")
        }

        print(content)
    }

    @Test func owlPropertyDeclarationConstructsAuthoredContentWithIRIRange() {
        let content = Property("cardinality") {
            Type(RDF.Property)
            Domain(OWL.Restriction)
            Range(IRI("http://www.w3.org/2001/XMLSchema#nonNegativeInteger"))
            Label("cardinality")
            Comment("The property that determines the cardinality of an exact cardinality restriction.")
        }

        print(content)
    }

    @Test func owlListValuedPropertyDeclarationConstructsAuthoredContent() {
        let content = Property("hasKey") {
            Type(RDF.Property)
            Domain(OWL.Class)
            Range(RDF.List)
            Label("hasKey")
            Comment("The property that determines the collection of properties that jointly build a key.")
        }

        print(content)
    }

    @Test func owlObjectPropertyDeclarationConstructsAuthoredContent() {
        let content = Property("inverseOf") {
            Type(RDF.Property)
            Domain(OWL.ObjectProperty)
            Range(OWL.ObjectProperty)
            Label("inverseOf")
            Comment("The property that determines that two given properties are inverse.")
        }

        print(content)
    }

    @Test func owlNegativePropertyAssertionFieldConstructsAuthoredContent() {
        let content = Property("sourceIndividual") {
            Type(RDF.Property)
            Domain(OWL.NegativePropertyAssertion)
            Range(OWL.Thing)
            Label("sourceIndividual")
            Comment("The property that determines the subject of a negative property assertion.")
        }

        print(content)
    }

    @Test func owlTopDataPropertyConstructsAuthoredContent() {
        let content = Property("topDataProperty") {
            Type(OWL.DatatypeProperty)
            Domain(OWL.Thing)
            Range(RDFS.Literal)
            Label("topDataProperty")
            Comment("The data property that relates every individual to every data value.")
        }

        print(content)
    }

    @Test func standardOWLOntologyConstructsAuthoredContent() {
        print(OWL.ontology)
    }
}
