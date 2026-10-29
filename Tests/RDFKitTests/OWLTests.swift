import IRIKit
import RDFCore
import RDFKit
import Testing

@Suite("OWL through @Ontology", .tags(.ontology, .generated))
struct OWLTests {
    @Test("An owl:Class is an rdfs:Class", .tags(.property))
    func owlClassIsAnRDFSClass() throws {
        let graph = IndividualGraph()
        let animal = OWL.ClassIndividual(in: graph)
        let plant = OWL.ClassIndividual(in: graph)
        let predator = OWL.ClassIndividual(in: graph, disjointWith: [plant])

        // rdfs:subClassOf is RDFS's property; owl:Class refines rdfs:Class.
        let asRDFSClass: any RDFS.Class = predator
        asRDFSClass.subClassOf.append(animal)

        let superclass = try #require(predator.subClassOf.first)
        #expect(superclass === animal)
        #expect(predator.disjointWith.first === plant)
        #expect(asRDFSClass === predator)
    }

    @Test("owl:equivalentClass relates every rdfs:Class", .tags(.property))
    func equivalentClassRelatesClasses() throws {
        // OWL declares owl:equivalentClass for rdfs:Class, which RDFS declares.
        let graph = IndividualGraph()
        let human = OWL.ClassIndividual(in: graph)
        let person = RDFS.ClassIndividual(in: graph)
        human.equivalentClass.append(person)
        person.equivalentClass.append(human)

        let asRDFSClass: any RDFS.Class = human
        let equivalent = try #require(asRDFSClass.equivalentClass.first)
        #expect(equivalent === person)
        #expect(person.equivalentClass.first === human)
        #expect(human.subClassOf.isEmpty)
    }

    @Test("OWL's properties for rdfs:Resource apply to every resource", .tags(.property))
    func versionInfoAppliesToEveryResource() throws {
        // OWL declares owl:versionInfo for rdfs:Resource, which RDFS declares,
        // so an individual of any vocabulary's class has it.
        let graph = IndividualGraph()
        let schema = RDFS.ResourceIndividual(in: graph)
        let list = RDF.ListIndividual(in: graph)
        schema.versionInfo.append(RDF.version_1_2)
        list.versionInfo.append(RDF.version_1_1)

        let resources: [any RDFS.Resource] = [schema, list]
        #expect(resources[0].versionInfo.first === RDF.version_1_2)
        #expect(resources[1].versionInfo.first === RDF.version_1_1)
        #expect(RDF.version_1_2.versionInfo.isEmpty)
    }

    @Test("A restriction is an owl:Class", .tags(.property))
    func restrictionIsAClass() throws {
        let graph = IndividualGraph()
        let hasParent = OWL.ObjectPropertyIndividual(in: graph)
        let person = OWL.ClassIndividual(in: graph)
        let twoParents = OWL.RestrictionIndividual(in: graph, cardinality: ["2"], onProperty: [hasParent])
        twoParents.subClassOf.append(person)

        let asClass: any OWL.Class = twoParents
        let property = try #require(twoParents.onProperty.first)
        #expect(property === hasParent)
        #expect(twoParents.cardinality.values == ["2"])
        #expect(asClass.subClassOf.first === person)
    }

    @Test("Property characteristics are classes of object properties", .tags(.characteristic))
    func characteristicsRefineObjectProperty() throws {
        let graph = IndividualGraph()
        let hasAncestor = OWL.TransitivePropertyIndividual(in: graph)
        let hasDescendant = OWL.TransitivePropertyIndividual(in: graph, inverseOf: [hasAncestor])
        hasAncestor.inverseOf.append(hasDescendant)

        let objectProperty: any OWL.ObjectProperty = hasAncestor
        let property: any RDF.Property = hasAncestor
        let inverse = try #require(objectProperty.inverseOf.first)
        let back = try #require(inverse.inverseOf.first)
        #expect(inverse === hasDescendant)
        #expect(back === hasAncestor)
        #expect(property === objectProperty)
    }

    @Test("A named property can be of two classes of another ontology", .tags(.characteristic))
    func namedIndividualOfTwoForeignClasses() throws {
        // Kinship.relativeOf is an owl:TransitiveProperty and an
        // owl:SymmetricProperty; both refine owl:ObjectProperty and rdf:Property.
        let transitive: any OWL.TransitiveProperty = Kinship.relativeOf
        let symmetric: any OWL.SymmetricProperty = Kinship.relativeOf
        let property: any RDF.Property = Kinship.relativeOf
        #expect(transitive === symmetric)
        #expect(property.domain.isEmpty)
        #expect(symmetric.inverseOf.isEmpty)

        // A graph's properties can be subproperties of it.
        let graph = IndividualGraph()
        let cousinOf = OWL.SymmetricPropertyIndividual(in: graph)
        cousinOf.subPropertyOf.append(Kinship.relativeOf)
        let parent = try #require(cousinOf.subPropertyOf.first)
        #expect(parent === Kinship.relativeOf)
    }

