import Testing
@testable import RDFKit

@Suite struct RDFSContentTests {
    private struct RDFSOntology: Ontology {
        var content: some Content {
//            Namespace("http://www.w3.org/2000/01/rdf-schema#")
            Prefix("rdf", "http://www.w3.org/1999/02/22-rdf-syntax-ns#")
            Prefix("rdfs", "http://www.w3.org/2000/01/rdf-schema#")
            Prefix("owl", "http://www.w3.org/2002/07/owl#")

            Class("Resource") {
                Type(RDFS.Class)
                Label("Resource")
                Comment("The class resource, everything.")
            }

            Class("Class") {
                Type(RDFS.Class)
                SubClassOf(RDFS.Resource)
                Label("Class")
                Comment("The class of classes.")
            }

            Property("subClassOf") {
                Type(RDF.Property)
                Domain(RDFS.Class)
                Range(RDFS.Class)
                Label("subClassOf")
                Comment("The subject is a subclass of a class.")
            }

            Property("isDefinedBy") {
                Type(RDF.Property)
                SubPropertyOf(RDFS.SeeAlso)
                Domain(RDFS.Resource)
                Range(RDFS.Resource)
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
            Type(RDFS.Class)
            Label("Resource")
            Comment("The class resource, everything.")
        }

        print(content)
    }

    @Test func rdfsSubclassedClassDeclarationConstructsAuthoredContent() {
        let content = Class("Class") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Resource)
            Label("Class")
            Comment("The class of classes.")
        }

        print(content)
    }

    @Test func rdfsPropertyDeclarationConstructsAuthoredContent() {
        let content = Property("subClassOf") {
            Type(RDF.Property)
            Domain(RDFS.Class)
            Range(RDFS.Class)
            Label("subClassOf")
            Comment("The subject is a subclass of a class.")
        }

        print(content)
    }

    @Test func rdfsSubpropertyDeclarationConstructsAuthoredContent() {
        let content = Property("isDefinedBy") {
            Type(RDF.Property)
            SubPropertyOf(RDFS.SeeAlso)
            Domain(RDFS.Resource)
            Range(RDFS.Resource)
            Label("isDefinedBy")
            Comment("The definition of the subject resource.")
        }

        print(content)
    }

    @Test func standardRDFSOntologyConstructsAuthoredContent() {
        print(RDFS.ontology)
    }
}
