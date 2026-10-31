import Testing
import XSD

@Suite(.tags(.xsd))
struct DecimalNumberTests {
    /// xsd:decimal's values are exact (XSD 1.1 Part 2 §3.3.3).
    @Test func arithmeticIsExact() {
        let sum = DecimalNumber(2) + DecimalNumber(3)
        #expect(sum == DecimalNumber(5))
        #expect(DecimalNumber(2) < DecimalNumber(3))
    }
}
