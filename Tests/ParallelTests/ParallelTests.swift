import Testing
import Foundation
import RDFCore
import RDFFormats
import FOAF
import AliceProfile

/// The parallel between RDF and Swift, checked mechanically.
///
/// RDF goes in at build time and Swift comes out as the things the RDF
/// describes. Swift translates back to the same RDF graph. These tests
/// assert only what the standards settle: membership (`rdf:type`,
/// `rdfs:subClassOf`), properties reachable on the things that have them,
/// and graph isomorphism (RDF 1.2 Concepts §3.7) for the way back.
@Suite struct ParallelTests {
    // MARK: RDF in, Swift out

    /// `:alice a foaf:Person` builds to a Swift value that is a `Person`.
    @Test func individualIsInstanceOfItsClass() {
        #expect(alice is Person)
        #expect(bob is Person)
    }

    /// `foaf:Person rdfs:subClassOf foaf:Agent`: membership follows the
    /// class hierarchy (RDF 1.2 Semantics, rule rdfs9).
    @Test func membershipFollowsSubClassOf() {
        #expect(alice is Agent)
    }

    /// `foaf:knows` is reachable on the individual that has it, and its
    /// values are the individuals themselves, cycles included.
    @Test func propertiesAreMembersOfTheThingsThatHaveThem() {
        #expect(alice.knows.contains { $0 === bob })
        #expect(bob.knows.contains { $0 === alice })
        #expect(alice.name.contains("Alice"))
    }

    // MARK: Swift back to RDF

    /// The individuals translate back to a graph isomorphic to the profile.
    @Test func dataTranslatesBackToTheSameGraph() throws {
        let input = try TurtleDecoder().decode(try fixture("AliceProfile/alice.ttl"))
        let output = try NTriplesDecoder().decode(try NTriplesEncoder().encode([alice, bob]))
        #expect(GraphIsomorphism(input, output).holds)
    }

    /// The vocabulary translates back to a graph isomorphic to FOAF as published
    /// (http://xmlns.com/foaf/spec/index.rdf, RDF/XML).
    @Test func vocabularyTranslatesBackToTheSameGraph() throws {
        let input = try RDFXMLDecoder().decode(try fixture("FOAF/index.rdf"))
        let output = try NTriplesDecoder().decode(try NTriplesEncoder().encode(FOAF.ontology))
        #expect(GraphIsomorphism(input, output).holds)
    }

    private func fixture(_ path: String) throws -> String {
        let url = URL(filePath: #filePath).deletingLastPathComponent().appending(path: "Fixtures/\(path)")
        return try String(contentsOf: url, encoding: .utf8)
    }
}
