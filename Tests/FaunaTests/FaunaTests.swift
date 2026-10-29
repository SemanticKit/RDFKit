import Testing
import IRIKit
import RDFCore
import RDFKit
@testable import Fauna

@Suite("Fauna ontology", .tags(.ontology))
struct FaunaTests {

    @Test("An individual is an object of its class", .tags(.generated))
    func individualIsAnObjectOfItsClass() {
        let graph = IndividualGraph()
        let lion = Fauna.PredatorIndividual(in: graph, commonName: ["Lion"], scientificName: "Panthera leo")

        // `Fauna.Predator` refines `Fauna.Animal`: a predator is an animal.
        let animal: any Fauna.Animal = lion
        #expect(animal === lion)
        #expect(animal is any Fauna.Predator)
        #expect(!(animal is any Fauna.Prey))
        #expect(Mirror(reflecting: lion).displayStyle == .class)
        #expect(graph.individuals.contains { $0 === lion })
    }

    @Test("One individual belongs to several classes", .tags(.generated))
    func individualBelongsToSeveralClasses() {
        let graph = IndividualGraph()
        // `Mesopredator` is a subclass of both `Predator` and `Prey`.
        let jackal = Fauna.MesopredatorIndividual(in: graph, commonName: ["Black-backed jackal"])
        let hunter: any Fauna.Predator = jackal
        let hunted: any Fauna.Prey = jackal
        let animal: any Fauna.Animal = jackal

        #expect(hunter === hunted)
        #expect(hunted === animal)

        // A property of the shared superclass is stored once.
        hunter.commonName.append("Silver-backed jackal")
        #expect(hunted.commonName.values == ["Black-backed jackal", "Silver-backed jackal"])
    }

    @Test("Individuals form a cycle and keep their identity", .tags(.generated, .property))
    func cycleKeepsIdentity() throws {
        let graph = IndividualGraph()
        let savanna = Fauna.HabitatIndividual(in: graph)
        let lion = Fauna.PredatorIndividual(in: graph, hasHabitat: [savanna], commonName: ["Lion"])
        let zebra = Fauna.PreyIndividual(in: graph, hasHabitat: [savanna], commonName: ["Zebra"])
        savanna.inhabitedBy.append(contentsOf: [lion, zebra])
        lion.preysOn.append(zebra)

        // The zebra the lion preys on is the zebra that lives in the savanna.
        let prey = try #require(lion.preysOn.first)
        let neighbour = try #require(savanna.inhabitedBy.last)
        #expect(prey === neighbour)
        #expect(prey === zebra)

        // lion -> savanna -> lion
        let home = try #require(lion.hasHabitat.first)
        let resident = try #require(home.inhabitedBy.first)
        #expect(home === savanna)
        #expect(resident === lion)

        // A change made through one path is seen through every other.
        neighbour.commonName.append("Plains zebra")
        #expect(zebra.commonName.values == ["Zebra", "Plains zebra"])
        #expect(prey.commonName.values == ["Zebra", "Plains zebra"])
    }

    @Test("A released graph frees its cycles", .tags(.generated, .property))
    func releasedCycleIsFreed() {
        weak var lion: Fauna.PredatorIndividual?
        weak var savanna: Fauna.HabitatIndividual?
        weak var released: IndividualGraph?
        weak var diet: TrackedDiet?
        do {
            let graph = IndividualGraph()
            let home = Fauna.HabitatIndividual(in: graph)
            let hunter = Fauna.PredatorIndividual(in: graph, hasHabitat: [home])
            home.inhabitedBy.append(hunter)
            hunter.preysOn.append(hunter)
            // The cycle holds a value that is not an individual of the graph.
            let tracked = TrackedDiet()
            hunter.hasDiet.replace(with: tracked)
            lion = hunter
            savanna = home
            released = graph
            diet = tracked
            #expect(lion != nil)
            #expect(savanna != nil)
        }
        #expect(lion == nil)
        #expect(savanna == nil)
        #expect(released == nil)
        // The values the cycle held are freed with it.
        #expect(diet == nil)
    }

    @Test("An individual keeps its graph and what it links to", .tags(.generated, .property))
    func individualKeepsItsGraph() throws {
        weak var released: IndividualGraph?
        func makeLion() -> Fauna.PredatorIndividual {
            // The graph is dropped when this returns; the lion still holds it.
            let graph = IndividualGraph()
            released = graph
            let savanna = Fauna.HabitatIndividual(in: graph)
            let lion = Fauna.PredatorIndividual(in: graph, hasHabitat: [savanna], commonName: ["Lion"])
            savanna.inhabitedBy.append(lion)
            return lion
        }

        do {
            let lion = makeLion()
            let home = try #require(lion.hasHabitat.first)
            let resident = try #require(home.inhabitedBy.first)
            #expect(resident === lion)
            #expect(lion.commonName.values == ["Lion"])
            #expect(released != nil)

            // A property view keeps the graph too.
            let names = lion.commonName
            withExtendedLifetime(names) {}
        }
        #expect(released == nil)
    }

