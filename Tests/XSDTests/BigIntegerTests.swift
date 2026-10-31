import Testing
import XSD

@Suite(.tags(.xsd))
struct BigIntegerTests {
    /// xsd:integer's value space is unbounded (XSD 1.1 Part 2 §3.4.13), so
    /// it is not bounded by Int.
    @Test func exceedsInt() {
        let max = BigInteger(Int.max)
        let beyond = max + BigInteger(1)
        #expect(beyond > max)
        #expect(beyond - BigInteger(1) == max)
        #expect(beyond.description == "9223372036854775808")
    }
}
