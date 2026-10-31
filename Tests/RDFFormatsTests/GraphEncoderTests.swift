import Testing
import RDFCore
import RDFFormats

@Suite(.tags(.rdf))
struct GraphEncoderTests {
    /// Two individuals who know each other encode as the graph a Turtle
    /// document states about them: their IRIs from `@id`, their classes from
    /// `@type`, and the cycle as two triples, not an endless descent.
    @Test func encodesNodesAndTheirCycle() throws {
        let alice = Individual(iri: "https://alice.example/profile#alice", name: "Alice")
        let bob = Individual(iri: "https://alice.example/profile#bob", name: "Bob")
        alice.knows = [bob]
        bob.knows = [alice]

        let expected = try TurtleDecoder().decode("""
            @prefix foaf: <http://xmlns.com/foaf/0.1/> .
            @prefix : <https://alice.example/profile#> .
            :alice a foaf:Person ; foaf:name "Alice" ; foaf:knows :bob .
            :bob a foaf:Person ; foaf:name "Bob" ; foaf:knows :alice .
            """)
        let encoded = try NTriplesDecoder().decode(try NTriplesEncoder().encode([alice, bob]))
        #expect(encoded.isIsomorphic(to: expected))
    }

    /// A node with no `@id` is a blank node, and Swift's numbers and booleans
    /// are typed literals in their canonical forms (XSD 1.1 Part 2 §3.3).
    @Test func encodesBlankNodesAndTypedLiterals() throws {
        let measurement = Measurement(value: 0.5, count: 2, exact: true)
        let expected = try TurtleDecoder().decode("""
            @prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
            [] <https://example.org/value> "5.0E-1"^^xsd:double ;
               <https://example.org/count> 2 ;
               <https://example.org/exact> true .
            """)
        #expect(try GraphEncoder().encode(measurement).isIsomorphic(to: expected))
    }

    /// A literal is not a node, so it cannot be a value at the top level.
    @Test func rejectsALiteralAtTheTopLevel() {
        #expect(throws: EncodingError.self) { try GraphEncoder().encode("Alice") }
    }
}

private final class Individual: Encodable {
    let iri: String
    var name: [String]
    var knows: [Individual] = []

    init(iri: String, name: String) {
        self.iri = iri
        self.name = [name]
    }

    enum CodingKeys: String, CodingKey {
        case id = "@id"
        case type = "@type"
        case name = "http://xmlns.com/foaf/0.1/name"
        case knows = "http://xmlns.com/foaf/0.1/knows"
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(iri, forKey: .id)
        try container.encode(["http://xmlns.com/foaf/0.1/Person"], forKey: .type)
        try container.encode(name, forKey: .name)
        try container.encode(knows, forKey: .knows)
    }
}

private struct Measurement: Encodable {
    let value: Double
    let count: Int
    let exact: Bool

    enum CodingKeys: String, CodingKey {
        case value = "https://example.org/value"
        case count = "https://example.org/count"
        case exact = "https://example.org/exact"
    }
}
