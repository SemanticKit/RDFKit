import Testing
@testable import RDFKit

@Suite struct RDFSContentTests {
    private struct RDFSOntology: Ontology {
        var content: some Content {
            Namespace("http://www.w3.org/2000/01/rdf-schema#")
            Alias("rdf", Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#"))
            Alias("rdfs", Namespace("http://www.w3.org/2000/01/rdf-schema#"))
            Alias("owl", Namespace("http://www.w3.org/2002/07/owl#"))

            Class("Resource") {
                Type(RDFS.Class.self)
                IsDefinedBy()
                Label("Resource")
                Comment("The class resource, everything.")
            }

            Class("Class") {
                Type(RDFS.Class.self)
                SubClassOf(RDFS.Resource.self)
                IsDefinedBy()
                Label("Class")
                Comment("The class of classes.")
            }

            Property("subClassOf") {
                Type(RDF.Property.self)
                Domain(RDFS.Class.self)
                Range(RDFS.Class.self)
                IsDefinedBy()
                Label("subClassOf")
                Comment("The subject is a subclass of a class.")
            }

            Property("isDefinedBy") {
                Type(RDF.Property.self)
                SubPropertyOf(RDFS.SeeAlso.self)
                Domain(RDFS.Resource.self)
                Range(RDFS.Resource.self)
                IsDefinedBy()
                Label("isDefinedBy")
                Comment("The definition of the subject resource.")
            }
        }
    }

    @Test func rdfsOntologyConstructsAuthoredContent() {
        let ontology = RDFSOntology()

        print(ontology.content)
    }

    @Test func rdfsRootClassDeclarationConstructsAuthoredContent() {
        let content = Class("Resource") {
            Type(RDFS.Class.self)
            IsDefinedBy()
            Label("Resource")
            Comment("The class resource, everything.")
        }

        print(content)
    }

    @Test func rdfsSubclassedClassDeclarationConstructsAuthoredContent() {
        let content = Class("Class") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Resource.self)
            IsDefinedBy()
            Label("Class")
            Comment("The class of classes.")
        }

        print(content)
    }

    @Test func rdfsPropertyDeclarationConstructsAuthoredContent() {
        let content = Property("subClassOf") {
            Type(RDF.Property.self)
            Domain(RDFS.Class.self)
            Range(RDFS.Class.self)
            IsDefinedBy()
            Label("subClassOf")
            Comment("The subject is a subclass of a class.")
        }

        print(content)
    }

    @Test func rdfsSubpropertyDeclarationConstructsAuthoredContent() {
        let content = Property("isDefinedBy") {
            Type(RDF.Property.self)
            SubPropertyOf(RDFS.SeeAlso.self)
            Domain(RDFS.Resource.self)
            Range(RDFS.Resource.self)
            IsDefinedBy()
            Label("isDefinedBy")
            Comment("The definition of the subject resource.")
        }

        print(content)
    }

    @Test func standardRDFSOntologyConstructsAuthoredContent() {
        print(RDFS.ontology)
    }
}