    @Test("A class that refines another ontology's class has that class's properties", .tags(.generated, .property))
    func foreignSuperclassRequirements() throws {
        let graph = IndividualGraph()
        // `Fauna.Habitat` refines `OWL.Thing`, so a habitat has owl:sameAs
        // and owl:differentFrom, which OWL declares.
        let serengeti = Fauna.HabitatIndividual(in: graph)
        let savanna = Fauna.HabitatIndividual(in: graph)
        let desert = Fauna.HabitatIndividual(in: graph)
        serengeti.sameAs.append(savanna)
        serengeti.differentFrom.append(desert)

        let thing: any OWL.Thing = serengeti
        let same = try #require(thing.sameAs.first)
        #expect(same === savanna)
        #expect(thing.differentFrom.first === desert)
        #expect(savanna.sameAs.isEmpty)
    }

    @Test("Every individual has the properties of rdfs:Resource", .tags(.generated, .property))
    func resourceProperties() {
        let graph = IndividualGraph()
        let lion = Fauna.PredatorIndividual(in: graph, commonName: ["Lion"])
        let savanna = Fauna.HabitatIndividual(in: graph)

        // rdfs:label and rdfs:seeAlso have rdfs:Resource as domain, which
        // RDFS declares: a Fauna individual has them too.
        RDFS.label.values(of: lion).append(RDFS.Literal("Löwe", languageTag: "de"))
        RDFS.seeAlso.values(of: lion).append(savanna)

        #expect(RDFS.label.values(of: lion).values.map(\.lexicalForm) == ["Löwe"])
        #expect(RDFS.seeAlso.values(of: lion).first === savanna)
        // A label is not a common name: each property has its own values.
        #expect(lion.commonName.values == ["Lion"])
        #expect(RDFS.label.values(of: savanna).isEmpty)
    }

    @Test("A named individual can be of another ontology's class", .tags(.generated))
    func namedIndividualOfForeignClass() {
        let ontology: any OWL.Ontology = Fauna.faunaOntology
        #expect(ontology === Fauna.faunaOntology)
        #expect(ontology.imports.isEmpty)
        #expect(type(of: ontology).metadata.id == IRI("https://fauna.example.org/ontology#faunaOntology"))
    }

