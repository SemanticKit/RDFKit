import Testing
import RDFCore
import IRIKit
import Fauna

@Suite("Fauna ontology")
struct FaunaTests {

    @Test("Create an animal")
    func createAnimal() {
        let animal = Fauna.Animal()
        #expect(animal.habitat.name == "Habitat")
        #expect(animal.diet.name == "Diet")
        #expect(animal.commonName == "")
        #expect(animal.scientificName == "")
    }

    @Test("Create an animal with values")
    func createAnimalWithValues() {
        let lion = Fauna.Animal(
            habitat: Fauna.Habitat(),
            diet: Fauna.Diet(),
            commonName: "Lion",
            scientificName: "Panthera leo"
        )
        #expect(lion.commonName == "Lion")
        #expect(lion.scientificName == "Panthera leo")
    }

    @Test("callAsFunction creates new instances")
    func callAsFunction() {
        let a1 = Fauna.Animal()
        let a2 = Fauna.Animal()()
        #expect(a1.commonName == a2.commonName)
    }
}
