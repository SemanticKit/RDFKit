import Testing
import RDFKit
import FOAF

@Suite(.tags(.class, .foaf))
struct FOAFProjectTests {
    /// foaf:Project, translated from index.rdf, as protocol inheritance:
    /// a FOAF.Project is each of these, which the upcasts compile only if so.
    @Test func inheritsItsSuperclasses() {
        let asRDFSResource: (any FOAF.Project) -> any RDFS.Resource = { $0 }
        _ = (asRDFSResource)
    }
}
