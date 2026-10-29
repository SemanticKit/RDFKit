import Testing
import RDFKit

@Suite("RDF, RDFS and OWL through @Ontology", .tags(.ontology, .generated))
struct RDFKitTests {
    @Test("rdf:nil is one list, and lists link to it")
    func listsEndAtNil() throws {
        let item = OWL.ThingIndividual()
        let list = RDF.ListIndividual(first: [item], rest: [RDF.nil])

        let rest = try #require(list.rest.first)
        #expect(rest === RDF.nil)
        #expect(list.first.first === item)
    }

    @Test("OWL individuals relate to each other as objects")
    func sameAsRelatesIndividuals() throws {
        let morningStar = OWL.ThingIndividual()
        let eveningStar = OWL.ThingIndividual(sameAs: [morningStar])
        morningStar.sameAs = [eveningStar]

        let other = try #require(morningStar.sameAs.first)
        let back = try #require(other.sameAs.first)
        #expect(other === eveningStar)
        #expect(back === morningStar)
    }

    @Test("A class of classes is a class protocol too")
    func classesAreIndividualsOfRDFSClass() throws {
        let animal = RDFS.ClassIndividual()
        let predator = RDFS.ClassIndividual(subClassOf: [animal])

        let superclass = try #require(predator.subClassOf.first)
        #expect(superclass === animal)
    }
}
