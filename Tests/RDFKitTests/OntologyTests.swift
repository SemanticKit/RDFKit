import Foundation
import Testing
@testable import RDFKit

@Suite struct OntologyTests {
    struct FixtureGraphContent: GraphContent {
        let subject: IRI

        func write(to graph: inout Graph) throws {
            try graph.insert(Graph.TripleType(
                subject: AnyRDFSubject(subject),
                predicate: RDF.type,
                object: AnyRDFObject(RDFS.Resource.iri)
            ))
        }
    }

    struct SemanticKitOntology: Ontology {
        var content: some Content {
            Namespace("https://example.com/ontology#")
            Alias("rdf", RDF.self)
            Alias("rdfs", RDFS.self)
            Alias("owl", OWL.self)
        }
    }

    @Test func ontologyUsesProtocolBasedAliasesAndContent() throws {
        let ontology = SemanticKitOntology()
        let rdfAlias = Alias("rdf", RDF.self)
        let rdfAliasNamespace = try rdfAlias.target.aliasNamespace()

        #expect(ontology.id == IRI("https://example.com/ontology#"))
        #expect(ontology.iri == ontology.id)
        #expect(ontology.environment.namespace == Namespace("https://example.com/ontology#"))
        #expect(ontology.environment.iri == ontology.id)
        #expect(rdfAliasNamespace == Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#"))
        _ = ontology.content
    }

    @Test func ontologyEnvironmentScopesChildDeclarations() throws {
        let ontology = ChildScopedOntology()
        let declaration = Class("Asset") {
            Label("Asset")
        }
        let declarations = try OntologyExpansionDeclarationCollector(maximumDepth: 8)
            .declarations(in: ontology.content, environment: ontology.environment)

        #expect(declaration.iri(in: ontology.environment) == IRI("https://example.com/child#Asset"))
        #expect(declarations.map(\.iri) == [IRI("https://example.com/child#Asset")])
    }

    @Test func declarationContentInfersParentOntologyContext() throws {
        let ontology = ImplicitEnvironmentOntology()
        let asset = IRI("https://example.com/implicit-environment#Asset")
        let facts = ContentFactResolver.facts(in: ontology.content)
        let declarations = try OntologyExpansionDeclarationCollector(maximumDepth: 8)
            .declarations(in: ontology.content, environment: ontology.environment)

        #expect(try ContentTermResolver.classIRIs(in: ontology.content) == [asset])
        #expect(declarations.map(\.iri) == [asset])
        #expect(facts[asset]?.isDefinedBy == [ontology.iri])
    }

    @Test func standardOntologyUsesDirectContentBuilder() {
        _ = RDF.ontology
        _ = RDFS.ontology
        _ = OWL.ontology
    }