    @Test("A property with two domains of another ontology applies to their intersection, with one store", .tags(.characteristic, .property))
    func propertyWithTwoForeignDomains() throws {
        // Kinship declares degree for owl:TransitiveProperty and
        // owl:SymmetricProperty: only a relation that is both has it.
        let graph = IndividualGraph()
        let siblingOf = Kinship.FamilyRelationIndividual(in: graph)
        siblingOf.degree.append("1")

        func degrees<R: OWL.TransitiveProperty & OWL.SymmetricProperty & Kinship.Extending>(of relation: R) -> [XSD.nonNegativeInteger] {
            relation.degree.values
        }
        let asFamilyRelation: any Kinship.FamilyRelation = siblingOf
        let asBoth: any OWL.TransitiveProperty & OWL.SymmetricProperty & Kinship.Extending = siblingOf

        // Written through the individual, read through every view: the same values.
        #expect(degrees(of: siblingOf) == ["1"])
        #expect(asFamilyRelation.degree.values == ["1"])
        #expect(asBoth.degree.values == ["1"])
        asBoth.degree.append("2")
        #expect(siblingOf.degree.values == ["1", "2"])

        // relativeOf is of both classes, so it has a degree too.
        #expect(Kinship.relativeOf.degree.isEmpty)
    }

    @Test("A named individual of another ontology's class has its own ontology's properties for that class", .tags(.property))
    func namedIndividualOfForeignClassHasLocalProperties() throws {
        // Kinship declares coverage for owl:Ontology, and names itself as an
        // owl:Ontology individual.
        let ontology: any OWL.Ontology = Kinship.kinshipOntology
        #expect(Kinship.kinshipOntology.coverage.isEmpty)
        #expect(ontology === Kinship.kinshipOntology)
        #expect(type(of: Kinship.kinshipOntology).metadata.id == IRI("https://kinship.example.org/ontology#kinshipOntology"))

        // The named individual is in Kinship's extension point, which gives it coverage.
        let extending: any Kinship.Extending = Kinship.kinshipOntology
        #expect(extending === Kinship.kinshipOntology)
    }

    @Test("A class can refine two classes of another ontology", .tags(.characteristic))
    func classRefiningTwoForeignClasses() throws {
        let graph = IndividualGraph()
        let person = OWL.ClassIndividual(in: graph)
        let cousinOf = Kinship.FamilyRelationIndividual(in: graph)
        let transitive: any OWL.TransitiveProperty = cousinOf
        let symmetric: any OWL.SymmetricProperty = cousinOf
        let property: any RDF.Property = cousinOf
        transitive.range.append(person)
        symmetric.label.append("cousin of")

        let range = try #require(property.range.first)
        #expect(range === person)
        #expect(property.label.values == ["cousin of"])
        #expect(symmetric.range.count == 1)
    }

    @Test("OWL individuals relate to each other as objects", .tags(.property))
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

    @Test("Ontologies import and succeed each other", .tags(.property))
    func ontologiesRelate() throws {
        let graph = IndividualGraph()
        let rdfs = OWL.OntologyIndividual(in: graph)
        let first = OWL.OntologyIndividual(in: graph, imports: [rdfs])
        let second = OWL.OntologyIndividual(in: graph, backwardCompatibleWith: [first], imports: [rdfs], priorVersion: [first])

        let prior = try #require(second.priorVersion.first)
        #expect(prior === first)
        #expect(second.backwardCompatibleWith.first === first)
        #expect(prior.imports.first === second.imports.first)
    }

    @Test("Another ontology's classes refine owl:Thing and keep its properties", .tags(.property))
    func foreignSubclassesKeepOWLProperties() throws {
        let graph = IndividualGraph()
        let eve = Kinship.PersonIndividual(in: graph, name: "Eve")
        let adam = Kinship.ParentIndividual(in: graph, name: "Adam", hasChild: [eve])

        // owl:sameAs is OWL's property, and rdfs:label is RDFS's.
        let thing: any OWL.Thing = adam
        thing.sameAs.append(eve)
        thing.label.append("Adam")

        let child = try #require(adam.hasChild.first)
        #expect(child === eve)
        #expect(adam.sameAs.first === eve)
        #expect(adam.label.values == ["Adam"])
        #expect(adam.name.value == "Adam")
        #expect(eve.sameAs.isEmpty)
    }

    @Test("A named individual can be an OWL class", .tags(.property))
    func namedIndividualOfOWLClass() throws {
        let graph = IndividualGraph()
        let cat = OWL.ClassIndividual(in: graph)
        let mammal: any OWL.Class = Kinship.Mammal
        cat.subClassOf.append(mammal)

        let superclass = try #require(cat.subClassOf.first)
        #expect(superclass === Kinship.Mammal)
        #expect(Kinship.Mammal.subClassOf.isEmpty)
    }

    @Test("Each term's IRI is projected from the OWL namespace", .tags(.boundary))
    func iriIsProjectedFromTheNamespace() {
        let owl = "http://www.w3.org/2002/07/owl#"
        #expect(OWL.ClassIndividual.metadata.id == IRI(owl + "Class"))
        #expect(OWL.ObjectPropertyIndividual.metadata.id == IRI(owl + "ObjectProperty"))
        #expect(OWL.sameAs.metadata.id == IRI(owl + "sameAs"))
        #expect(OWL.deprecated.metadata.id == IRI(owl + "deprecated"))
        #expect(type(of: Kinship.Mammal).metadata.id == IRI("https://kinship.example.org/ontology#Mammal"))
        #expect(type(of: Kinship.relativeOf).metadata.id == IRI("https://kinship.example.org/ontology#relativeOf"))
    }
}
