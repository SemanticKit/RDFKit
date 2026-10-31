import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDNameTests {
    /// xsd:Name is xsd:token with the pattern `\i\c*`, an XML Name (XSD 1.1 Part 2 §3.4.6),
    /// as derived.nxsd gives it; its values are xsd:string's.
    @Test func acceptsItsValues() throws {
        #expect(try XSD.Name("a:b").value == "a:b")
        #expect(try XSD.Name("_x.y-z").value == "_x.y-z")
        #expect(try XSD.Name("\u{E9}t\u{E9}").value == "\u{E9}t\u{E9}")
        #expect(try XSD.Name("\u{F900}").value == "\u{F900}")
        #expect((try XSD.Name("a:b") as Any) is RDFS.Literal)
    }

    /// A String outside the value space of xsd:Name is ill-typed.
    @Test func throwsOutsideItsValueSpace() {
        #expect(throws: DatatypeError.illTyped) { try XSD.Name("1a") }
        #expect(throws: DatatypeError.illTyped) { try XSD.Name("-a") }
        #expect(throws: DatatypeError.illTyped) { try XSD.Name("a b") }
        #expect(throws: DatatypeError.illTyped) { try XSD.Name("") }
    }
}
