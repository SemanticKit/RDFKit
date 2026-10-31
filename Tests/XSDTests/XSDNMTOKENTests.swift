import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDNMTOKENTests {
    /// xsd:NMTOKEN is xsd:token with the pattern `\c+`, XML name characters (XSD 1.1 Part 2 §3.4.4),
    /// as derived.nxsd gives it; its values are xsd:string's.
    @Test func acceptsItsValues() throws {
        #expect(try XSD.NMTOKEN("1a").value == "1a")
        #expect(try XSD.NMTOKEN("-a:b").value == "-a:b")
        #expect(try XSD.NMTOKEN("...").value == "...")
        #expect((try XSD.NMTOKEN("1a") as Any) is RDFS.Literal)
    }

    /// A String outside the value space of xsd:NMTOKEN is ill-typed.
    @Test func throwsOutsideItsValueSpace() {
        #expect(throws: DatatypeError.illTyped) { try XSD.NMTOKEN("a b") }
        #expect(throws: DatatypeError.illTyped) { try XSD.NMTOKEN("") }
        #expect(throws: DatatypeError.illTyped) { try XSD.NMTOKEN(" a") }
    }
}
