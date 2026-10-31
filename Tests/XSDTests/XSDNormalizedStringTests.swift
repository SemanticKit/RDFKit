import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDNormalizedStringTests {
    /// xsd:normalizedString is xsd:string with whiteSpace replace, no tab, line feed or carriage return (XSD 1.1 Part 2 §3.4.1),
    /// as derived.nxsd gives it; its values are xsd:string's.
    @Test func acceptsItsValues() throws {
        #expect(try XSD.normalizedString("a  b ").value == "a  b ")
        #expect(try XSD.normalizedString(" leading").value == " leading")
        #expect((try XSD.normalizedString("a  b ") as Any) is RDFS.Literal)
    }

    /// A String outside the value space of xsd:normalizedString is ill-typed.
    @Test func throwsOutsideItsValueSpace() {
        #expect(throws: DatatypeError.illTyped) { try XSD.normalizedString("a\tb") }
        #expect(throws: DatatypeError.illTyped) { try XSD.normalizedString("a\nb") }
        #expect(throws: DatatypeError.illTyped) { try XSD.normalizedString("a\rb") }
        #expect(throws: DatatypeError.illTyped) { try XSD.normalizedString("a\r\nb") }
    }
}
