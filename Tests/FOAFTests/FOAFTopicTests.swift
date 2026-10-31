import Testing
import RDFCore
import RDFKit
import FOAF

@Suite(.tags(.property, .foaf))
struct FOAFTopicTests {
    /// foaf:topic, translated from index.rdf: its domain, FOAF.Document, is a class of FOAF, so it is a requirement of FOAF.Document.
    /// The key path compiles only if the requirement exists with its type.
    @Test func isARequirementTypedByItsRange() {
        let path: WritableKeyPath<any FOAF.Document, Values<any OWL.Thing>> = \.topic
        _ = path
    }
}
