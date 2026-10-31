import Testing
import RDFKit
import FOAF

@Suite(.tags(.class, .foaf))
struct FOAFLabelPropertyTests {
    /// foaf:LabelProperty, translated from index.rdf, as protocol inheritance:
    /// a FOAF.LabelProperty is each of these, which the upcasts compile only if so.
    @Test func inheritsItsSuperclasses() {
        let asRDFSResource: (any FOAF.LabelProperty) -> any RDFS.Resource = { $0 }
        _ = (asRDFSResource)
    }
}
