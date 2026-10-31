import Foundation
import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDAnyURITests {
    /// xsd:anyURI's value is a sequence of characters (§3.3.17), which is
    /// a URL as Foundation reads one, and it is a literal.
    @Test func isAURL() throws {
        let profile = try #require(URL(string: "https://alice.example/profile#me"))
        let uri = XSD.anyURI(profile)
        #expect(uri.value == "https://alice.example/profile#me")
        #expect(uri.url == profile)
        #expect((uri as Any) is RDFS.Literal)
    }

    /// The characters are the value, compared code point by code point; an
    /// IRI's are a URL with its non-ASCII characters percent-encoded.
    @Test func keepsTheCharacters() {
        let iri = XSD.anyURI("https://example.org/caf\u{E9}")
        #expect(iri != XSD.anyURI("https://example.org/cafe\u{301}"))
        #expect(iri.url?.absoluteString == "https://example.org/caf%C3%A9")
    }
}
