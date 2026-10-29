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
        let inserted = Log.FormulaIndividual()
        let condition = Log.FormulaIndividual()
        let patch = Solid.InsertDeletePatchIndividual(inserts: inserted, where: condition)

        // solid:inserts, solid:deletes and solid:where are functional.
        #expect(patch.inserts === inserted)
        #expect(patch.where === condition)
        #expect(patch.deletes == nil)
        #expect(patch is any Solid.Patch)
    }

    @Test("Type indexes are typed by their ranges", .tags(.property, .generated))
    func typeIndexes() throws {
        let alice = Foaf.PersonIndividual()
        let index = Solid.ListedDocumentIndividual()
        let registration = Solid.TypeRegistrationIndividual()

        // solid:publicTypeIndex has the range solid:ListedDocument and no domain.
        Solid.publicTypeIndex[alice] = [index]
        Solid.forClass[registration] = [Foaf.PersonIndividual()]
        let found: Solid.publicTypeIndex.Range = try #require(Solid.publicTypeIndex[alice].first)
        #expect(found === index)
        #expect(Solid.forClass[registration].count == 1)
    }

    @Test("A term's IRI is projected from the namespace at the boundary", .tags(.boundary))
    func iriIsBoundaryProjection() {
        #expect(Solid.oidcIssuer.metadata.id == IRI("http://www.w3.org/ns/solid/terms#oidcIssuer"))
        #expect(Solid.oidcIssuer.metadata.label == "OIDC issuer")
        #expect(OpenIDConnect.issuer.metadata.id == IRI("http://openid.net/specs/connect/1.0/issuer"))
    }
}
