import Testing
import RDFCore
import IRIKit
import Fauna

@Suite("Fauna ontology")
struct FaunaTests {

    @Test("Create an animal and use it")
    func createAnimal() {
        let animal = Fauna.Animal()
        #expect(animal.habitat == Fauna.Habitat())
        #expect(animal.diet == Fauna.Diet())
        #expect(animal.commonName == "")
        #expect(animal.scientificName == "")
    }
}
