import Testing
@testable import RDFKit

@Suite struct OWLContentTests {
    private struct OWLOntology: Ontology {
        var content: some Content {
            Namespace("http://www.w3.org/2002/07/owl#")
            Alias("rdf", Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#"))
            Alias("rdfs", Namespace("http://www.w3.org/2000/01/rdf-schema#"))
            Alias("owl", Namespace("http://www.w3.org/2002/07/owl#"))

            Class("Thing") {
                Type(OWL.Class.self)
                IsDefinedBy()
                Label("Thing")
                Comment("The class of OWL individuals.")
            }

            Class("Restriction") {
                Type(RDFS.Class.self)
                SubClassOf(OWL.Class.self)
                IsDefinedBy()
                Label("Restriction")
                Comment("The class of property restrictions.")
            }

            Property("allValuesFrom") {
                Type(RDF.Property.self)
                Domain(OWL.Restriction.self)
                Range(RDFS.Class.self)
                IsDefinedBy()
                Label("allValuesFrom")
                Comment("The property that determines the class that a universal property restriction refers to.")
            }

            Property("backwardCompatibleWith") {
                Type(OWL.AnnotationProperty.self)
                Type(OWL.OntologyProperty.self)
                Domain(OWL.Ontology.self)
                Range(OWL.Ontology.self)
                IsDefinedBy()
                Label("backwardCompatibleWith")
                Comment("The annotation property that indicates that a given ontology is backward compatible with another ontology.")
            }

            Property("cardinality") {
                Type(RDF.Property.self)
                Domain(OWL.Restriction.self)
                Range(IRI("http://www.w3.org/2001/XMLSchema#nonNegativeInteger"))
                IsDefinedBy()
                Label("cardinality")
                Comment("The property that determines the cardinality of an exact cardinality restriction.")
            }

            Property("hasKey") {
                Type(RDF.Property.self)
                Domain(OWL.Class.self)
                Range(RDF.List.self)
                IsDefinedBy()
                Label("hasKey")
                Comment("The property that determines the collection of properties that jointly build a key.")
            }

            Property("inverseOf") {
                Type(RDF.Property.self)
                Domain(OWL.ObjectProperty.self)
                Range(OWL.ObjectProperty.self)
                IsDefinedBy()
                Label("inverseOf")
                Comment("The property that determines that two given properties are inverse.")
            }

            Property("sourceIndividual") {
                Type(RDF.Property.self)
                Domain(OWL.NegativePropertyAssertion.self)
                Range(OWL.Thing.self)
                IsDefinedBy()
                Label("sourceIndividual")
                Comment("The property that determines the subject of a negative property assertion.")
            }

            Property("topDataProperty") {
                Type(OWL.DatatypeProperty.self)
                Domain(OWL.Thing.self)
                Range(RDFS.Literal.self)
                IsDefinedBy()
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
            Type(OWL.Class.self)
            IsDefinedBy()
            Label("Thing")
            Comment("The class of OWL individuals.")
        }

        print(content)
    }

    @Test func owlRestrictionClassDeclarationConstructsAuthoredContent() {
        let content = Class("Restriction") {
            Type(RDFS.Class.self)
            SubClassOf(OWL.Class.self)
            IsDefinedBy()
            Label("Restriction")
            Comment("The class of property restrictions.")
        }

        print(content)
    }

    @Test func owlPropertyDeclarationConstructsAuthoredContent() {
        let content = Property("allValuesFrom") {
            Type(RDF.Property.self)
            Domain(OWL.Restriction.self)
            Range(RDFS.Class.self)
            IsDefinedBy()
            Label("allValuesFrom")
            Comment("The property that determines the class that a universal property restriction refers to.")
        }

        print(content)
    }

    @Test func owlPropertyDeclarationConstructsAuthoredContentWithMultipleTypes() {
        let content = Property("backwardCompatibleWith") {
            Type(OWL.AnnotationProperty.self)
            Type(OWL.OntologyProperty.self)
            Domain(OWL.Ontology.self)
            Range(OWL.Ontology.self)
            IsDefinedBy()
            Label("backwardCompatibleWith")
            Comment("The annotation property that indicates that a given ontology is backward compatible with another ontology.")
        }

        print(content)
    }

    @Test func owlPropertyDeclarationConstructsAuthoredContentWithIRIRange() {
        let content = Property("cardinality") {
            Type(RDF.Property.self)
            Domain(OWL.Restriction.self)
            Range(IRI("http://www.w3.org/2001/XMLSchema#nonNegativeInteger"))
            IsDefinedBy()
            Label("cardinality")
            Comment("The property that determines the cardinality of an exact cardinality restriction.")
        }

        print(content)
    }

    @Test func owlListValuedPropertyDeclarationConstructsAuthoredContent() {
        let content = Property("hasKey") {
            Type(RDF.Property.self)
            Domain(OWL.Class.self)
            Range(RDF.List.self)
            IsDefinedBy()
            Label("hasKey")
            Comment("The property that determines the collection of properties that jointly build a key.")
        }

        print(content)
    }

    @Test func owlObjectPropertyDeclarationConstructsAuthoredContent() {
        let content = Property("inverseOf") {
            Type(RDF.Property.self)
            Domain(OWL.ObjectProperty.self)
            Range(OWL.ObjectProperty.self)
            IsDefinedBy()
            Label("inverseOf")
            Comment("The property that determines that two given properties are inverse.")
        }

        print(content)
    }

    @Test func owlNegativePropertyAssertionFieldConstructsAuthoredContent() {
        let content = Property("sourceIndividual") {
            Type(RDF.Property.self)
            Domain(OWL.NegativePropertyAssertion.self)
            Range(OWL.Thing.self)
            IsDefinedBy()
            Label("sourceIndividual")
            Comment("The property that determines the subject of a negative property assertion.")
        }

        print(content)
    }

    @Test func owlTopDataPropertyConstructsAuthoredContent() {
        let content = Property("topDataProperty") {
            Type(OWL.DatatypeProperty.self)
            Domain(OWL.Thing.self)
            Range(RDFS.Literal.self)
            IsDefinedBy()
            Label("topDataProperty")
            Comment("The data property that relates every individual to every data value.")
        }

        print(content)
    }

    @Test func standardOWLOntologyConstructsAuthoredContent() {
        print(OWL.ontology)
    }
}
