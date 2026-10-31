import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDTokenTests {
    /// xsd:token is xsd:normalizedString with whiteSpace collapse, no leading or trailing space and no two spaces in a row (XSD 1.1 Part 2 §3.4.2),
    /// as derived.nxsd gives it; its values are xsd:string's.
    @Test func acceptsItsValues() throws {
        #expect(try XSD.token("a b").value == "a b")
        #expect(try XSD.token("").value == "")
        #expect((try XSD.token("a b") as Any) is RDFS.Literal)
    }

    /// A String outside the value space of xsd:token is ill-typed.
    @Test func throwsOutsideItsValueSpace() {
        #expect(throws: DatatypeError.illTyped) { try XSD.token(" a") }
        #expect(throws: DatatypeError.illTyped) { try XSD.token("a ") }
        #expect(throws: DatatypeError.illTyped) { try XSD.token("a  b") }
        #expect(throws: DatatypeError.illTyped) { try XSD.token("a\tb") }
    }
}
