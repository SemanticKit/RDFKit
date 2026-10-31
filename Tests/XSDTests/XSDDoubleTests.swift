import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDDoubleTests {
    /// xsd:double is IEEE double precision (XSD 1.1 Part 2 §3.3.5), exactly
    /// Swift's Double, so the datatype is Double (rule 20), and a Double is
    /// a literal.
    @Test func isDoubleAndALiteral() {
        let ratio: XSD.double = 0.5
        #expect(ratio == 0.5)
        #expect((0.5 as Any) is RDFS.Literal)
        #expect(ObjectIdentifier(XSD.double.self) == ObjectIdentifier(Double.self))
    }

    /// xsd:double's lexical mapping, ·doubleLexicalMap· (§3.3.5.2), after
    /// whiteSpace collapse: numerals rounded to the nearest double, the
    /// special values, and negative zero for a zero numeral with `-`.
    @Test func mapsALexicalForm() throws {
        #expect(try Double(lexicalForm: "1.5") == 1.5)
        #expect(try Double(lexicalForm: " -12.5E-1 ") == -1.25)
        #expect(try Double(lexicalForm: "1.") == 1)
        #expect(try Double(lexicalForm: ".5") == 0.5)
        #expect(try Double(lexicalForm: "+3e2") == 300)
        #expect(try Double(lexicalForm: "0.1") == 0.1)
        #expect(try Double(lexicalForm: "INF") == .infinity)
        #expect(try Double(lexicalForm: "+INF") == .infinity)
        #expect(try Double(lexicalForm: "-INF") == -.infinity)
        #expect(try Double(lexicalForm: "NaN").isNaN)
        #expect(try Double(lexicalForm: "1e400") == .infinity)
        #expect(try Double(lexicalForm: "-1e400") == -.infinity)
        #expect(try Double(lexicalForm: "1e-400") == 0)
        let negativeZero = try Double(lexicalForm: "-0")
        #expect(negativeZero == 0 && negativeZero.sign == .minus)
        #expect(try Double(lexicalForm: "0.0e5").sign == .plus)
        for form in ["inf", "nan", "-NaN", "Infinity", "0x1p3", "1e", "e1", ".", "", "1.5.2", "1 000", "1,5", "1d0"] {
            #expect(throws: DatatypeError.illTyped) { try Double(lexicalForm: form) }
        }
    }
}
