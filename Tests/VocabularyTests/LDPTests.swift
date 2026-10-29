import Testing
import IRIKit
import RDFCore
import RDFKit
import ReferencedVocabularies
import LDP

@Suite("Linked Data Platform", .tags(.vocabulary))
struct LDPTests {
    @Test("Declares every class, property and individual of the LDP vocabulary")
    func declaresThePublishedTerms() {
        #expect(Declarations(of: LDP()) == Declarations(classes: 9, properties: 13, individuals: 7))
    }

    @Test("Containers are RDF sources and LDP resources", .tags(.generated))
    func containers() {
        let container: any LDP.Resource = LDP.BasicContainerIndividual(in: IndividualGraph())

        #expect(container is any LDP.Container)
        #expect(container is any LDP.RDFSource)
        #expect(!(container is any LDP.NonRDFSource))
        #expect(!(container is any LDP.DirectContainer))
    }

    @Test("A container contains resources as objects", .tags(.property, .generated))
    func containment() throws {
        let graph = IndividualGraph()
        let child = LDP.BasicContainerIndividual(in: graph)
        let document = LDP.NonRDFSourceIndividual(in: graph)
        let root = LDP.BasicContainerIndividual(in: graph, contains: [child, document])
        child.contains.append(root)

        let first = try #require(root.contains.first)
        #expect(first === child)
        #expect(try #require(child.contains.first) === root)
        #expect(root.contains.last === document)
    }

    @Test("Preferences and sort orders are named individuals", .tags(.generated))
    func namedIndividuals() {
        #expect(LDP.Ascending !== LDP.Descending)
        #expect(LDP.PreferContainment === LDP.PreferContainment)
        #expect(type(of: LDP.PreferMinimalContainer).metadata.id == IRI("http://www.w3.org/ns/ldp#PreferMinimalContainer"))
    }

    @Test("Named individuals are typed owl:Individual, as published", .tags(.generated))
    func individualsAreOWLIndividuals() {
        let individuals: [any LegacyOWL.Individual] = [
            LDP.Ascending, LDP.Descending, LDP.MemberSubject, LDP.PreferContainment,
            LDP.PreferEmptyContainer, LDP.PreferMembership, LDP.PreferMinimalContainer,
        ]
        #expect(individuals.count == 7)
        #expect(!(LDP.Ascending is any LDP.Resource))
    }

    @Test("A page sort criterion's order is an rdf:Resource, its published range", .tags(.property, .generated))
    func pageSortOrderRange() throws {
        let graph = IndividualGraph()
        let order = LegacyRDF.ResourceIndividual(in: graph)
        let criterion = LDP.PageSortCriterionIndividual(in: graph, pageSortOrder: [order])
        let value: LDP.pageSortOrder.Range = try #require(criterion.pageSortOrder.first)
        let resource: any LegacyRDF.Resource = value
        #expect(resource === order)
        #expect(!(LDP.BasicContainerIndividual(in: graph) is any LegacyRDF.Resource))
    }

    @Test("The terms RDF and OWL do not define keep their own IRIs", .tags(.boundary))
    func legacyTermsAtTheBoundary() {
        #expect(LegacyRDF.ResourceIndividual.metadata.id == IRI("http://www.w3.org/1999/02/22-rdf-syntax-ns#Resource"))
        #expect(LegacyOWL.IndividualIndividual.metadata.id == IRI("http://www.w3.org/2002/07/owl#Individual"))
    }
}
