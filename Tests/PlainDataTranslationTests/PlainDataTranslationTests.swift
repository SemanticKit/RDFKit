import Testing
import Foundation
import IRIKit
import RDFCore
import RDFFormats
import PlainData
@testable import RDFTranslator

/// Data translated by `RDFTranslatorPlugin` into `PlainData`, a module with
/// no layer below it, and the order the translator writes nodes in.
@Suite("Data translated to Swift without the layers below it", .tags(.generated))
struct PlainDataTranslationTests {
    /// The documents translate back to the same graph (RDF 1.2 Concepts
    /// §3.7), every `rdf:type` triple included: with no RDF layer below,
    /// `:Person` is not declared as a class, so alice's type is one of her
    /// values.
    @Test func translatesBackToTheSameGraph() throws {
        let input = try document("PlainData/people.ttl").union(document("PlainData/namespaces.ttl"))
        let output = try NTriplesDecoder().decode(try NTriplesEncoder().encode(PlainData.ontology))
        #expect(input.isIsomorphic(to: output))
    }

    /// `:alice a :Person ; :name "Alice"`: encoding alice gives back both
    /// triples the document states about her.
    @Test func typesWithoutAClassDeclarationStayValues() throws {
        let input = try document("PlainData/people.ttl")
        let alice = SubjectTerm.iri(try #require(IRI(of: PlainData.alice)))
        let output = try NTriplesDecoder().decode(try NTriplesEncoder().encode([PlainData.alice]))
        #expect(output == Graph(input.filter { $0.subject == alice }))
        #expect(output.count == 2)
    }

    /// Two namespaces that are canonically equivalent but differ in their
    /// Unicode scalars are two namespaces: IRIs are compared by simple
    /// string comparison (RDF 1.2 Concepts §3.2), so `a` and `b` keep the
    /// IRIs the document gives them.
    @Test(.tags(.boundary)) func namespacesAreComparedByScalars() throws {
        let input = try document("PlainData/namespaces.ttl")
        let subjects = Set(input.map(\.subject))
        let a = SubjectTerm.iri(try #require(IRI(of: PlainData.a)))
        let b = SubjectTerm.iri(try #require(IRI(of: PlainData.b)))
        #expect(subjects == [a, b])
        let output = try NTriplesDecoder().decode(try NTriplesEncoder().encode(PlainData.ontology))
        #expect(Graph(output.filter { subjects.contains($0.subject) }).isIsomorphic(to: input))
    }

    /// The translator's order is total: blank nodes come after IRIs and
    /// are ordered by their identifiers, so sorting a `Set` of nodes gives
    /// one order however the set was built, and every build of one input
    /// writes the same Swift. `restrictions.ttl` has three classes that are
    /// blank nodes.
    @Test func nodeOrderHasNoTies() throws {
        let path = URL(filePath: #filePath).deletingLastPathComponent().appending(path: "Fixtures/restrictions.ttl").path
        let layer = try Layer(module: "Pets", paths: [path], firstDocument: 0)
        let nodes = layer.graph.flatMap { [$0.subject] + [$0.object.node].compactMap(\.self) }
        let blankNodes = nodes.filter { $0.iri == nil }
        #expect(Set(blankNodes).count == 3)

        for lhs in Set(nodes) {
            for rhs in Set(nodes) where lhs != rhs {
                #expect(SubjectTerm.inIRIOrder(lhs, rhs) != SubjectTerm.inIRIOrder(rhs, lhs))
            }
        }
        var larger = Set<SubjectTerm>(minimumCapacity: 4 * nodes.count)
        for node in nodes.reversed() { larger.insert(node) }
        let sorted = Set(nodes).sorted(by: SubjectTerm.inIRIOrder)
        #expect(larger.sorted(by: SubjectTerm.inIRIOrder) == sorted)
        #expect(sorted.suffix(3).allSatisfy { $0.iri == nil })
    }

    private func document(_ path: String) throws -> Graph {
        let url = URL(filePath: #filePath).deletingLastPathComponent().appending(path: "Fixtures/\(path)")
        return try TurtleDecoder().decode(try String(contentsOf: url, encoding: .utf8))
    }
}
