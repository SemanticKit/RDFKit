import Testing
import RDFCore
import IRIKit
@testable import Fauna

@Suite("Fauna ontology")
struct FaunaTests {

    @Test("Create an animal and use it")
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
}
