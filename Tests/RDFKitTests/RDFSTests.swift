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

    @Test("A declaration form has no term identity; rdfs:Class is the generated type", .tags(.boundary))
    func declarationFormsCarryNoIdentity() throws {
        // `Class("Person")` is a statement of Kinship's content, not a term:
        // only the generated RDFS.ClassIndividual projects rdfs:Class's IRI.
        let content = Kinship().content()
        let declarations = content.filter { $0 is any Declaration }
        #expect(!declarations.isEmpty)
        #expect(declarations.allSatisfy { !($0 is any Entity) })
        #expect(RDFS.ClassIndividual.metadata.id == IRI("http://www.w3.org/2000/01/rdf-schema#Class"))
        #expect(RDF.PropertyIndividual.metadata.id == IRI("http://www.w3.org/1999/02/22-rdf-syntax-ns#Property"))
    }

    @Test("Every individual can have the properties of rdfs:Resource", .tags(.property))
    func propertiesOfResource() throws {
        let graph = IndividualGraph()
        let ontology = OWL.OntologyIndividual(in: graph)
        let thing = OWL.ThingIndividual(in: graph)
        let related = OWL.ThingIndividual(in: graph)

        RDFS.label.values(of: thing).append(contentsOf: ["Morning star", RDFS.Literal("Morgenstern", languageTag: "de")])
        RDFS.comment.values(of: thing).append("The planet Venus.")
        RDFS.seeAlso.values(of: thing).append(related)
        OWL.versionInfo.values(of: ontology).append(thing)

        #expect(RDFS.label.values(of: thing).values.map(\.lexicalForm) == ["Morning star", "Morgenstern"])
        #expect(RDFS.comment.values(of: thing).first?.lexicalForm == "The planet Venus.")
        #expect(RDFS.seeAlso.values(of: thing).first === related)
        #expect(OWL.versionInfo.values(of: ontology).first === thing)

        // The values belong to the individual, not to the term: another
        // individual has none.
        #expect(RDFS.label.values(of: related).isEmpty)
        // Stored once, whichever way the individual is reached.
        let resource: some RDFS.Resource = thing
        #expect(RDFS.label.values(of: resource).count == 2)
        #expect(thing.label.count == 2)
        #expect(ontology.versionInfo.first === thing)
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
