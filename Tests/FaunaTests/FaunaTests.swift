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
        let savanna = Fauna.Habitat()
        let carnivore = Fauna.Diet()
        let lion = Fauna.Animal(
            habitat: savanna,
            diet: carnivore,
            commonName: "Lion",
            scientificName: "Panthera leo"
        )

        // The declared ranges are the stored types: this only compiles if
        // `hasHabitat` is a `Fauna.Habitat` and `hasDiet` a `Fauna.Diet`.
        let habitat: Fauna.Habitat = lion.hasHabitat
        let diet: Fauna.Diet = lion.hasDiet
        _ = (habitat, diet)

        // Nothing an animal stores is an identifier standing in for a term.
        let stored = Mirror(reflecting: lion).children.map(\.value)
        #expect(stored.count == 4)
        #expect(!stored.contains { $0 is IRI })
        #expect(stored.filter { $0 is String }.count == 2)
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
