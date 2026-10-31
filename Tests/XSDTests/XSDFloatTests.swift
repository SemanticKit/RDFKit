import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDFloatTests {
    /// xsd:float is IEEE single precision (XSD 1.1 Part 2 §3.3.4), exactly
    /// Swift's Float, so the datatype is Float (rule 20), and a Float is a
    /// literal.
    @Test func isFloatAndALiteral() {
        let ratio: XSD.float = 0.5
        #expect(ratio == 0.5)
        #expect((Float(0.5) as Any) is RDFS.Literal)
        #expect(ObjectIdentifier(XSD.float.self) == ObjectIdentifier(Float.self))
    }

    /// xsd:float's lexical mapping, ·floatLexicalMap· (§3.3.4.2), after
    /// whiteSpace collapse, rounding to the nearest float.
    @Test func mapsALexicalForm() throws {
        #expect(try Float(lexicalForm: " 0.1 ") == Float(0.1))
        #expect(try Float(lexicalForm: "-1E2") == -100)
        #expect(try Float(lexicalForm: "INF") == .infinity)
        #expect(try Float(lexicalForm: "NaN").isNaN)
        #expect(try Float(lexicalForm: "1e39") == .infinity)
        #expect(try Float(lexicalForm: "-0.0").sign == .minus)
        for form in ["INFINITY", "1.0f", "", "--1"] {
            #expect(throws: DatatypeError.illTyped) { try Float(lexicalForm: form) }
        }
    }
}