    @Test func rdfOntologyCanBeRecreatedWithDeclarationDSL() throws {
        let rdf = RDFOntologyWrittenInDSL()
        let content = rdf.content
        let classes = rdfIRIs([
            "Alt",
            "Bag",
            "CompoundLiteral",
            "List",
            "Property",
            "PropositionForm",
            "Seq",
            "Statement"
        ])
        let datatypes = rdfIRIs([
            "HTML",
            "JSON",
            "PlainLiteral",
            "XMLLiteral",
            "dirLangString",
            "langString"
        ])
        let individuals = rdfIRIs([
            "nil",
            "version-1.0",
            "version-1.1",
            "version-1.2",
            "version-1.2-basic"
        ])
        let properties = rdfIRIs([
            "direction",
            "first",
            "language",
            "object",
            "predicate",
            "propositionFormObject",
            "propositionFormPredicate",
            "propositionFormSubject",
            "reifies",
            "rest",
            "subject",
            "type",
            "value"
        ])
        let terms = classes.union(datatypes).union(individuals).union(properties)
        let facts = ContentFactResolver.facts(in: content)

        #expect(try ContentTermResolver.classIRIs(in: content) == classes)
        #expect(try ContentTermResolver.datatypeIRIs(in: content) == datatypes)
        #expect(try ContentTermResolver.individualIRIs(in: content) == individuals)
        #expect(try ContentTermResolver.propertyIRIs(in: content) == properties)
        #expect(try ContentTermResolver.termIRIs(in: content) == terms)
        #expect(facts[IRI("http://www.w3.org/1999/02/22-rdf-syntax-ns#Alt")]?.types == [RDFS.Class.iri])
        #expect(facts[IRI("http://www.w3.org/1999/02/22-rdf-syntax-ns#Alt")]?.superclasses == [RDFS.Container.iri])
        #expect(facts[IRI("http://www.w3.org/1999/02/22-rdf-syntax-ns#HTML")]?.types == [RDFS.Datatype.iri])
        #expect(facts[IRI("http://www.w3.org/1999/02/22-rdf-syntax-ns#HTML")]?.superclasses == [RDFS.Literal.iri])
        #expect(facts[IRI("http://www.w3.org/1999/02/22-rdf-syntax-ns#PlainLiteral")]?.deprecated == true)
        #expect(facts[IRI("http://www.w3.org/1999/02/22-rdf-syntax-ns#type")]?.types == [RDF.Property.iri])
        #expect(facts[IRI("http://www.w3.org/1999/02/22-rdf-syntax-ns#type")]?.domains == [RDFS.Resource.iri])
        #expect(facts[IRI("http://www.w3.org/1999/02/22-rdf-syntax-ns#type")]?.ranges == [RDFS.Class.iri])
        #expect(facts[IRI("http://www.w3.org/1999/02/22-rdf-syntax-ns#first")]?.domains == [RDF.List.iri])
        #expect(facts[IRI("http://www.w3.org/1999/02/22-rdf-syntax-ns#first")]?.ranges == [RDFS.Resource.iri])
        #expect(facts[IRI("http://www.w3.org/1999/02/22-rdf-syntax-ns#rest")]?.ranges == [RDF.List.iri])
        #expect(facts[IRI("http://www.w3.org/1999/02/22-rdf-syntax-ns#Alt")]?.labels == ["Alt"])
        #expect(facts[IRI("http://www.w3.org/1999/02/22-rdf-syntax-ns#Alt")]?.comments == ["The class of containers of alternatives."])
        #expect(terms.count == 32)
    }

    @Test func rdfsOntologyCanBeRecreatedWithDeclarationDSL() throws {
        let rdfs = RDFSOntologyWrittenInDSL()
        let content = rdfs.content
        let classes = rdfsIRIs([
            "Class",
            "Container",
            "ContainerMembershipProperty",
            "Datatype",
            "Literal",
            "Proposition",
            "Resource"
        ])
        let properties = rdfsIRIs([
            "comment",
            "domain",
            "isDefinedBy",
            "label",
            "member",
            "range",
            "seeAlso",
            "subClassOf",
            "subPropertyOf"
        ])
        let terms = classes.union(properties)
        let facts = ContentFactResolver.facts(in: content)

        #expect(try ContentTermResolver.classIRIs(in: content) == classes)
        #expect(try ContentTermResolver.propertyIRIs(in: content) == properties)
        #expect(try ContentTermResolver.termIRIs(in: content) == terms)
        #expect(facts[RDFS.Resource.iri]?.types == [RDFS.Class.iri])
        #expect(facts[RDFS.Proposition.iri]?.superclasses == [RDFS.Resource.iri])
        #expect(facts[RDFS.Datatype.iri]?.superclasses == [RDFS.Class.iri])
        #expect(facts[RDFS.ContainerMembershipProperty.iri]?.superclasses == [RDF.Property.iri])
        #expect(facts[RDFS.subClassOf.iri]?.types == [RDF.Property.iri])
        #expect(facts[RDFS.subClassOf.iri]?.domains == [RDFS.Class.iri])
        #expect(facts[RDFS.subClassOf.iri]?.ranges == [RDFS.Class.iri])
        #expect(facts[RDFS.subPropertyOf.iri]?.domains == [RDF.Property.iri])
        #expect(facts[RDFS.subPropertyOf.iri]?.ranges == [RDF.Property.iri])
        #expect(facts[RDFS.isDefinedBy.iri]?.superproperties == [RDFS.seeAlso.iri])
        #expect(facts[RDFS.Resource.iri]?.isDefinedBy == [RDFS().iri])
        #expect(facts[RDFS.Resource.iri]?.labels == ["Resource"])
        #expect(facts[RDFS.Resource.iri]?.comments == ["The class resource, everything."])
        #expect(terms.count == 16)
    }

