import Testing
import Foundation
import RDFCore
import RDFFormats
import RDF
import EntailmentRegimes

/// The entailment regime vocabulary, translated by `RDFTranslatorPlugin`
/// into `EntailmentRegimes` on top of RDF and OWL. Its individual ent:RDF is
/// the constant `RDF`, named like the RDF module the generated Swift
/// imports, so the generated Swift refers to every other module's
/// declarations with a module selector (SE-0491), which a declaration of
/// this module cannot shadow.
@Suite("A vocabulary naming an individual like a module it builds on", .tags(.generated))
struct EntailmentTranslationTests {
    /// `ent:RDF a ent:Entailment`: the individual named like a module is a
    /// member of its class, and of the classes of the RDF module it is
    /// named like.
    @Test func individualNamedLikeAModuleIsAMemberOfItsClass() {
        #expect((EntailmentRegimes::RDF as AnyObject) is any EntailmentRegimes::Entailment)
        #expect((EntailmentRegimes::RDF as AnyObject) is any RDF::Resource)
    }

    /// The individual's values, read through properties the RDF module
    /// declares.
    @Test func individualNamedLikeAModuleHasItsValues() {
        #expect(EntailmentRegimes::RDF.comment == ["The specification for the RDF entailment is part of the RDF Semantics W3C Recommendation."])
        #expect(RDF::type.label == ["type"])
    }

    /// The documents translate back to the same graph (RDF 1.2 Concepts
    /// §3.7).
    @Test func translatesBackToTheSameGraph() throws {
        let input = try document("Entailment.ttl").union(document("RDF.ttl"))
        let output = try NTriplesDecoder().decode(try NTriplesEncoder().encode(EntailmentRegimes::ontology))
        #expect(input.isIsomorphic(to: output))
    }

    private func document(_ name: String) throws -> Graph {
        let url = URL(filePath: #filePath).deletingLastPathComponent().appending(path: "Fixtures/EntailmentRegimes/\(name)")
        return try TurtleDecoder().decode(try String(contentsOf: url, encoding: .utf8))
    }
}
