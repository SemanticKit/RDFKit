import Testing
@testable import RDFKit

@Suite struct RDFContentTests {
    private struct RDFOntology: Ontology {
        var content: some Content {
            Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
            Alias("rdf", Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#"))
            Alias("rdfs", Namespace("http://www.w3.org/2000/01/rdf-schema#"))
            Alias("owl", Namespace("http://www.w3.org/2002/07/owl#"))

            Class("Statement") {
                Type(RDFS.Class.self)
                SubClassOf(RDFS.Resource.self)
                IsDefinedBy()
                Label("Statement")
                Comment("The class of RDF statements.")
            }

            Datatype("langString") {
                Type(RDFS.Datatype.self)
                SubClassOf(RDFS.Literal.self)
                IsDefinedBy()
                Label("langString")
                Comment("The datatype of language-tagged string values.")
            }

            Individual("nil") {
                Type(RDF.List.self)
                IsDefinedBy()
                Label("nil")
                Comment("The empty list.")
            }

            Property("type") {
                Type(RDF.Property.self)
                Domain(RDFS.Resource.self)
                Range(RDFS.Class.self)
                IsDefinedBy()
                Label("type")
                Comment("The subject is an instance of a class.")
            }

            Class("CompoundLiteral") {
                Type(RDFS.Class.self)
                SubClassOf(RDFS.Resource.self)
                IsDefinedBy()
                SeeAlso(IRI("https://www.w3.org/TR/json-ld11/#the-rdf-compoundliteral-class-and-the-rdf-language-and-rdf-direction-properties"))
                Label("CompoundLiteral")
                Comment("A class representing a compound literal.")
            }

            Datatype("PlainLiteral") {
                Type(RDFS.Datatype.self)
                SubClassOf(RDFS.Literal.self)
                IsDefinedBy()
                SeeAlso(IRI("http://www.w3.org/TR/rdf-plain-literal/"))
                Label("PlainLiteral")
                Comment("The class of plain literal values.")
                OWLDeprecated()
            }

            Property("first") {
                Type(RDF.Property.self)
                Domain(RDF.List.self)
                Range(RDFS.Resource.self)
                IsDefinedBy()
                Label("first")
                Comment("The first item in the subject RDF list.")
            }

            Individual("version-1.2") {
                Type(RDFS.Resource.self)
                IsDefinedBy()
                Label("1.2")
                Comment("Version 1.2.")
            }
        }
    }

    @Test func rdfOntologyConstructsAuthoredContent() {
        let ontology = RDFOntology()

        print(ontology.content)
    }

    @Test func rdfClassDeclarationConstructsAuthoredContent() {
        let content = Class("Statement") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Resource.self)
            IsDefinedBy()
            Label("Statement")
            Comment("The class of RDF statements.")
        }

        print(content)
    }

    @Test func rdfClassDeclarationConstructsAuthoredContentWithSeeAlso() {
        let content = Class("CompoundLiteral") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Resource.self)
            IsDefinedBy()
            SeeAlso(IRI("https://www.w3.org/TR/json-ld11/#the-rdf-compoundliteral-class-and-the-rdf-language-and-rdf-direction-properties"))
            Label("CompoundLiteral")
            Comment("A class representing a compound literal.")
        }

        print(content)
    }

    @Test func rdfDatatypeDeclarationConstructsAuthoredContent() {
        let content = Datatype("langString") {
            Type(RDFS.Datatype.self)
            SubClassOf(RDFS.Literal.self)
            IsDefinedBy()
            Label("langString")
            Comment("The datatype of language-tagged string values.")
        }

        print(content)
    }

    @Test func rdfDatatypeDeclarationConstructsAuthoredContentWithDeprecation() {
        let content = Datatype("PlainLiteral") {
            Type(RDFS.Datatype.self)
            SubClassOf(RDFS.Literal.self)
            IsDefinedBy()
            SeeAlso(IRI("http://www.w3.org/TR/rdf-plain-literal/"))
            Label("PlainLiteral")
            Comment("The class of plain literal values.")
            OWLDeprecated()
        }

        print(content)
    }

    @Test func rdfIndividualDeclarationConstructsAuthoredContent() {
        let content = Individual("nil") {
            Type(RDF.List.self)
            IsDefinedBy()
            Label("nil")
            Comment("The empty list.")
        }

        print(content)
    }

    @Test func rdfVersionIndividualConstructsAuthoredContent() {
        let content = Individual("version-1.2") {
            Type(RDFS.Resource.self)
            IsDefinedBy()
            Label("1.2")
            Comment("Version 1.2.")
        }

        print(content)
    }

    @Test func rdfPropertyDeclarationConstructsAuthoredContent() {
        let content = Property("type") {
            Type(RDF.Property.self)
            Domain(RDFS.Resource.self)
            Range(RDFS.Class.self)
            IsDefinedBy()
            Label("type")
            Comment("The subject is an instance of a class.")
        }

        print(content)
    }

    @Test func rdfListPropertyDeclarationConstructsAuthoredContent() {
        let content = Property("first") {
            Type(RDF.Property.self)
            Domain(RDF.List.self)
            Range(RDFS.Resource.self)
            IsDefinedBy()
            Label("first")
            Comment("The first item in the subject RDF list.")
        }

        print(content)
    }

    @Test func standardRDFOntologyConstructsAuthoredContent() {
        print(RDF.ontology)
    }
}