    @Test func siblingNamespacesExposeStandardTerms() throws {
        #expect(RDF.type.iri == IRI("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"))
        #expect(RDFS.Class.iri == IRI("http://www.w3.org/2000/01/rdf-schema#Class"))
        #expect(OWL.Thing.iri == IRI("http://www.w3.org/2002/07/owl#Thing"))
    }

    @Test func standardVocabulariesAreDSLTypes() {
        let vocabularies: [any Vocabulary] = [RDF(), RDFS(), OWL()]

        #expect(vocabularies.count == 3)
        #expect(vocabularies.allSatisfy { $0.iri.rawValue.isEmpty == false })
    }

    @Test func graphContentBuilderMaterializesProtocolContent() throws {
        let graph = try makeGraph {
            FixtureGraphContent(subject: IRI("https://example.com/First"))
            FixtureGraphContent(subject: IRI("https://example.com/Second"))
        }

        #expect(graph.triples.count == 2)
    }

    private func makeGraph(@GraphContentBuilder content: () -> some GraphContent) throws -> Graph {
        try content().graph()
    }

    private func rdfIRIs(_ localNames: [String]) -> Set<IRI> {
        Set(localNames.map { IRI("http://www.w3.org/1999/02/22-rdf-syntax-ns#\($0)") })
    }

    private func rdfsIRIs(_ localNames: [String]) -> Set<IRI> {
        Set(localNames.map { IRI("http://www.w3.org/2000/01/rdf-schema#\($0)") })
    }

    private struct ChildScopedOntology: Ontology {
        var content: some Content {
            Namespace("https://example.com/child#")

            Class("Asset") {
                Label("Asset")
            }
        }
    }

    private struct ImplicitEnvironmentOntology: Ontology {
        var content: some Content {
            Namespace("https://example.com/implicit-environment#")

            Class("Asset") {
                IsDefinedBy()
            }
        }
    }

