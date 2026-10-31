import Testing
import RDFKit
import FOAF

@Suite(.tags(.class, .foaf))
struct FOAFDocumentTests {
    /// foaf:Document, translated from index.rdf, as protocol inheritance.
    @Test func inheritsItsSuperclasses() {
        let member: AnyObject = Member()
        #expect(member is FOAF.Document)
        #expect(member is RDFS.Resource)
    }

    private final class Member: FOAF.Document {}
}
