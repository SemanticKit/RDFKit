import Testing
import RDFKit
import FOAF

@Suite(.tags(.class, .foaf))
struct FOAFPersonalProfileDocumentTests {
    /// foaf:PersonalProfileDocument rdfs:subClassOf FOAF.Document, translated from index.rdf, as protocol
    /// inheritance: the upcasts compile only if a FOAF.PersonalProfileDocument is each of these.
    @Test func inheritsItsSuperclasses() {
        let asFOAFDocument: (any FOAF.PersonalProfileDocument) -> any FOAF.Document = { $0 }
        let asRDFSResource: (any FOAF.PersonalProfileDocument) -> any RDFS.Resource = { $0 }
        _ = (asFOAFDocument, asRDFSResource)
    }
}
