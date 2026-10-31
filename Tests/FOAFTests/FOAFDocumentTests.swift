import Testing
import RDFKit
import FOAF

@Suite(.tags(.class, .foaf))
struct FOAFDocumentTests {
    /// foaf:Document, translated from index.rdf, as protocol inheritance:
    /// a FOAF.Document is each of these, which the upcasts compile only if so.
    @Test func inheritsItsSuperclasses() {
        let asRDFSResource: (any FOAF.Document) -> any RDFS.Resource = { $0 }
        _ = (asRDFSResource)
    }
}
