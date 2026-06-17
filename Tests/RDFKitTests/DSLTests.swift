import Testing
@testable import RDFKit
import IRIKit

@Suite struct RDFDSLBehavior {
    @Test func declareClassInOntology() {
        // Given an ontology with a single class
        struct MyOntology: Ontology {
            var content: Content {
                Namespace("https://example.com#")
                Class("Widget") {
                    Type(RDFSTerm.Class)
                    Label("Widget")
                    Comment("A widget.")
                }
            }
        }

        // When the ontology is created
        let ontology = MyOntology()

        // Then the content contains exactly one class declaration
        let classes = ontology.content.compactMap { $0 as? TermDeclaration }
        #expect(classes.count == 1)
        #expect(classes[0].name == "Widget")
        #expect(classes[0].kind == .class)
        #expect(classes[0].children.count == 3)
    }

    @Test func declarePropertyWithDomainAndRange() {
        // Given a property with domain, range, and label
        let prop = Property("name") {
            Type(RDFTerm.Property)
            Domain(RDFSTerm.Resource)
            Range(RDFSTerm.Literal)
            Label("name")
        }

        // When inspecting the declaration
        // Then it has the correct structure
        #expect(prop.name == "name")
        #expect(prop.kind == .property)
        #expect(prop.children.count == 4)
    }

    @Test func declareMultipleTypesOnOneProperty() {
        // Given a property annotated with two OWL types
        let prop = Property("backwardCompatibleWith") {
            Type(OWLTerm.AnnotationProperty)
            Type(OWLTerm.OntologyProperty)
            Domain(OWLTerm.Ontology)
            Range(OWLTerm.Ontology)
            Label("backwardCompatibleWith")
        }

        // When counting the type annotations
        let types = prop.children.compactMap { $0 as? TypeAnnotation }

        // Then both type annotations are present
        #expect(types.count == 2)
    }

    @Test func declareDatatypeSubclassingLiteral() {
        // Given a datatype that subclasses rdfs:Literal
        let dt = Datatype("langString") {
            Type(RDFSTerm.Datatype)
            SubClassOf(RDFSTerm.Literal)
            Label("langString")
        }

        // When inspecting the declaration
        // Then it has the right name, kind, and subclass relationship
        #expect(dt.name == "langString")
        #expect(dt.kind == .datatype)
        #expect(dt.children.count == 3)
    }

    @Test func declareIndividualWithLabel() {
        // Given an individual declaration
        let ind = Individual("nil") {
            Type(RDFTerm.List)
            Label("nil")
        }

        // When inspecting the declaration
        // Then it is marked as an individual
        #expect(ind.name == "nil")
        #expect(ind.kind == .individual)
    }
}

@Suite struct OntologyTreeBehavior {
    @Test func ontologyExtractsNamespaceFromContent() {
        // Given an ontology with a Namespace declaration
        struct NSOntology: Ontology {
            var content: Content {
                Namespace("https://example.com/vocab#")
                Prefix("ex", "https://example.com/vocab#")
            }
        }

        // When accessing the ontology's namespace
        let ns = NSOntology().namespace

        // Then it matches the declared namespace
        #expect(ns.rawValue == "https://example.com/vocab#")
    }

    @Test func ontologyPreservesAllContentInOrder() {
        // Given an ontology with multiple declarations
        struct OrderedOntology: Ontology {
            var content: Content {
                Namespace("https://example.com#")
                Prefix("ex", "https://example.com#")
                Class("A") { Label("A") }
                Class("B") { Label("B") }
                Property("p") { Label("p") }
            }
        }

        // When reading the content
        let content = OrderedOntology().content

        // Then all items are present and in declaration order
        #expect(content.count == 5)
        #expect((content[0] as? Namespace)?.rawValue == "https://example.com#")
        #expect((content[1] as? Prefix)?.prefix == "ex")
        let names = content.compactMap { ($0 as? TermDeclaration)?.name }
        #expect(names == ["A", "B", "p"])
    }
}

@Suite struct StandardOntologyBehavior {
    @Test func rdfOntologyDefinesCoreClasses() {
        // Given the standard RDF ontology
        let rdf = RDF()

        // When querying for class declarations
        let classes = rdf.content.compactMap { $0 as? TermDeclaration }

        // Then it contains the core RDF classes
        let names = classes.map(\.name)
        #expect(names.contains("Alt"))
        #expect(names.contains("Bag"))
        #expect(names.contains("Seq"))
        #expect(names.contains("Statement"))
        #expect(names.contains("Property"))
        #expect(names.contains("List"))
    }

    @Test func rdfOntologyDefinesCoreProperties() {
        // Given the standard RDF ontology
        let rdf = RDF()

        // When querying for property declarations
        let props = rdf.content.compactMap { $0 as? TermDeclaration }

        // Then it contains the core RDF properties
        let names = props.map(\.name)
        #expect(names.contains("type"))
        #expect(names.contains("subject"))
        #expect(names.contains("predicate"))
        #expect(names.contains("object"))
        #expect(names.contains("first"))
        #expect(names.contains("rest"))
    }

