import IRIKit
import RDFCore
import RDFKit
import Testing

@Suite("RDF through @Ontology", .tags(.ontology, .generated))
struct RDFTests {
    @Test("rdf:nil is one list, and lists link to it", .tags(.property))
    func listsEndAtNil() throws {
        let item = OWL.ThingIndividual()
        let list = RDF.ListIndividual(first: [item], rest: [RDF.nil])

        let rest = try #require(list.rest.first)
        #expect(rest === RDF.nil)
        #expect(list.first.first === item)
        #expect(RDF.nil.first.isEmpty)
    }

    @Test("A statement's parts are the individuals themselves", .tags(.property))
    func statementPartsAreIndividuals() throws {
        let lion = OWL.ThingIndividual()
        let zebra = OWL.ThingIndividual()
        let preysOn = OWL.ObjectPropertyIndividual()
        let statement = RDF.StatementIndividual(object: [zebra], predicate: [preysOn], subject: [lion])

        let predicate = try #require(statement.predicate.first)
        #expect(statement.subject.first === lion)
        #expect(predicate === preysOn)
        #expect(statement.object.first === zebra)
    }

    @Test("A list can hold itself", .tags(.property))
    func listsFormCycles() throws {
        let list = RDF.ListIndividual()
        list.first = [list]
        list.rest = [list]

        let rest = try #require(list.rest.first)
        let head = try #require(rest.first.first)
        #expect(rest === list)
        #expect(head === list)
    }

    @Test("The RDF versions are distinct named individuals")
    func versionsAreDistinctIndividuals() {
        #expect(RDF.version_1_2 !== RDF.version_1_1)
        #expect(RDF.version_1_2 === RDF.version_1_2)
        RDF.version_1_2_basic.seeAlso = [RDF.version_1_2]
        #expect(RDF.version_1_2_basic.seeAlso.first === RDF.version_1_2)
    }

    @Test("RDF datatypes are values")
    func datatypesAreValues() {
        #expect(Mirror(reflecting: RDF.HTML()).displayStyle == .struct)
        #expect(Mirror(reflecting: RDF.JSON()).displayStyle == .struct)
        #expect(Mirror(reflecting: RDF.langString()).displayStyle == .struct)
        #expect(Mirror(reflecting: RDF.dirLangString()).displayStyle == .struct)
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
