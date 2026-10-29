import Testing
import RDFCore
import RDFKit

@Suite("RDF, RDFS and OWL through @Ontology", .tags(.ontology, .generated))
struct RDFKitTests {
    @Test("rdf:nil is one list, and lists link to it")
    func listsEndAtNil() throws {
        let graph = IndividualGraph()
        let item = OWL.ThingIndividual(in: graph)
        let list = RDF.ListIndividual(in: graph, first: [item], rest: [RDF.nil])

        let rest = try #require(list.rest.first)
        #expect(rest === RDF.nil)
        #expect(list.first.first === item)
    }

    @Test("OWL individuals relate to each other as objects")
    func sameAsRelatesIndividuals() throws {
        let graph = IndividualGraph()
        let morningStar = OWL.ThingIndividual(in: graph)
        let eveningStar = OWL.ThingIndividual(in: graph, sameAs: [morningStar])
        morningStar.sameAs.append(eveningStar)

        let other = try #require(morningStar.sameAs.first)
        let back = try #require(other.sameAs.first)
        #expect(other === eveningStar)
        #expect(back === morningStar)
    }

    @Test("A class of classes is a class protocol too")
    func classesAreIndividualsOfRDFSClass() throws {
        let graph = IndividualGraph()
        let animal = RDFS.ClassIndividual(in: graph)
        let predator = RDFS.ClassIndividual(in: graph, subClassOf: [animal])

        let superclass = try #require(predator.subClassOf.first)
        #expect(superclass === animal)
    }

    @Test("An OWL class is an RDFS class, with the properties of both")
    func owlClassHasRDFSClassProperties() throws {
        let graph = IndividualGraph()
        // `OWL.Class` refines `RDFS.Class`, which another ontology declares.
        let animal = OWL.ClassIndividual(in: graph)
        let plant = OWL.ClassIndividual(in: graph)
        let predator = OWL.ClassIndividual(in: graph, disjointWith: [plant])
        predator.subClassOf.append(animal)

        let rdfsClass: any RDFS.Class = predator
        let superclass = try #require(rdfsClass.subClassOf.first)
        #expect(superclass === animal)
        #expect(predator.disjointWith.first === plant)
    }
}
