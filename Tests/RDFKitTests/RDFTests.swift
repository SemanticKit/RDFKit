import IRIKit
import RDFCore
import RDFKit
import Testing

@Suite("RDF through @Ontology", .tags(.ontology, .generated))
struct RDFTests {
    @Test("rdf:nil is one list, and lists link to it", .tags(.property))
    func listsEndAtNil() throws {
        let graph = IndividualGraph()
        let item = OWL.ThingIndividual(in: graph)
        let list = RDF.ListIndividual(in: graph, first: [item], rest: [RDF.nil])

        let rest = try #require(list.rest.first)
        #expect(rest === RDF.nil)
        #expect(list.first.first === item)
        #expect(RDF.nil.first.isEmpty)
    }

    @Test("A statement's parts are the individuals themselves", .tags(.property))
    func statementPartsAreIndividuals() throws {
        let graph = IndividualGraph()
        let lion = OWL.ThingIndividual(in: graph)
        let zebra = OWL.ThingIndividual(in: graph)
        let preysOn = OWL.ObjectPropertyIndividual(in: graph)
        let statement = RDF.StatementIndividual(in: graph, object: [zebra], predicate: [preysOn], subject: [lion])

        let predicate = try #require(statement.predicate.first)
        #expect(statement.subject.first === lion)
        #expect(predicate === preysOn)
        #expect(statement.object.first === zebra)
    }

    @Test("A list can hold itself, and its graph frees the cycle", .tags(.property))
    func listsFormCycles() throws {
        weak var released: RDF.ListIndividual?
        do {
            let graph = IndividualGraph()
            let list = RDF.ListIndividual(in: graph)
            list.first.append(list)
            list.rest.append(list)
            released = list

            let rest = try #require(list.rest.first)
            let head = try #require(rest.first.first)
            #expect(rest === list)
            #expect(head === list)
        }
        #expect(released == nil)
    }

    @Test("rdfs:domain and rdfs:range are properties of every rdf:Property", .tags(.property))
    func propertiesHaveDomainsAndRanges() throws {
        // RDFS declares rdfs:domain and rdfs:range for rdf:Property, which RDF declares.
        let graph = IndividualGraph()
        let person = RDFS.ClassIndividual(in: graph)
        let place = RDFS.ClassIndividual(in: graph)
        let livesIn = RDF.PropertyIndividual(in: graph)
        let residesIn = RDF.PropertyIndividual(in: graph)
        livesIn.domain.append(person)
        livesIn.range.append(place)
        residesIn.subPropertyOf.append(livesIn)

        let property: any RDF.Property = try #require(residesIn.subPropertyOf.first)
        #expect(property === livesIn)
        #expect(property.domain.first === person)
        #expect(property.range.first === place)
        #expect(residesIn.domain.isEmpty)
    }

    @Test("rdf:value is a property of every resource", .tags(.property))
    func everyResourceHasAValue() throws {
        // RDF declares rdf:value for rdfs:Resource, which RDFS declares.
        let graph = IndividualGraph()
        let kilograms = RDFS.ResourceIndividual(in: graph)
        let weight = OWL.ThingIndividual(in: graph)
        weight.value.append(kilograms)

        #expect(weight.value.first === kilograms)
        #expect(kilograms.value.isEmpty)
    }

    @Test("The RDF versions are distinct named individuals that any graph can link to", .tags(.property))
    func versionsAreDistinctIndividuals() throws {
        #expect(RDF.version_1_2 !== RDF.version_1_1)
        #expect(RDF.version_1_2 === RDF.version_1_2)

        let graph = IndividualGraph()
        let specification = RDFS.ResourceIndividual(in: graph)
        specification.seeAlso.append(RDF.version_1_2)
        let version = try #require(specification.seeAlso.first)
        #expect(version === RDF.version_1_2)
        #expect(RDF.version_1_2.seeAlso.isEmpty)
    }

    @Test("An RDF datatype stores its literal", .tags(.property))
    func datatypesStoreLiterals() {
        let markup = RDF.HTML("<p>Lion</p>")
        let german = RDF.langString("Löwe", languageTag: "de")
        let arabic = RDF.dirLangString("أسد", languageTag: "ar", direction: .rtl)

        #expect(markup.lexicalForm == "<p>Lion</p>")
        #expect(markup == "<p>Lion</p>")
        #expect(german.languageTag == "de")
        #expect(german != RDF.langString("Löwe"))
        #expect(arabic.direction == .rtl)
    }

    @Test("Each term's IRI is projected from the RDF namespace", .tags(.boundary))
    func iriIsProjectedFromTheNamespace() {
        let rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
        #expect(RDF.PropertyIndividual.metadata.id == IRI(rdf + "Property"))
        #expect(type(of: RDF.nil).metadata.id == IRI(rdf + "nil"))
        #expect(type(of: RDF.version_1_2).metadata.id == IRI(rdf + "version-1.2"))
        #expect(RDF.HTML.metadata.id == IRI(rdf + "HTML"))
        #expect(RDF.rest.metadata.id == IRI(rdf + "rest"))
    }
}
