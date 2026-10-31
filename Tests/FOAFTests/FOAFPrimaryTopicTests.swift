import Testing
import RDFCore
import RDFKit
import FOAF

@Suite(.tags(.property, .foaf))
struct FOAFPrimaryTopicTests {
    /// foaf:primaryTopic, translated from index.rdf: its domain, FOAF.Document, is a class of FOAF, so it is a requirement of FOAF.Document.
    /// The key path compiles only if the requirement exists with its type.
    @Test func isARequirementTypedByItsRange() {
        let path: WritableKeyPath<any FOAF.Document, (any OWL.Thing)?> = \.primaryTopic
        _ = path
    }
}
