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
}
