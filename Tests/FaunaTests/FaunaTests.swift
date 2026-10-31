import Foundation
import Testing
import RDFCore
import RDFFormats
import RDFKit
import XSD
@testable import Fauna

/// Direction step 1: `@Ontology` turns Fauna's declarations into the Swift
/// types an app works with. Domain and Range become typed stored
/// properties, SubClassOf becomes conformance, and Label and Comment become
/// DocC. The IRIs exist only where the ontology and its individuals are
/// encoded.
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
        let fauna = Fauna()
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
        lion.hasDiet = fauna.carnivore
        #expect(lion.scientificName == "Panthera leo")
        #expect(lion.averageLifespan == 14)
        #expect(lion.hasDiet === fauna.carnivore)
    }

    @Test("A named individual is one object", .tags(.generated))
    func namedIndividualIsOneObject() {
        let fauna = Fauna()
        let lion = Fauna.PredatorIndividual(hasDiet: fauna.carnivore)
        let jackal = Fauna.MesopredatorIndividual(hasDiet: Fauna().carnivore)
        let zebra = Fauna.PreyIndividual(hasDiet: fauna.herbivore)

        #expect(lion.hasDiet === jackal.hasDiet)
        #expect(lion.hasDiet !== zebra.hasDiet)
        #expect(fauna.omnivore !== fauna.herbivore)
        #expect(fauna.carnivore is any Fauna.Diet)
    }

    @Test("Ranges type the values", .tags(.generated, .property))
    func rangesTypeTheValues() {
        let savanna = Fauna.HabitatIndividual()
        let lion = Fauna.PredatorIndividual(hasHabitat: [savanna], scientificName: "Panthera leo", averageLifespan: 14)

        // An object-ranged property holds the individuals themselves.
        let habitats: [any Fauna.Habitat] = lion.hasHabitat
        #expect(habitats.first === savanna)

        // An XSD-ranged property holds the datatype's Swift value type.
        let lifespan: XSD.nonNegativeInteger? = lion.averageLifespan
        #expect(lifespan == 14)
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

    @Test("body returns the authored declarations", .tags(.ontology))
    func bodyReturnsDeclarations() {
        let content = Fauna().body.entities
        #expect(content.filter { $0 is RDFCore.Class }.count == 6)
        #expect(content.filter { $0 is RDFCore.Property }.count == 7)
        #expect(content.filter { $0 is RDFCore.Individual }.count == 3)
    }

    @Test("The ontology translates back to the graph it declares", .tags(.boundary))
    func ontologyTranslatesBack() throws {
        let expected = try TurtleDecoder().decode(try fixture("fauna.ttl"))
        let output = try TurtleDecoder().decode(try TurtleEncoder().encode(Fauna().ontology))
        #expect(output.isIsomorphic(to: expected))
    }

    @Test("An individual's IRIs appear only where it is encoded", .tags(.boundary))
    func individualEncodes() throws {
        let fauna = Fauna()
        let lion = Fauna.PredatorIndividual(
            hasHabitat: [Fauna.HabitatIndividual()],
            hasDiet: fauna.carnivore,
            commonName: ["Lion"],
            scientificName: "Panthera leo",
            averageLifespan: 14
        )
        let expected = try TurtleDecoder().decode(try fixture("lion.ttl"))
        let output = try TurtleDecoder().decode(try TurtleEncoder().encode([lion]))
        #expect(output.isIsomorphic(to: expected))
    }

    private func fixture(_ name: String) throws -> String {
        let url = URL(filePath: #filePath).deletingLastPathComponent().appending(path: "Fixtures/\(name)")
        return try String(contentsOf: url, encoding: .utf8)
    }
}
