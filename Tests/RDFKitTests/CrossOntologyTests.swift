import Testing
import RDFCore
import RDFKit

/// A class with a property in its domain, declared in one ontology.
@Ontology
struct ServiceDescription: Ontology {
    var body: some Content {
        Namespace("http://www.w3.org/ns/sparql-service-description#")
        Class("EntailmentRegime") {
            Type(RDFS.Class)
            Label("Entailment Regime")
        }
        Property("name") {
            Domain(ServiceDescription.EntailmentRegime)
            Range(RDFS.Literal)
        }
    }
}

/// A named individual typed with that class, declared in another ontology.
@Ontology
struct Entailment: Ontology {
    var body: some Content {
        Namespace("http://www.w3.org/ns/entailment/")
        Individual("RDFS") {
            Type(ServiceDescription.EntailmentRegime)
            Label("RDFS entailment")
        }
    }
}

@Suite("An individual typed with another ontology's class", .tags(.ontology, .generated))
struct CrossOntologyTests {
    @Test("is an instance of that class and stores its properties")
    func storesTheForeignClassesProperties() {
        let regime: any ServiceDescription.EntailmentRegime = Entailment.RDFS
        #expect(regime.name.isEmpty)
        regime.name = ["RDFS"]
        #expect(Entailment.RDFS.name == ["RDFS"])
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
            Range(RDFS.Literal)
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
            Range(RDFS.Literal)
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
            Range(RDFS.Literal)
        }
    }
}

/// Individuals typed with those subclasses, in a fourth ontology.
@Ontology
struct Directory: Ontology {
    var body: some Content {
        Namespace("https://directory.example.org/#")
        Individual("alice") {
            Type(People.Person)
        }
        Individual("bob") {
            Type(People.Person)
            Type(Staff.Employee)
        }
    }
}

@Suite("Individuals typed with classes that refine another ontology's class", .tags(.ontology, .generated))
struct ChainedOntologyTests {
    @Test("A class refining a third ontology's class stores the superclass's properties too")
    func storesThroughTheChain() {
        let alice: any People.Person = Directory.alice
        alice.name = ["Alice"]
        alice.nickname = ["Al"]
        let agent: any Agents.Agent = Directory.alice
        #expect(agent.name == ["Alice"])
        #expect(Directory.alice.nickname == ["Al"])
    }

    @Test("Two classes that share a superclass share its property: it is one property")
    func sharedSuperclassPropertyIsOneProperty() {
        let bob = Directory.bob
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
            Range(RDFS.Literal)
        }
    }
}

/// An individual in both domains, declared in another ontology.
@Ontology
struct Faculty: Ontology {
    var body: some Content {
        Namespace("https://faculty.example.org/#")
        Individual("carol") {
            Type(Teaching.Teacher)
            Type(Teaching.Researcher)
        }
    }
}

@Suite("A property with two domains", .tags(.ontology, .generated))
struct TwoDomainTests {
    @Test("is one property of an individual in both domains")
    func isOnePropertyInBothDomains() {
        let teacher: any Teaching.Teacher = Faculty.carol
        let researcher: any Teaching.Researcher = Faculty.carol
        teacher.office = ["B12"]
        #expect(researcher.office == ["B12"])
        researcher.office.append("Lab 3")
        #expect(teacher.office == ["B12", "Lab 3"])
    }
}
