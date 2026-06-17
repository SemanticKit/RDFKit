import Testing
import RDFCore
import IRIKit
import Fauna

@Suite("Fauna ontology")
struct FaunaTests {

    @Test("Classes are real types you can use")
    func classes() {
        let animal = Fauna.Animal
        let habitat = Fauna.Habitat
        let diet = Fauna.Diet
        #expect(animal.name == "Animal")
        #expect(habitat.name == "Habitat")
        #expect(diet.name == "Diet")
    }

    @Test("Properties are real types you can use")
    func properties() {
        let hasHabitat = Fauna.hasHabitat
        let hasDiet = Fauna.hasDiet
        let commonName = Fauna.commonName
        let scientificName = Fauna.scientificName
        #expect(hasHabitat.name == "hasHabitat")
        #expect(hasDiet.name == "hasDiet")
        #expect(commonName.name == "commonName")
        #expect(scientificName.name == "scientificName")
    }

    @Test("Terms have stable identity")
    func identity() {
        let a1 = Fauna.Animal
        let a2 = Fauna.Animal
        #expect(a1 == a2)
        #expect(a1.id == a1.iri)
    }
}
