import Testing
import RDFKit
import FOAF

@Suite(.tags(.class, .foaf))
struct FOAFImageTests {
    /// foaf:Image rdfs:subClassOf FOAF.Document, translated from index.rdf, as protocol
    /// inheritance: the upcasts compile only if a FOAF.Image is each of these.
    @Test func inheritsItsSuperclasses() {
        let asFOAFDocument: (any FOAF.Image) -> any FOAF.Document = { $0 }
        let asRDFSResource: (any FOAF.Image) -> any RDFS.Resource = { $0 }
        _ = (asFOAFDocument, asRDFSResource)
    }
}