    @Test("A named individual's values are fixed", .tags(.generated, .property))
    func namedIndividualValuesAreFixed() async {
        await #expect(processExitsWith: .failure) {
            Fauna.faunaOntology.imports.append(Fauna.faunaOntology)
        }
    }

    @Test("A value links individuals of one graph", .tags(.generated, .property))
    func valuesStayInTheirGraph() async {
        await #expect(processExitsWith: .failure) {
            let lion = Fauna.PredatorIndividual(in: IndividualGraph())
            lion.hasHabitat.append(Fauna.HabitatIndividual(in: IndividualGraph()))
        }
    }

    @Test("Properties are many-valued unless they are functional", .tags(.generated, .property, .characteristic))
    func cardinality() {
        let graph = IndividualGraph()
        let lion = Fauna.PredatorIndividual(in: graph)
        #expect(lion.commonName.isEmpty)
        #expect(lion.scientificName.value == nil)
        #expect(lion.hasDiet.value == nil)

        lion.commonName.replace(with: ["Lion", "African lion"])
        lion.hasHabitat.append(contentsOf: [Fauna.HabitatIndividual(in: graph), Fauna.HabitatIndividual(in: graph)])
        #expect(lion.commonName.count == 2)
        #expect(lion.hasHabitat.count == 2)

        // `scientificName`, `hasDiet` and `averageLifespan` are
        // owl:FunctionalProperty: at most one value.
        lion.scientificName.replace(with: "Panthera leo")
        lion.averageLifespan.replace(with: "14")
        lion.hasDiet.replace(with: Fauna.carnivore)
        #expect(lion.scientificName.value == "Panthera leo")
        #expect(lion.averageLifespan.value == "14")
        #expect(lion.hasDiet.value === Fauna.carnivore)
    }

    @Test("A named individual is one object", .tags(.generated))
    func namedIndividualIsOneObject() {
        let graph = IndividualGraph()
        let lion = Fauna.PredatorIndividual(in: graph, hasDiet: Fauna.carnivore)
        let jackal = Fauna.MesopredatorIndividual(in: graph, hasDiet: Fauna.carnivore)
        let zebra = Fauna.PreyIndividual(in: graph, hasDiet: Fauna.herbivore)

        #expect(lion.hasDiet.value === jackal.hasDiet.value)
        #expect(lion.hasDiet.value !== zebra.hasDiet.value)
        #expect(Fauna.omnivore !== Fauna.herbivore)
    }

    @Test("Ranges type the values", .tags(.generated, .property))
    func rangesTypeTheValues() {
        let graph = IndividualGraph()
        let savanna = Fauna.HabitatIndividual(in: graph)
        let lion = Fauna.PredatorIndividual(in: graph, hasHabitat: [savanna], scientificName: "Panthera leo", averageLifespan: "14")

        // The property term names the same types the individual stores.
        let domain: Fauna.hasHabitat.Domain = lion
        let range: Fauna.hasHabitat.Range = savanna
        #expect(domain.hasHabitat.first === range)

        // Literal ranges are the datatypes' value types.
        let name: Fauna.scientificName.Range? = lion.scientificName.value
        let lifespan: XSD.nonNegativeInteger? = lion.averageLifespan.value
        #expect(name?.lexicalForm.hasPrefix("Panthera") == true)
        #expect(lifespan?.lexicalForm == "14")
    }

    @Test("A declared datatype stores its literal", .tags(.generated, .property))
    func datatypeStoresItsLiteral() throws {
        let graph = IndividualGraph()
        let lion = Fauna.PredatorIndividual(in: graph, averageMass: Fauna.Kilograms("190.5"))
        let zebra = Fauna.PreyIndividual(in: graph, commonName: [RDFS.Literal("Zebra", languageTag: "en"), RDFS.Literal("Zebra", languageTag: "de")])

        let mass = try #require(lion.averageMass.value)
        #expect(mass.lexicalForm == "190.5")
        #expect(mass == "190.5")
        #expect(Mirror(reflecting: mass).displayStyle == .struct)
        #expect(zebra.commonName.values.map(\.languageTag) == ["en", "de"])
        #expect(zebra.commonName.first != zebra.commonName.last)
    }

    @Test("Datatypes are values", .tags(.generated))
    func datatypesAreValues() {
        var lifespan = XSD.nonNegativeInteger("14")
        let copy = lifespan
        lifespan.lexicalForm = "15"
        #expect(copy.lexicalForm == "14")
        #expect(Mirror(reflecting: copy).displayStyle == .struct)
        #expect(Mirror(reflecting: RDFS.Literal("Lion")).displayStyle == .struct)
    }

    @Test("Individuals can be shared across tasks", .tags(.generated))
    func individualsAreSendable() async {
        let graph = IndividualGraph()
        let savanna = Fauna.HabitatIndividual(in: graph)
        let animals = (0..<20).map { _ in Fauna.PreyIndividual(in: graph) }

        await withTaskGroup { group in
            for animal in animals {
                group.addTask {
                    animal.hasHabitat.replace(with: [savanna])
                }
            }
        }
        #expect(animals.allSatisfy { $0.hasHabitat.first === savanna })
    }

    @Test("Concurrent changes to one property all land", .tags(.generated, .property))
    func concurrentAppendsAreAtomic() async {
        let graph = IndividualGraph()
        let savanna = Fauna.HabitatIndividual(in: graph)
        let count = 2000

        await withTaskGroup { group in
            for _ in 0..<count {
                group.addTask {
                    savanna.inhabitedBy.append(Fauna.PreyIndividual(in: graph))
                }
            }
        }
        #expect(savanna.inhabitedBy.count == count)
        #expect(graph.individuals.count == count + 1)
    }

    @Test("Multi-line annotation text survives expansion", .tags(.generated))
    func multiLineCommentIsPreserved() {
        #expect(Fauna.preysOn.metadata.comment == """
            An animal this predator hunts for food.
            Its range is "Animal", so a predator can prey on another predator.
            """)
        #expect(Fauna.preysOn.metadata.label == "preys on")
    }

    @Test("content() returns the authored declarations", .tags(.ontology))
    func contentReturnsDeclarations() {
        let content = Fauna().content()
        #expect(content.filter { $0 is RDFCore.Class }.count == 6)
        #expect(content.filter { $0 is RDFCore.Datatype }.count == 1)
        #expect(content.filter { $0 is RDFCore.Property }.count == 8)
        #expect(content.filter { $0 is RDFCore.Individual }.count == 4)
    }

    @Test("A term's IRI is projected from the namespace at the boundary", .tags(.boundary))
    func iriIsBoundaryProjection() {
        let lion: any Fauna.Animal = Fauna.PredatorIndividual(in: IndividualGraph())

        #expect(Fauna.AnimalIndividual.metadata.id == IRI("https://fauna.example.org/ontology#Animal"))
        #expect(type(of: lion).metadata.id == IRI("https://fauna.example.org/ontology#Predator"))
        #expect(type(of: Fauna.carnivore).metadata.id == IRI("https://fauna.example.org/ontology#carnivore"))
        #expect(Fauna.Kilograms.metadata.id == IRI("https://fauna.example.org/ontology#Kilograms"))
        #expect(Fauna.hasHabitat.metadata.id == IRI("https://fauna.example.org/ontology#hasHabitat"))
        #expect(Fauna.hasHabitat.metadata.label == "has habitat")
    }
}

/// A diet that is not an individual of any graph, so that a test can see
/// when the values an individual stores are freed. Like a named individual,
/// it has a fixed membership in no graph, which gives it the properties every
/// resource has (`label`, `comment`, ...).
private final class TrackedDiet: Fauna.Diet, StoredIndividual {
    static let metadata: any ContentMetadata = Fauna.DietIndividual.metadata
    let membership = Membership.fixed()
}
