import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDDecimalTests {
    /// xsd:decimal's value is an exact decimal number (XSD 1.1 Part 2
    /// §3.3.3, D6), and it is a literal.
    @Test func isAnExactValueTypeLiteral() {
        let price = XSD.decimal(DecimalNumber(5))
        #expect(price.value == DecimalNumber(2) + DecimalNumber(3))
        #expect((price as Any) is RDFS.Literal)
    }

    /// xsd:decimal's lexical mapping, ·decimalLexicalMap· (§3.3.3.2), after
    /// whiteSpace collapse: one value for every numeral of the number.
    @Test func mapsALexicalForm() throws {
        #expect(try XSD.decimal(lexicalForm: " 1.50 ").value.description == "1.5")
        #expect(try XSD.decimal(lexicalForm: "1.50") == XSD.decimal(lexicalForm: "+01.5"))
        #expect(try XSD.decimal(lexicalForm: "-0").value == DecimalNumber(0))
        #expect(try XSD.decimal(lexicalForm: "12.").value == DecimalNumber(12))
        #expect(try XSD.decimal(lexicalForm: "-.5").value.description == "-0.5")
        #expect(try XSD.decimal(lexicalForm: "123456789012345678901234567890.1").value.description == "123456789012345678901234567890.1")
        for form in ["1e2", "INF", "NaN", ".", "", "1.2.3", "- 1", "1 2", "+-1", "0x10"] {
            #expect(throws: DatatypeError.illTyped) { try XSD.decimal(lexicalForm: form) }
        }
    }
}
