import Testing
import RDFCore
import RDFKit
import FOAF

@Suite(.tags(.property, .foaf))
struct FOAFDnaChecksumTests {
    /// foaf:dnaChecksum, translated from index.rdf: its domain is the root, so it is its own protocol, FOAF.DnaChecksum.
    /// The key path compiles only if the requirement exists with its type.
    @Test func isARequirementTypedByItsRange() {
        let path: WritableKeyPath<any FOAF.DnaChecksum, Values<any RDFS.Literal>> = \.dnaChecksum
        _ = path
    }
}
