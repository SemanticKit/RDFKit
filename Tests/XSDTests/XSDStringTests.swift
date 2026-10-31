import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDStringTests {
    /// xsd:string's value space is exactly Swift's String, so the datatype
    /// is String (rule 20), and a String is a literal.
    @Test func isStringAndALiteral() {
        let name: XSD.string = "Alice"
        #expect(name == "Alice")
        #expect(("Alice" as Any) is RDFS.Literal)
        #expect(ObjectIdentifier(XSD.string.self) == ObjectIdentifier(String.self))
    }

    /// xsd:string's lexical mapping is the identity on sequences of XML
    /// Chars (§3.3.1.2), with whiteSpace preserve: nothing is collapsed.
    @Test func mapsALexicalForm() throws {
        #expect(try String(lexicalForm: "Alice") == "Alice")
        #expect(try String(lexicalForm: "  two\tspaces\n ") == "  two\tspaces\n ")
        #expect(try String(lexicalForm: "").isEmpty)
        #expect(throws: DatatypeError.illTyped) { try String(lexicalForm: "\u{0}") }
        #expect(throws: DatatypeError.illTyped) { try String(lexicalForm: "\u{FFFE}") }
    }
}
