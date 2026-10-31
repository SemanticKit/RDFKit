import Testing
import RDFKit
import FOAF

@Suite(.tags(.class, .foaf))
struct FOAFSpatialThingTests {
    /// geo:SpatialThing, translated from index.rdf, as protocol inheritance:
    /// a FOAF.SpatialThing is each of these, which the upcasts compile only if so.
    @Test func inheritsItsSuperclasses() {
        let asRDFSResource: (any FOAF.SpatialThing) -> any RDFS.Resource = { $0 }
        _ = (asRDFSResource)
    }
}
