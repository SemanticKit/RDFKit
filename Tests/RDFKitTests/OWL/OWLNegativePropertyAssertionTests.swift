import Testing
import RDFCore
import RDFKit

@Suite(.tags(.class, .owl))
struct OWLNegativePropertyAssertionTests {
    /// owl:NegativePropertyAssertion, as protocol inheritance.
    @Test func inheritsItsSuperclasses() {
        let member: AnyObject = Member()
        #expect(member is OWL.NegativePropertyAssertion)
        #expect(member is RDFS.Resource)
    }

    private final class Member: OWL.NegativePropertyAssertion {
        var assertionProperty: Values<any RDF.Property> = []
        var sourceIndividual: Values<any OWL.Thing> = []
        var targetIndividual: Values<any OWL.Thing> = []
        var targetValue: Values<any RDFS.Literal> = []
    }
}
