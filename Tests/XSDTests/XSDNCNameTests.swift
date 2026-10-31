import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDNCNameTests {
    /// xsd:NCName is xsd:Name with the pattern `[\i-[:]][\c-[:]]*`, a Name with no colon (XSD 1.1 Part 2 §3.4.7),
    /// as derived.nxsd gives it; its values are xsd:string's.
    @Test func acceptsItsValues() throws {
        #expect(try XSD.NCName("a").value == "a")
        #expect(try XSD.NCName("_x.y-z").value == "_x.y-z")
        #expect((try XSD.NCName("a") as Any) is RDFS.Literal)
    }

    /// A String outside the value space of xsd:NCName is ill-typed.
    @Test func throwsOutsideItsValueSpace() {
        #expect(throws: DatatypeError.illTyped) { try XSD.NCName("a:b") }
        #expect(throws: DatatypeError.illTyped) { try XSD.NCName(":a") }
        #expect(throws: DatatypeError.illTyped) { try XSD.NCName("1a") }
    }
}
