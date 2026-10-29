import IRIKit
import RDFCore
import RDFKit
import Testing

@Suite("RDFS through @Ontology", .tags(.ontology, .generated))
struct RDFSTests {
    @Test("Every individual is an rdfs:Resource with labels and comments", .tags(.property))
    func everyIndividualIsAResource() {
        let graph = IndividualGraph()
        let eve = Kinship.PersonIndividual(in: graph, name: "Eve")
        let list = RDF.ListIndividual(in: graph)

        // Neither class names rdfs:Resource, and both refine it.
        let resources: [any RDFS.Resource] = [eve, list]
        resources[0].label.append("Eve")
        resources[1].comment.append("An empty list.")

        #expect(eve.label.values == ["Eve"])
        #expect(list.comment.values == ["An empty list."])
        #expect(list.label.isEmpty)
    }

    @Test("rdfs:subClassOf relates classes as objects", .tags(.property))
    func subClassOfRelatesClasses() throws {
        let graph = IndividualGraph()
        let animal = RDFS.ClassIndividual(in: graph)
        let predator = RDFS.ClassIndividual(in: graph, subClassOf: [animal])

        let superclass = try #require(predator.subClassOf.first)
        #expect(superclass === animal)
        #expect(animal.subClassOf.isEmpty)
    }

    @Test("rdfs:Datatype is an rdfs:Class, and stores its superclasses once", .tags(.property))
    func datatypeIsAClass() throws {
        let graph = IndividualGraph()
        let literal = RDFS.ClassIndividual(in: graph)
        let datatype = RDFS.DatatypeIndividual(in: graph)
        let asClass: any RDFS.Class = datatype

        asClass.subClassOf.append(literal)
        let superclass = try #require(datatype.subClassOf.first)
        #expect(superclass === literal)
        #expect(asClass === datatype)
    }

    @Test("A container membership property is an rdf:Property with a domain", .tags(.property))
    func containerMembershipPropertyIsAProperty() {
        // rdfs:ContainerMembershipProperty refines rdf:Property, which RDF declares.
        let graph = IndividualGraph()
        let first = RDFS.ContainerMembershipPropertyIndividual(in: graph)
        let container = RDFS.ContainerIndividual(in: graph)
        let property: any RDF.Property = first
        property.label.append("_1")
        first.subPropertyOf.append(RDFS.ContainerMembershipPropertyIndividual(in: graph))

        #expect(property === first)
        #expect(first.label.values == ["_1"])
        #expect(property.subPropertyOf.count == 1)
        #expect(container.member.isEmpty)
    }

    @Test("The DSL's annotations are the generated property terms")
    func annotationsAreTheGeneratedTerms() throws {
        let label = RDFS.label("Animal")
        let comment = RDFS.comment("The class of all animals.")
        #expect(label.text == "Animal")
        #expect(comment.text == "The class of all animals.")

        // `Label("Person")` in Kinship's content is built as `RDFS.label`.
        let person = try #require(Kinship().content().first { $0 is RDFCore.Class } as? RDFCore.Class)
        let labels = person.content.compactMap { $0 as? RDFS.label }
        #expect(labels.map(\.text) == ["Person"])
    }

    @Test("A literal range holds rdfs:Literal values", .tags(.property))
    func literalRangeHoldsLiterals() throws {
        let graph = IndividualGraph()
        let eve = Kinship.PersonIndividual(in: graph, name: "Eve")
        eve.label.append(RDFS.Literal("Ève", languageTag: "fr"))

        let name = try #require(eve.name.value)
        let french = try #require(eve.label.first)
        #expect(name.lexicalForm == "Eve")
        #expect(name.languageTag == nil)
        #expect(french.languageTag == "fr")
        #expect(french != "Ève")
    }

    @Test("Each term's IRI is projected from the RDFS namespace", .tags(.boundary))
    func iriIsProjectedFromTheNamespace() {
        let rdfs = "http://www.w3.org/2000/01/rdf-schema#"
        #expect(RDFS.ResourceIndividual.metadata.id == IRI(rdfs + "Resource"))
        #expect(RDFS.ClassIndividual.metadata.id == IRI(rdfs + "Class"))
        #expect(RDFS.label.metadata.id == IRI(rdfs + "label"))
        #expect(RDFS.seeAlso.metadata.id == IRI(rdfs + "seeAlso"))
        #expect(RDFS.seeAlso("https://www.w3.org/TR/rdf12-schema/").document == IRI("https://www.w3.org/TR/rdf12-schema/"))
        #expect(RDFS.Literal.metadata.label == "Literal")
    }
}
