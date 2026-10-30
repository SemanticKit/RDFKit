import Testing
import Foundation
import IRIKit
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
    /// declares, are the literals the document states; the RDF module's
    /// properties stay reachable through their term types.
    @Test func individualNamedLikeAModuleHasItsValues() throws {
        let document = try document("Entailment.ttl").union(document("RDF.ttl"))
        let comments: [RDFCore::Literal] = document.compactMap { triple in
            guard triple.subject == .iri(IRI(of: EntailmentRegimes::RDF)!), triple.predicate == IRI(RDF::comment.key),
                  case .literal(let literal) = triple.object else { return nil }
            return literal
        }
        #expect(!comments.isEmpty)
        #expect(EntailmentRegimes::RDF.comment == comments)
        #expect(!(try GraphEncoder().encode(RDF::type())).isEmpty)
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
