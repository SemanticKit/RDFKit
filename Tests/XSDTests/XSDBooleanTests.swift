import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDBooleanTests {
    /// xsd:boolean's value space is {true, false} (XSD 1.1 Part 2 §3.3.2),
    /// exactly Swift's Bool, so the datatype is Bool (rule 20), and a Bool
    /// is a literal.
    @Test func isBoolAndALiteral() {
        let flag: XSD.boolean = true
        #expect(flag)
        #expect((false as Any) is RDFS.Literal)
        #expect(ObjectIdentifier(XSD.boolean.self) == ObjectIdentifier(Bool.self))
    }

    /// xsd:boolean's lexical mapping, ·booleanLexicalMap· (§3.3.2.2), after
    /// whiteSpace collapse: `true` and `1`, `false` and `0`.
    @Test func mapsALexicalForm() throws {
        #expect(try Bool(lexicalForm: "true"))
        #expect(try Bool(lexicalForm: "1"))
        #expect(try Bool(lexicalForm: " \ttrue\n"))
        #expect(try !Bool(lexicalForm: "false"))
        #expect(try !Bool(lexicalForm: "0"))
        for form in ["TRUE", "True", "yes", "2", "", "t rue", "01"] {
            #expect(throws: DatatypeError.illTyped) { try Bool(lexicalForm: form) }
        }
    }
}
