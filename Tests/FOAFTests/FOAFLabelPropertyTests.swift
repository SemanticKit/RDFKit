import Testing
import RDFKit
import FOAF

@Suite(.tags(.class, .foaf))
struct FOAFLabelPropertyTests {
    /// foaf:LabelProperty, translated from index.rdf, as protocol inheritance.
    @Test func inheritsItsSuperclasses() {
        let member: AnyObject = Member()
        #expect(member is FOAF.LabelProperty)
        #expect(member is RDFS.Resource)
    }

    private final class Member: FOAF.LabelProperty {}
}
