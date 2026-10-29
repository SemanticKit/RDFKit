import Testing
import IRIKit
import RDFCore
import RDFKit
@testable import Fauna

@Suite("Fauna ontology", .tags(.ontology))
struct FaunaTests {

    @Test("An individual is an object of its class", .tags(.generated))
    func individualIsAnObjectOfItsClass() {
        let lion = Fauna.PredatorIndividual(commonName: ["Lion"], scientificName: "Panthera leo")

        // `Fauna.Predator` refines `Fauna.Animal`: a predator is an animal.
        let animal: any Fauna.Animal = lion
        #expect(animal === lion)
        #expect(animal is any Fauna.Predator)
        #expect(!(animal is any Fauna.Prey))
        #expect(Mirror(reflecting: lion).displayStyle == .class)
    }

    @Test("One individual belongs to several classes", .tags(.generated))
    func individualBelongsToSeveralClasses() {
        // `Mesopredator` is a subclass of both `Predator` and `Prey`.
        let jackal = Fauna.MesopredatorIndividual(commonName: ["Black-backed jackal"])
        let hunter: any Fauna.Predator = jackal
        let hunted: any Fauna.Prey = jackal
        let animal: any Fauna.Animal = jackal

        #expect(hunter === hunted)
        #expect(hunted === animal)

        // A property of the shared superclass is stored once.
        hunter.commonName.append("Silver-backed jackal")
        #expect(hunted.commonName == ["Black-backed jackal", "Silver-backed jackal"])
    }

    @Test("Individuals form a cycle and keep their identity", .tags(.generated, .property))
    func cycleKeepsIdentity() throws {
        let savanna = Fauna.HabitatIndividual()
        let lion = Fauna.PredatorIndividual(hasHabitat: [savanna], commonName: ["Lion"])
        let zebra = Fauna.PreyIndividual(hasHabitat: [savanna], commonName: ["Zebra"])
        savanna.inhabitedBy = [lion, zebra]
        lion.preysOn = [zebra]

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
        #expect(zebra.commonName == ["Zebra", "Plains zebra"])
        #expect(prey.commonName == ["Zebra", "Plains zebra"])
    }

    @Test("Properties are many-valued unless they are functional", .tags(.generated, .property, .characteristic))
    func cardinality() {
        let lion = Fauna.PredatorIndividual()
        #expect(lion.commonName.isEmpty)
        #expect(lion.scientificName == nil)
        #expect(lion.hasDiet == nil)

        lion.commonName = ["Lion", "African lion"]
        lion.hasHabitat = [Fauna.HabitatIndividual(), Fauna.HabitatIndividual()]
        #expect(lion.commonName.count == 2)
        #expect(lion.hasHabitat.count == 2)

        // `scientificName`, `hasDiet` and `averageLifespan` are
        // owl:FunctionalProperty: at most one value.
        lion.scientificName = "Panthera leo"
        lion.averageLifespan = 14
        lion.hasDiet = Fauna.carnivore
        #expect(lion.scientificName == "Panthera leo")
        #expect(lion.averageLifespan == 14)
        #expect(lion.hasDiet === Fauna.carnivore)
    }

    @Test("A named individual is one object", .tags(.generated))
    func namedIndividualIsOneObject() {
        let lion = Fauna.PredatorIndividual(hasDiet: Fauna.carnivore)
        let jackal = Fauna.MesopredatorIndividual(hasDiet: Fauna.carnivore)
        let zebra = Fauna.PreyIndividual(hasDiet: Fauna.herbivore)

        #expect(lion.hasDiet === jackal.hasDiet)
        #expect(lion.hasDiet !== zebra.hasDiet)
        #expect(Fauna.omnivore !== Fauna.herbivore)
    }

    @Test("Ranges type the values", .tags(.generated, .property))
    func rangesTypeTheValues() {
        let savanna = Fauna.HabitatIndividual()
        let lion = Fauna.PredatorIndividual(hasHabitat: [savanna], scientificName: "Panthera leo", averageLifespan: 14)

        // The property term names the same types the individual stores.
        let domain: Fauna.hasHabitat.Domain = lion
        let range: Fauna.hasHabitat.Range = savanna
        let habitats = domain.hasHabitat
        #expect(habitats.first === range)

        // Literal ranges are Swift values.
        let name = lion.scientificName
        let lifespan = lion.averageLifespan
        #expect(name?.hasPrefix("Panthera") == true)
        #expect(lifespan.map { $0 + 1 } == 15)
    }

    @Test("A property term reads the same values as the class member", .tags(.generated, .property))
    func propertyTermReadsTheMemberValues() throws {
        let savanna = Fauna.HabitatIndividual()
        let lion = Fauna.PredatorIndividual(hasDiet: Fauna.carnivore)
        let animal: any Fauna.Animal = lion

        Fauna.hasHabitat[animal] = [savanna]
        #expect(try #require(lion.hasHabitat.first) === savanna)

        lion.commonName = ["Lion"]
        Fauna.commonName[lion].append("African lion")
        #expect(animal.commonName == ["Lion", "African lion"])
        #expect(Fauna.hasDiet[lion] === Fauna.carnivore)
        #expect(Fauna.preysOn[lion].isEmpty)
    }

    @Test("Datatypes are values", .tags(.generated))
    func datatypesAreValues() {
        #expect(Mirror(reflecting: XSD.nonNegativeInteger()).displayStyle == .struct)
        #expect(Mirror(reflecting: RDFS.Literal()).displayStyle == .struct)
    }

    @Test("Individuals can be shared across tasks", .tags(.generated))
    func individualsAreSendable() async {
        let savanna = Fauna.HabitatIndividual()
        let animals = (0..<20).map { _ in Fauna.PreyIndividual() }

        await withTaskGroup { group in
            for animal in animals {
                group.addTask {
                    animal.hasHabitat = [savanna]
                }
            }
        }
        #expect(animals.allSatisfy { $0.hasHabitat.first === savanna })
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
        #expect(content.filter { $0 is RDFCore.Property }.count == 7)
        #expect(content.filter { $0 is RDFCore.Individual }.count == 3)
    }

    @Test("A term's IRI is projected from the namespace at the boundary", .tags(.boundary))
    func iriIsBoundaryProjection() {
        let lion: any Fauna.Animal = Fauna.PredatorIndividual()

        #expect(Fauna.AnimalIndividual.metadata.id == IRI("https://fauna.example.org/ontology#Animal"))
        #expect(type(of: lion).metadata.id == IRI("https://fauna.example.org/ontology#Predator"))
        #expect(type(of: Fauna.carnivore).metadata.id == IRI("https://fauna.example.org/ontology#carnivore"))
        #expect(Fauna.hasHabitat.metadata.id == IRI("https://fauna.example.org/ontology#hasHabitat"))
        #expect(Fauna.hasHabitat.metadata.label == "has habitat")
    }
}
