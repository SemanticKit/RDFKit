import IRIKit
import RDFCore
import RDFKit
import Testing

@Suite("OWL through @Ontology", .tags(.ontology, .generated))
struct OWLTests {
    @Test("An owl:Class is an rdfs:Class", .tags(.property))
    func owlClassIsAnRDFSClass() throws {
        let animal = OWL.ClassIndividual()
        let plant = OWL.ClassIndividual()
        let predator = OWL.ClassIndividual(disjointWith: [plant])

        // rdfs:subClassOf is RDFS's property; owl:Class refines rdfs:Class.
        let asRDFSClass: any RDFS.Class = predator
        asRDFSClass.subClassOf = [animal]

        let superclass = try #require(predator.subClassOf.first)
        #expect(superclass === animal)
        #expect(predator.disjointWith.first === plant)
        #expect(asRDFSClass === predator)
    }

    @Test("A restriction is an owl:Class", .tags(.property))
    func restrictionIsAClass() throws {
        let hasParent = OWL.ObjectPropertyIndividual()
        let person = OWL.ClassIndividual()
        let twoParents = OWL.RestrictionIndividual(cardinality: [2], onProperty: [hasParent])
        twoParents.subClassOf = [person]

        let asClass: any OWL.Class = twoParents
        let property = try #require(twoParents.onProperty.first)
        #expect(property === hasParent)
        #expect(twoParents.cardinality == [2])
        #expect(asClass.subClassOf.first === person)
    }

    @Test("Property characteristics are classes of object properties", .tags(.characteristic))
    func characteristicsRefineObjectProperty() throws {
        let hasAncestor = OWL.TransitivePropertyIndividual()
        let hasDescendant = OWL.TransitivePropertyIndividual(inverseOf: [hasAncestor])
        hasAncestor.inverseOf = [hasDescendant]

        let objectProperty: any OWL.ObjectProperty = hasAncestor
        let property: any RDF.Property = hasAncestor
        let inverse = try #require(objectProperty.inverseOf.first)
        let back = try #require(inverse.inverseOf.first)
        #expect(inverse === hasDescendant)
        #expect(back === hasAncestor)
        #expect(property === objectProperty)
    }

    @Test("OWL individuals relate to each other as objects", .tags(.property))
    func sameAsRelatesIndividuals() throws {
        let morningStar = OWL.ThingIndividual()
        let eveningStar = OWL.ThingIndividual(sameAs: [morningStar])
        morningStar.sameAs = [eveningStar]

        let other = try #require(morningStar.sameAs.first)
        let back = try #require(other.sameAs.first)
        #expect(other === eveningStar)
        #expect(back === morningStar)
    }

    @Test("Ontologies import and succeed each other", .tags(.property))
    func ontologiesRelate() throws {
        let rdfs = OWL.OntologyIndividual()
        let first = OWL.OntologyIndividual(imports: [rdfs])
        let second = OWL.OntologyIndividual(backwardCompatibleWith: [first], imports: [rdfs], priorVersion: [first])

        let prior = try #require(second.priorVersion.first)
        #expect(prior === first)
        #expect(second.backwardCompatibleWith.first === first)
        #expect(prior.imports.first === second.imports.first)
    }

    @Test("Another ontology's classes refine owl:Thing and keep its properties", .tags(.property))
    func foreignSubclassesKeepOWLProperties() throws {
        let eve = Kinship.PersonIndividual(name: "Eve")
        let adam = Kinship.ParentIndividual(name: "Adam", hasChild: [eve])

        // owl:sameAs is OWL's property, and rdfs:label is RDFS's.
        let thing: any OWL.Thing = adam
        thing.sameAs = [eve]
        thing.label = ["Adam"]

        let child = try #require(adam.hasChild.first)
        #expect(child === eve)
        #expect(adam.sameAs.first === eve)
        #expect(adam.label == ["Adam"])
        #expect(adam.name == "Adam")
        #expect(eve.sameAs.isEmpty)
    }

    @Test("A named individual can be an OWL class", .tags(.property))
    func namedIndividualOfOWLClass() throws {
        let animal = OWL.ClassIndividual()
        let mammal: any OWL.Class = Kinship.Mammal
        mammal.subClassOf = [animal]

        let superclass = try #require(Kinship.Mammal.subClassOf.first)
        #expect(superclass === animal)
        #expect(mammal === Kinship.Mammal)
    }

    @Test("Each term's IRI is projected from the OWL namespace", .tags(.boundary))
    func iriIsProjectedFromTheNamespace() {
        let owl = "http://www.w3.org/2002/07/owl#"
        #expect(OWL.ClassIndividual.metadata.id == IRI(owl + "Class"))
        #expect(OWL.ObjectPropertyIndividual.metadata.id == IRI(owl + "ObjectProperty"))
        #expect(OWL.sameAs.metadata.id == IRI(owl + "sameAs"))
        #expect(OWL.deprecated.metadata.id == IRI(owl + "deprecated"))
        #expect(type(of: Kinship.Mammal).metadata.id == IRI("https://kinship.example.org/ontology#Mammal"))
    }
}
