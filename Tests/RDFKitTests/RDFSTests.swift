import IRIKit
import RDFCore
import RDFKit
import Testing

@Suite("RDFS through @Ontology", .tags(.ontology, .generated))
struct RDFSTests {
    @Test("Every individual is an rdfs:Resource with labels and comments", .tags(.property))
    func everyIndividualIsAResource() {
        let eve = Kinship.PersonIndividual(name: "Eve")
        let list = RDF.ListIndividual()

        // Neither class names rdfs:Resource, and both refine it.
        let resources: [any RDFS.Resource] = [eve, list]
        resources[0].label = ["Eve"]
        resources[1].comment = ["An empty list."]

        #expect(eve.label == ["Eve"])
        #expect(list.comment == ["An empty list."])
        #expect(list.label.isEmpty)
    }

    @Test("rdfs:subClassOf relates classes as objects", .tags(.property))
    func subClassOfRelatesClasses() throws {
        let animal = RDFS.ClassIndividual()
        let predator = RDFS.ClassIndividual(subClassOf: [animal])

        let superclass = try #require(predator.subClassOf.first)
        #expect(superclass === animal)
        #expect(animal.subClassOf.isEmpty)
    }

    @Test("rdfs:Datatype is an rdfs:Class, and stores its superclasses once", .tags(.property))
    func datatypeIsAClass() throws {
        let literal = RDFS.ClassIndividual()
        let datatype = RDFS.DatatypeIndividual()
        let asClass: any RDFS.Class = datatype

        asClass.subClassOf = [literal]
        let superclass = try #require(datatype.subClassOf.first)
        #expect(superclass === literal)
        #expect(asClass === datatype)
    }

    @Test("A container membership property is an rdf:Property")
    func containerMembershipPropertyIsAProperty() {
        // rdfs:ContainerMembershipProperty refines rdf:Property, which RDF declares.
        let first = RDFS.ContainerMembershipPropertyIndividual()
        let property: any RDF.Property = first
        property.label = ["_1"]

        #expect(property === first)
        #expect(first.label == ["_1"])
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

    @Test("A literal range is a Swift value", .tags(.property))
    func literalRangeIsAValue() {
        let text: RDFS.label.Range = "Animal"
        let eve = Kinship.PersonIndividual(name: text)
        #expect(eve.name == "Animal")
        #expect(Mirror(reflecting: RDFS.Literal()).displayStyle == .struct)
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
