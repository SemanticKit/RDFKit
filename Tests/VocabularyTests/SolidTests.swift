import Testing
import IRIKit
import RDFCore
import RDFKit
import ReferencedVocabularies
import FOAF
import Solid

@Suite("Solid terms", .tags(.vocabulary))
struct SolidTests {
    @Test("Declares every class and property of the Solid terms vocabulary")
    func declaresThePublishedTerms() {
        #expect(Declarations(of: Solid()) == Declarations(classes: 10, properties: 23))
    }

    @Test("A patch has at most one insert, delete and where formula", .tags(.property, .generated))
    func patchFormulas() throws {
        let graph = IndividualGraph()
        let inserted = Log.FormulaIndividual(in: graph)
        let condition = Log.FormulaIndividual(in: graph)
        let patch = Solid.InsertDeletePatchIndividual(in: graph, inserts: inserted, where: condition)

        // solid:inserts, solid:deletes and solid:where are functional.
        #expect(patch.inserts.value === inserted)
        #expect(patch.where.value === condition)
        #expect(patch.deletes.value == nil)
        #expect(patch is any Solid.Patch)
    }

    @Test("Type indexes are typed by their ranges, and register classes", .tags(.property, .generated))
    func typeIndexes() throws {
        let graph = IndividualGraph()
        let alice = Foaf.PersonIndividual(in: graph)
        let index = Solid.ListedDocumentIndividual(in: graph)
        let registration = Solid.TypeRegistrationIndividual(in: graph)

        // solid:publicTypeIndex has the range solid:ListedDocument and no domain.
        Solid.publicTypeIndex[alice].append(index)
        let found: Solid.publicTypeIndex.Range = try #require(Solid.publicTypeIndex[alice].first)
        #expect(found === index)

        // solid:forClass registers a class: here foaf:Person, as a value.
        Solid.forClass[registration].append(Foaf.personClass)
        let registered = try #require(Solid.forClass[registration].first)
        #expect(registered === Foaf.personClass)
        #expect(registered is any RDFS.Class)
        #expect(!(registered is any Foaf.Person))
    }

    @Test("A term's IRI is projected from the namespace at the boundary", .tags(.boundary))
    func iriIsBoundaryProjection() {
        #expect(Solid.oidcIssuer.metadata.id == IRI("http://www.w3.org/ns/solid/terms#oidcIssuer"))
        #expect(Solid.oidcIssuer.metadata.label == "OIDC issuer")
        #expect(OpenIDConnect.issuer.metadata.id == IRI("http://openid.net/specs/connect/1.0/issuer"))
    }
}