    private struct RDFOntologyWrittenInDSL: Ontology {
        var content: some Content {
            Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
            Alias("rdf", RDF.self)
            Alias("rdfs", RDFS.self)

            Class("Alt") {
                Type(RDFS.Class.self)
                SubClassOf(RDFS.Container.self)
                Label("Alt")
                Comment("The class of containers of alternatives.")
            }
            Class("Bag") {
                Type(RDFS.Class.self)
                SubClassOf(RDFS.Container.self)
                Label("Bag")
            }
            Class("CompoundLiteral") {
                Type(RDFS.Class.self)
                SubClassOf(RDFS.Resource.self)
            }
            Datatype("HTML") {
                Type(RDFS.Datatype.self)
                SubClassOf(RDFS.Literal.self)
                Label("HTML")
            }
            Datatype("JSON") {
                Type(RDFS.Datatype.self)
                SubClassOf(RDFS.Literal.self)
                Label("JSON")
            }
            Datatype("dirLangString") {
                Type(RDFS.Datatype.self)
                SubClassOf(RDFS.Literal.self)
            }
            Datatype("langString") {
                Type(RDFS.Datatype.self)
                SubClassOf(RDFS.Literal.self)
                Label("langString")
            }
            Class("List") {
                Type(RDFS.Class.self)
                SubClassOf(RDFS.Resource.self)
            }
            Individual("nil") {
                Type(RDF.List.self)
                Label("nil")
            }
            Datatype("PlainLiteral") {
                Type(RDFS.Datatype.self)
                SubClassOf(RDFS.Literal.self)
                OWLDeprecated()
            }
            Class("Property") {
                Type(RDFS.Class.self)
                SubClassOf(RDFS.Resource.self)
            }
            Class("PropositionForm") {
                Type(RDFS.Class.self)
                SubClassOf(RDFS.Resource.self)
            }
            Class("Seq") {
                Type(RDFS.Class.self)
                SubClassOf(RDFS.Container.self)
            }
            Class("Statement") {
                Type(RDFS.Class.self)
                SubClassOf(RDFS.Resource.self)
            }
            Property("direction") {
                Type(RDF.Property.self)
                Domain(RDF.CompoundLiteral.self)
            }
            Property("first") {
                Type(RDF.Property.self)
                Domain(RDF.List.self)
                Range(RDFS.Resource.self)
            }
            Property("language") {
                Type(RDF.Property.self)
                Domain(RDF.CompoundLiteral.self)
            }
            Property("object") {
                Type(RDF.Property.self)
                Domain(RDF.Statement.self)
                Range(RDFS.Resource.self)
            }
            Property("predicate") {
                Type(RDF.Property.self)
                Domain(RDF.Statement.self)
                Range(RDFS.Resource.self)
            }
            Property("propositionFormObject") {
                Type(RDF.Property.self)
                Domain(RDF.PropositionForm.self)
                Range(RDFS.Resource.self)
            }
            Property("propositionFormPredicate") {
                Type(RDF.Property.self)
                Domain(RDF.PropositionForm.self)
                Range(RDF.Property.self)
            }
            Property("propositionFormSubject") {
                Type(RDF.Property.self)
                Domain(RDF.PropositionForm.self)
                Range(RDFS.Resource.self)
            }
            Property("reifies") {
                Type(RDF.Property.self)
                Domain(RDFS.Resource.self)
                Range(RDFS.Proposition.self)
            }
            Property("rest") {
                Type(RDF.Property.self)
                Domain(RDF.List.self)
                Range(RDF.List.self)
            }
            Property("subject") {
                Type(RDF.Property.self)
                Domain(RDF.Statement.self)
                Range(RDFS.Resource.self)
            }
            Property("type") {
                Type(RDF.Property.self)
                Domain(RDFS.Resource.self)
                Range(RDFS.Class.self)
                Label("type")
                Comment("The subject is an instance of a class.")
            }
            Property("value") {
                Type(RDF.Property.self)
                Domain(RDFS.Resource.self)
                Range(RDFS.Resource.self)
            }
            Datatype("XMLLiteral") {
                Type(RDFS.Datatype.self)
                SubClassOf(RDFS.Literal.self)
            }
            Individual("version-1.0") {
                Type(RDFS.Resource.self)
                Label("1.0")
            }
            Individual("version-1.1") {
                Type(RDFS.Resource.self)
                Label("1.1")
            }
            Individual("version-1.2") {
                Type(RDFS.Resource.self)
                Label("1.2")
            }
            Individual("version-1.2-basic") {
                Type(RDFS.Resource.self)
                Label("1.2-basic")
            }
        }
    }

