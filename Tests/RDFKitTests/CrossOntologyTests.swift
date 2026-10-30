import Testing
import IRIKit
import RDF
import RDFCore
import RDFKit

/// A class with a property in its domain, declared in one ontology.
@Ontology
struct ServiceDescription: Ontology {
    var body: some Content {
        Namespace("http://www.w3.org/ns/sparql-service-description#")
        Class("EntailmentRegime") {
            Type(RDF.Class)
            Label("Entailment Regime")
        }
        Property("name") {
            Domain(ServiceDescription.EntailmentRegime)
            Range(RDF.Literal)
        }
    }
}

/// An individual typed with that class, declared in another module's Swift:
/// an instance of a class that conforms to the class's storing protocol.
final class EntailmentRegime: ServiceDescription.EntailmentRegimeStoring {
    let iri: IRI? = "http://www.w3.org/ns/entailment/RDFS"
    let storage = IndividualStorage()

    func encode(to encoder: any Encoder) throws {
        try storage.encode(to: encoder)
    }
}

@Suite("An individual typed with another ontology's class", .tags(.ontology, .generated))
struct CrossOntologyTests {
    @Test("is an instance of that class and stores its properties")
    func storesTheForeignClassesProperties() {
        let rdfs = EntailmentRegime()
        let regime: any ServiceDescription.EntailmentRegime = rdfs
        #expect(regime.name.isEmpty)
        regime.name = ["RDFS"]
        #expect(rdfs.name == ["RDFS"])
    }
}

/// A class with a property, declared in one ontology.
@Ontology
struct Agents: Ontology {
    var body: some Content {
        Namespace("https://agents.example.org/#")
        Class("Agent")
        Property("name") {
            Domain(Agents.Agent)
            Range(RDF.Literal)
        }
    }
}

/// A subclass of that class, with a property of its own, in a second ontology.
@Ontology
struct People: Ontology {
    var body: some Content {
        Namespace("https://people.example.org/#")
        Class("Person") {
            SubClassOf(Agents.Agent)
        }
        Property("nickname") {
            Domain(People.Person)
            Range(RDF.Literal)
        }
    }
}

/// Another subclass of it, in a third ontology.
@Ontology
struct Staff: Ontology {
    var body: some Content {
        Namespace("https://staff.example.org/#")
        Class("Employee") {
            SubClassOf(Agents.Agent)
        }
        Property("badge") {
            Domain(Staff.Employee)
            Range(RDF.Literal)
        }
    }
}

/// An individual typed with both subclasses: one Swift class that conforms
/// to the storing protocol of each.
final class PersonAndEmployee: People.PersonStoring, Staff.EmployeeStoring {
    let iri: IRI?
    let storage = IndividualStorage()

    init(iri: IRI? = nil) {
        self.iri = iri
    }

    func encode(to encoder: any Encoder) throws {
        try storage.encode(to: encoder)
    }
}

@Suite("Individuals typed with classes that refine another ontology's class", .tags(.ontology, .generated))
struct ChainedOntologyTests {
    @Test("A class refining a third ontology's class stores the superclass's properties too")
    func storesThroughTheChain() {
        let individual = People.PersonIndividual()
        let alice: any People.Person = individual
        alice.name = ["Alice"]
        alice.nickname = ["Al"]
        let agent: any Agents.Agent = individual
        #expect(agent.name == ["Alice"])
        #expect(individual.nickname == ["Al"])
    }

    @Test("Two classes that share a superclass share its property: it is one property")
    func sharedSuperclassPropertyIsOneProperty() {
        let bob = PersonAndEmployee()
        let person: any People.Person = bob
        let employee: any Staff.Employee = bob
        person.name = ["Bob"]
        #expect(employee.name == ["Bob"])
        employee.name.append("Robert")
        #expect(person.name == ["Bob", "Robert"])
        employee.badge = ["42"]
        person.nickname = ["Bobby"]
        #expect(bob.badge == ["42"])
        #expect(bob.nickname == ["Bobby"])
    }
}

/// A property with two domains: its subject is in both (RDFS, an intersection).
@Ontology
struct Teaching: Ontology {
    var body: some Content {
        Namespace("https://teaching.example.org/#")
        Class("Teacher")
        Class("Researcher")
        Property("office") {
            Domain(Teaching.Teacher)
            Domain(Teaching.Researcher)
            Range(RDF.Literal)
        }
    }
}

/// An individual in both domains.
final class TeacherAndResearcher: Teaching.TeacherStoring, Teaching.ResearcherStoring {
    let iri: IRI? = nil
    let storage = IndividualStorage()

    func encode(to encoder: any Encoder) throws {
        try storage.encode(to: encoder)
    }
}

@Suite("A property with two domains", .tags(.ontology, .generated))
struct TwoDomainTests {
    @Test("is one property of an individual in both domains")
    func isOnePropertyInBothDomains() {
        let carol = TeacherAndResearcher()
        let teacher: any Teaching.Teacher = carol
        let researcher: any Teaching.Researcher = carol
        teacher.office = ["B12"]
        #expect(researcher.office == ["B12"])
        researcher.office.append("Lab 3")
        #expect(teacher.office == ["B12", "Lab 3"])
    }
}