    @Test func rdfsOntologyDefinesCoreClasses() {
        // Given the standard RDFS ontology
        let rdfs = RDFS()

        // When querying for class declarations
        let classes = rdfs.content.compactMap { $0 as? TermDeclaration }

        // Then it contains the core RDFS classes
        let names = classes.map(\.name)
        #expect(names.contains("Class"))
        #expect(names.contains("Resource"))
        #expect(names.contains("Literal"))
        #expect(names.contains("Container"))
        #expect(names.contains("Datatype"))
    }

    @Test func rdfsOntologyDefinesCoreProperties() {
        // Given the standard RDFS ontology
        let rdfs = RDFS()

        // When querying for property declarations
        let props = rdfs.content.compactMap { $0 as? TermDeclaration }

        // Then it contains the core RDFS properties
        let names = props.map(\.name)
        #expect(names.contains("subClassOf"))
        #expect(names.contains("subPropertyOf"))
        #expect(names.contains("domain"))
        #expect(names.contains("range"))
        #expect(names.contains("label"))
        #expect(names.contains("comment"))
    }

    @Test func owlOntologyDefinesCoreClasses() {
        // Given the standard OWL ontology
        let owl = OWL()

        // When querying for class declarations
        let classes = owl.content.compactMap { $0 as? TermDeclaration }

        // Then it contains the core OWL classes
        let names = classes.map(\.name)
        #expect(names.contains("Thing"))
        #expect(names.contains("Nothing"))
        #expect(names.contains("Class"))
        #expect(names.contains("ObjectProperty"))
        #expect(names.contains("DatatypeProperty"))
        #expect(names.contains("Restriction"))
        #expect(names.contains("Ontology"))
    }

    @Test func owlOntologyDefinesCoreProperties() {
        // Given the standard OWL ontology
        let owl = OWL()

        // When querying for property declarations
        let props = owl.content.compactMap { $0 as? TermDeclaration }

        // Then it contains the core OWL properties
        let names = props.map(\.name)
        #expect(names.contains("sameAs"))
        #expect(names.contains("imports"))
        #expect(names.contains("equivalentClass"))
        #expect(names.contains("disjointWith"))
        #expect(names.contains("complementOf"))
    }

    @Test func eachStandardOntologyHasCorrectNamespace() {
        // Given each standard ontology
        // When accessing its namespace
        // Then it matches the W3C namespace IRI
        #expect(RDF().namespace.rawValue == "http://www.w3.org/1999/02/22-rdf-syntax-ns#")
        #expect(RDFS().namespace.rawValue == "http://www.w3.org/2000/01/rdf-schema#")
        #expect(OWL().namespace.rawValue == "http://www.w3.org/2002/07/owl#")
    }
}

@Suite struct FreeFunctionBehavior {
    @Test func freeFunctionClassReturnsDeclaration() {
        // Given a class declaration at module scope
        let decl = Class("Foo") {
            Type(RDFSTerm.Class)
            Label("Foo")
        }

        // When inspecting the result
        // Then it is a valid class declaration
        #expect(decl.kind == .class)
        #expect(decl.name == "Foo")
    }

    @Test func freeFunctionPropertyReturnsDeclaration() {
        // Given a property declaration at module scope
        let decl = Property("bar") {
            Type(RDFTerm.Property)
            Label("bar")
        }

        // When inspecting the result
        // Then it is a valid property declaration
        #expect(decl.kind == .property)
        #expect(decl.name == "bar")
    }

    @Test func annotationsCanBeUsedInsideDeclaration() {
        // Given a class with all annotation types
        let decl = Class("Foo") {
            Type(RDFSTerm.Class)
            SubClassOf(RDFSTerm.Resource)
            SubPropertyOf(RDFSTerm.SeeAlso)
            Domain(RDFSTerm.Class)
            Range(RDFSTerm.Literal)
            Label("Foo")
            Comment("A foo.")
            SeeAlso("https://example.com")
            OWLDeprecated()
        }

        // When inspecting the declaration
        // Then all 9 annotations are present as children
        #expect(decl.children.count == 9)
    }

    @Test func freeFunctionAnnotationsStoreCorrectValues() {
        // Given each annotation free function
        // When calling each one
        // Then the stored values match the inputs
        let typeAnn = Type(RDFSTerm.Class)
        let labelAnn = Label("hello")
        let commentAnn = Comment("world")
        let seeAlsoAnn = SeeAlso("https://x.com")

        #expect(labelAnn.text == "hello")
        #expect(commentAnn.text == "world")
        #expect(seeAlsoAnn.url == "https://x.com")
        // Type stores the term as any Node — verify it's present
        #expect(typeAnn.term is Node)
    }
}
