import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDLanguageTests {
    /// xsd:language is xsd:token with the pattern `[a-zA-Z]{1,8}(-[a-zA-Z0-9]{1,8})*` (XSD 1.1 Part 2 §3.4.3),
    /// as derived.nxsd gives it; its values are xsd:string's.
    @Test func acceptsItsValues() throws {
        #expect(try XSD.language("en").value == "en")
        #expect(try XSD.language("en-US").value == "en-US")
        #expect(try XSD.language("zh-Hant-TW").value == "zh-Hant-TW")
        #expect((try XSD.language("en") as Any) is RDFS.Literal)
    }

    /// A String outside the value space of xsd:language is ill-typed.
    @Test func throwsOutsideItsValueSpace() {
        #expect(throws: DatatypeError.illTyped) { try XSD.language("") }
        #expect(throws: DatatypeError.illTyped) { try XSD.language("toolongtag") }
        #expect(throws: DatatypeError.illTyped) { try XSD.language("en_US") }
        #expect(throws: DatatypeError.illTyped) { try XSD.language(" en") }
        #expect(throws: DatatypeError.illTyped) { try XSD.language("en-") }
    }
}
