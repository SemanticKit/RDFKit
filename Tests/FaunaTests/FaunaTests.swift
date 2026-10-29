import Testing
import IRIKit
import RDFCore
import RDFKit
@testable import Fauna

@Suite("Fauna ontology", .tags(.ontology))
struct FaunaTests {

    @Test("Create an animal and use it", .tags(.generated))
    func createAnimal() {
        let lion = Fauna.Animal(
            habitat: Fauna.Habitat(),
            diet: Fauna.Diet(),
            commonName: "Lion",
            scientificName: "Panthera leo"
        )

        // Use the animal in a real scenario
        let description = "\(lion.commonName) (\(lion.scientificName))"
        #expect(description == "Lion (Panthera leo)")
    }

    @Test("Relationships are stored as their range types", .tags(.generated, .property))
    func relationshipsAreTypedByRange() {
        // Habitat and Diet carry no stored state yet, so these are values of
        // the range types, not distinct individuals.
        let habitat = Fauna.Habitat()
        let diet = Fauna.Diet()
        let lion = Fauna.Animal(
            habitat: habitat,
            diet: diet,
            commonName: "Lion",
            scientificName: "Panthera leo"
        )

        // The declared ranges are the stored types: this only compiles if
        // `hasHabitat` is a `Fauna.Habitat` and `hasDiet` a `Fauna.Diet`.
        let storedHabitat: Fauna.Habitat = lion.hasHabitat
        let storedDiet: Fauna.Diet = lion.hasDiet
        let prey: Fauna.Animal? = lion.preysOn
        _ = (storedHabitat, storedDiet)
        #expect(prey == nil)

        // Nothing an animal stores is an identifier standing in for a term.
        let stored = Mirror(reflecting: lion).children.map(\.value)
        #expect(stored.count == 5)
        #expect(!stored.contains { $0 is IRI })
        #expect(stored.filter { $0 is String }.count == 2)
    }

    @Test("A property whose range is its own domain builds a finite chain", .tags(.generated, .property))
    func selfReferentialRangeIsConstructible() throws {
        let zebra = Fauna.Animal(
            habitat: Fauna.Habitat(),
            diet: Fauna.Diet(),
            commonName: "Zebra",
            scientificName: "Equus quagga"
        )
        let lion = Fauna.Animal(
            habitat: Fauna.Habitat(),
            diet: Fauna.Diet(),
            preysOn: zebra,
            commonName: "Lion",
            scientificName: "Panthera leo"
        )

        // The stored value is typed by the range, `Fauna.Animal`.
        let prey: Fauna.Animal = try #require(lion.preysOn)
        #expect(prey.commonName == "Zebra")
        #expect(prey.preysOn == nil)

        // Values are stored out of line, so changing one copy leaves the other.
        var hungry = lion
        hungry.preysOn = nil
        #expect(hungry.preysOn == nil)
        #expect(lion.preysOn?.scientificName == "Equus quagga")

        let range: Fauna.preysOn.Range = zebra
        let domain: Fauna.preysOn.Domain = lion
        _ = (range, domain)
    }

    @Test("Multi-line annotation text survives expansion", .tags(.generated))
    func multiLineCommentIsPreserved() {
        #expect(Fauna.preysOn.metadata.comment == """
            An animal this animal hunts for food.
            Its range is "Animal", the property's own domain.
            """)
        #expect(Fauna.preysOn.metadata.label == "preys on")
    }

    @Test("Property declarations relate terms as types", .tags(.property))
    func declarationsRelateTypes() throws {
        let declarations = Fauna().content.compactMap { $0 as? RDFCore.Property }
        let hasHabitat = try #require(declarations.first { $0.localName == "hasHabitat" })

        #expect(hasHabitat.content.contains { $0 is Domain<Fauna.Animal> })
        #expect(hasHabitat.content.contains { $0 is Range<Fauna.Habitat> })
        #expect(!hasHabitat.content.contains { $0 is Range<Fauna.Diet> })

        // The generated property term names the same types.
        let range: Fauna.hasHabitat.Range = Fauna.Habitat()
        let domain: Fauna.hasHabitat.Domain = Fauna.Animal(
            habitat: range,
            diet: Fauna.Diet(),
            commonName: "Lion",
            scientificName: "Panthera leo"
        )
        #expect(domain.commonName == "Lion")
    }

    @Test("Every declared class becomes a generated type", .tags(.generated))
    func everyClassIsGenerated() {
        let classes = Fauna().content.compactMap { $0 as? RDFCore.Class }.map(\.localName)
        #expect(classes == ["Animal", "Habitat", "Diet"])

        let generated = [Fauna.Animal.metadata.name, Fauna.Habitat.metadata.name, Fauna.Diet.metadata.name]
        #expect(generated == classes)
    }

    @Test("A term's IRI is projected from the namespace at the boundary", .tags(.boundary))
    func iriIsBoundaryProjection() throws {
        let namespace = try #require(Fauna().content.compactMap { $0 as? Namespace }.first)

        #expect(namespace.iri == IRI("https://fauna.example.org/ontology#"))
        #expect(Fauna.Animal.metadata.id == IRI("https://fauna.example.org/ontology#Animal"))
        #expect(Fauna.Habitat.metadata.id == IRI("https://fauna.example.org/ontology#Habitat"))
        #expect(Fauna.hasHabitat.metadata.id == IRI("https://fauna.example.org/ontology#hasHabitat"))
        #expect(Fauna.hasHabitat.metadata.label == "has habitat")
    }
}
