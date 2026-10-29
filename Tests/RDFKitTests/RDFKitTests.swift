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

    @Test("A property of another ontology's class reaches every individual of that class", .tags(.property))
    func propertiesOfForeignDomains() throws {
        let graph = IndividualGraph()
        // `owl:equivalentClass` and `owl:unionOf` have `rdfs:Class` as domain,
        // which RDFS declares, so OWL classes and RDFS classes both have them.
        let feline = OWL.ClassIndividual(in: graph)
        let cat = OWL.ClassIndividual(in: graph)
        let animal = RDFS.ClassIndividual(in: graph)
        let beast = RDFS.ClassIndividual(in: graph)
        let members = RDF.ListIndividual(in: graph, first: [feline], rest: [RDF.nil])

        OWL.equivalentClass.values(of: feline).append(cat)
        OWL.unionOf.values(of: feline).append(members)
        OWL.equivalentClass.values(of: animal).append(beast)

        #expect(OWL.equivalentClass.values(of: feline).first === cat)
        #expect(OWL.unionOf.values(of: feline).first === members)
        #expect(OWL.equivalentClass.values(of: animal).first === beast)
        #expect(OWL.equivalentClass.values(of: cat).isEmpty)

        // `rdfs:subPropertyOf` and `owl:equivalentProperty` have `rdf:Property`
        // as domain.
        let parent = RDF.PropertyIndividual(in: graph)
        let child = RDF.PropertyIndividual(in: graph)
        RDFS.subPropertyOf.values(of: child).append(parent)
        OWL.equivalentProperty.values(of: child).append(parent)
        #expect(RDFS.subPropertyOf.values(of: child).first === parent)
        #expect(OWL.equivalentProperty.values(of: child).first === parent)

        // `owl:onDatatype` has `rdfs:Datatype` as domain, which `owl:DataRange` refines.
        let range = OWL.DataRangeIndividual(in: graph)
        let base = RDFS.DatatypeIndividual(in: graph)
        OWL.onDatatype.values(of: range).append(base)
        #expect(OWL.onDatatype.values(of: range).first === base)
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
        let resource: some StoredIndividual = thing
        #expect(RDFS.label.values(of: resource).count == 2)
    }
}
