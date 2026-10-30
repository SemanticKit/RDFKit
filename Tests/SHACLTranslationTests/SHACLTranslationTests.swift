import Testing
import Foundation
import IRIKit
import RDFCore
import RDFFormats
import RDF
import SHACL

/// SHACL 1.2's published `shacl.ttl`, translated by `RDFTranslatorPlugin`
/// into `SHACL` on top of `RDF` and `OWL`.
@Suite("SHACL translated on top of RDF", .tags(.generated))
struct SHACLTranslationTests {
    /// `sh:value` (`rdfs:domain sh:AbstractResult`) and `rdf:value`
    /// (`rdfs:domain rdfs:Resource`) share a local name. A validation result
    /// is a member of both domains, so it has both properties, each through
    /// its own accessor, and each keeps its own values.
    @Test func propertiesWithOneLocalNameAreBothMembers() throws {
        let result = SHACL.ValidationResultIndividual()
        result.value = [.individual(SHACL.Info)]
        result.shaclValue = [.individual(SHACL.Violation)]
        guard case .individual(let value) = try #require(result.value.first) else {
            Issue.record("rdf:value holds the individual it was given")
            return
        }
        #expect(result.value.count == 1)
        #expect(value === SHACL.Info)
        guard case .individual(let severity) = try #require(result.shaclValue.first) else {
            Issue.record("sh:value holds the individual it was given")
            return
        }
        #expect(result.shaclValue.count == 1)
        #expect(severity === SHACL.Violation)

        // Each accessor writes its own property.
        let output = try NTriplesDecoder().decode(try NTriplesEncoder().encode([result]))
        let rdfValue = try #require(IRI(RDF.value.key))
        let shaclValue = try #require(IRI(SHACL.value.key))
        let info = try #require(IRI(of: SHACL.Info))
        let violation = try #require(IRI(of: SHACL.Violation))
        #expect(rdfValue != shaclValue)
        #expect(output.contains { $0.predicate == rdfValue && $0.object == .iri(info) })
        #expect(output.contains { $0.predicate == shaclValue && $0.object == .iri(violation) })
        #expect(!output.contains { $0.predicate == rdfValue && $0.object == .iri(violation) })
    }

    /// The SHACL document comes back as the same graph (RDF 1.2 Concepts
    /// §3.7).
    @Test func shaclTranslatesBackToTheSameGraph() throws {
        let url = URL(filePath: #filePath).deletingLastPathComponent().appending(path: "Fixtures/SHACL/shacl.ttl")
        let input = try TurtleDecoder().decode(try String(contentsOf: url, encoding: .utf8))
        let output = try NTriplesDecoder().decode(try NTriplesEncoder().encode(SHACL.ontology))
        #expect(input.isIsomorphic(to: output))
    }
}
