import Testing
import RDFCore
import RDFKit
import Fauna

@Suite("Properties of two ontologies with the same name", .tags(.ontology))
struct ZooTests {
    @Test("A class refining another ontology's class keeps both same-named properties apart", .tags(.generated, .property))
    func sameNamedPropertiesStayApart() {
        let leo = Zoo.ResidentIndividual(commonName: ["Leo"])
        let animal: any Fauna.Animal = leo
        let resident: any Zoo.Resident = leo

        // Written through the Fauna class: only fauna:commonName changes.
        animal.commonName = ["Lion"]
        #expect(animal.commonName == ["Lion"])
        #expect(Fauna.commonName[leo] == ["Lion"])
        #expect(resident.commonName == ["Leo"])
        #expect(Zoo.commonName[leo] == ["Leo"])

        // Written through the Zoo term: only zoo:commonName changes.
        Zoo.commonName[leo] = ["Leo the Lion"]
        #expect(resident.commonName == ["Leo the Lion"])
        #expect(animal.commonName == ["Lion"])
        #expect(Fauna.commonName[leo] == ["Lion"])
    }

    @Test("The individual type of the refining class is an individual of both classes", .tags(.generated))
    func individualOfBothClasses() {
        let leo: any RDFCore.Resource = Zoo.ResidentIndividual()
        #expect(leo is any Fauna.Animal)
        #expect(leo is any Zoo.Resident)
        #expect(!(leo is any Fauna.Predator))
    }
}