    private struct RDFSOntologyWrittenInDSL: Ontology {
        var content: some Content {
            Namespace("http://www.w3.org/2000/01/rdf-schema#")
            Alias("rdf", RDF.self)
            Alias("rdfs", RDFS.self)

            Class("Resource") {
                Type(RDFS.Class.self)
                IsDefinedBy(RDFS())
                Label("Resource")
                Comment("The class resource, everything.")
            }
            Class("Proposition") {
                Type(RDFS.Class.self)
                SubClassOf(RDFS.Resource.self)
                IsDefinedBy(RDFS())
                Label("Proposition")
                Comment("The class of propositions, simple logical expressions describing a relationship between two entities.")
            }
            Class("Class") {
                Type(RDFS.Class.self)
                SubClassOf(RDFS.Resource.self)
                IsDefinedBy(RDFS())
                Label("Class")
                Comment("The class of classes.")
            }
            Property("subClassOf") {
                Type(RDF.Property.self)
                Domain(RDFS.Class.self)
                Range(RDFS.Class.self)
                IsDefinedBy(RDFS())
                Label("subClassOf")
                Comment("The subject is a subclass of a class.")
            }
            Property("subPropertyOf") {
                Type(RDF.Property.self)
                Domain(RDF.Property.self)
                Range(RDF.Property.self)
                IsDefinedBy(RDFS())
                Label("subPropertyOf")
                Comment("The subject is a subproperty of a property.")
            }
            Property("comment") {
                Type(RDF.Property.self)
                Domain(RDFS.Resource.self)
                Range(RDFS.Literal.self)
                IsDefinedBy(RDFS())
                Label("comment")
                Comment("A description of the subject resource.")
            }
            Property("label") {
                Type(RDF.Property.self)
                Domain(RDFS.Resource.self)
                Range(RDFS.Literal.self)
                IsDefinedBy(RDFS())
                Label("label")
                Comment("A human-readable name for the subject.")
            }
            Property("domain") {
                Type(RDF.Property.self)
                Domain(RDF.Property.self)
                Range(RDFS.Class.self)
                IsDefinedBy(RDFS())
                Label("domain")
                Comment("A domain of the subject property.")
            }
            Property("range") {
                Type(RDF.Property.self)
                Domain(RDF.Property.self)
                Range(RDFS.Class.self)
                IsDefinedBy(RDFS())
                Label("range")
                Comment("A range of the subject property.")
            }
            Property("seeAlso") {
                Type(RDF.Property.self)
                Domain(RDFS.Resource.self)
                Range(RDFS.Resource.self)
                IsDefinedBy(RDFS())
                Label("seeAlso")
                Comment("Further information about the subject resource.")
            }
            Property("isDefinedBy") {
                Type(RDF.Property.self)
                SubPropertyOf(RDFS.SeeAlso.self)
                Domain(RDFS.Resource.self)
                Range(RDFS.Resource.self)
                IsDefinedBy(RDFS())
                Label("isDefinedBy")
                Comment("The definition of the subject resource.")
            }
            Class("Literal") {
                Type(RDFS.Class.self)
                SubClassOf(RDFS.Resource.self)
                IsDefinedBy(RDFS())
                Label("Literal")
                Comment("The class of literal values, eg. textual strings and integers.")
            }
            Class("Container") {
                Type(RDFS.Class.self)
                SubClassOf(RDFS.Resource.self)
                IsDefinedBy(RDFS())
                Label("Container")
                Comment("The class of RDF containers.")
            }
            Class("ContainerMembershipProperty") {
                Type(RDFS.Class.self)
                SubClassOf(RDF.Property.self)
                IsDefinedBy(RDFS())
                Label("ContainerMembershipProperty")
                Comment("The class of container membership properties, rdf:_1, rdf:_2, ..., all of which are sub-properties of 'member'.")
            }
            Property("member") {
                Type(RDF.Property.self)
                Domain(RDFS.Resource.self)
                Range(RDFS.Resource.self)
                IsDefinedBy(RDFS())
                Label("member")
                Comment("A member of the subject resource.")
            }
            Class("Datatype") {
                Type(RDFS.Class.self)
                SubClassOf(RDFS.Class.self)
                IsDefinedBy(RDFS())
                Label("Datatype")
                Comment("The class of RDF datatypes.")
            }
        }
    }

}
