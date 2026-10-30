import Foundation
import IRIKit
import AliceProfile
import FOAF
import RDFCore
import RDFFormats
import Testing

/// A document decoded into the individuals it describes, and encoded back.
///
/// The decoder makes the Swift individuals; the IRIs of the document stay in
/// its ``DocumentContext``, which is what writes them back.
@Suite("Graph decoder", .tags(.boundary))
struct GraphDecoderTests {
    /// `:alice a foaf:Person ; foaf:knows :bob`: each node becomes a
    /// `FOAF.Person`, its values are typed Swift values, and the individuals
    /// refer to each other, cycles included.
    @Test("A document decodes to the individuals it describes")
    func decodesIndividuals() throws {
        let graph = try profile()
        let context = DocumentContext()
        let people = try GraphDecoder(classes: [FOAF.PersonIndividual.self])
            .decode((any FOAF.PersonStoring).self, from: graph, context: context)
        #expect(people.count == 2)
        let decodedAlice = try #require(people.first { context.iri(of: $0) == IRI(of: alice) })
        let decodedBob = try #require(people.first { context.iri(of: $0) == IRI(of: bob) })
        #expect((decodedAlice as AnyObject) is any FOAF.Agent)
        #expect(decodedAlice.knows.contains { $0 === decodedBob })
        #expect(decodedBob.knows.contains { $0 === decodedAlice })
        #expect(decodedAlice.name == alice.name)
        #expect(decodedBob.name == bob.name)
    }

    /// The decoded individuals hold no IRI: an encoder without the context
    /// writes them as blank nodes, and one given the context writes them
    /// with the document's IRIs, the same graph.
    @Test("The context, not the individual, holds the document's IRIs")
    func contextHoldsTheIRIs() throws {
        let graph = try profile()
        let context = DocumentContext()
        let people = try GraphDecoder(classes: [FOAF.PersonIndividual.self])
            .decode((any FOAF.PersonStoring).self, from: graph, context: context)
        #expect(people.allSatisfy { IRI(of: $0) == nil })

        let anonymous = try GraphEncoder().encode(people)
        #expect(anonymous.allSatisfy { if case .blankNode = $0.subject { true } else { false } })
        #expect(anonymous.isIsomorphic(to: graph) == false)

        let encoded = try GraphEncoder(context: context).encode(people)
        #expect(encoded == graph)
        let document = try NTriplesDecoder().decode(NTriplesEncoder().encode(encoded))
        #expect(document == graph)
    }

    /// A named individual the decoder is given is the individual the
    /// document names, not a new one.
    @Test("A named individual decodes to itself")
    func namedIndividualsDecodeToThemselves() throws {
        let graph = try profile()
        let context = DocumentContext()
        let people = try GraphDecoder(classes: [FOAF.PersonIndividual.self], individuals: [bob])
            .decode((any FOAF.PersonStoring).self, from: graph, context: context)
        let decodedAlice = try #require(people.first { context.iri(of: $0) == IRI(of: alice) })
        #expect(decodedAlice.knows.contains { $0 === bob })
    }

    /// A node the decoder is told the class of decodes as a member of it.
    @Test("A node decodes as the class the caller states")
    func decodesTheStatedClass() throws {
        let graph = try profile()
        let context = DocumentContext()
        let iri = try #require(IRI(of: alice))
        let agents = try GraphDecoder(classes: [])
            .decode(FOAF.AgentIndividual.self, for: [iri], from: graph, context: context)
        #expect(agents.count == 1)
        #expect(context.iri(of: agents[0]) == iri)
        #expect(context.individual(for: iri) === agents[0])
        #expect(agents[0].name == alice.name)
    }

    /// A context holds one individual for each IRI: decoding the document
    /// again with it gives the same instances, through either entry point.
    @Test("Decoding twice with one context gives the same individuals")
    func oneIndividualForEachIRI() throws {
        let graph = try profile()
        let context = DocumentContext()
        let decoder = GraphDecoder(classes: [FOAF.PersonIndividual.self])
        let first = try decoder.decode((any FOAF.PersonStoring).self, from: graph, context: context)
        let second = try decoder.decode((any FOAF.PersonStoring).self, from: graph, context: context)
        let iri = try #require(IRI(of: alice))
        let firstAlice = try #require(first.first { context.iri(of: $0) == iri })
        let secondAlice = try #require(second.first { context.iri(of: $0) == iri })
        #expect(firstAlice === secondAlice)
        #expect(context.individual(for: iri) === firstAlice)
        #expect(secondAlice.knows.count == firstAlice.knows.count)

        let stated = try GraphDecoder(classes: [])
            .decode(FOAF.PersonIndividual.self, for: [iri], from: graph, context: context)
        #expect(stated.first === firstAlice)
        #expect(try GraphEncoder(context: context).encode(first) == graph)
    }

    /// `:alice rdfs:seeAlso <<( :bob foaf:name "Bob" )>>`: a property whose
    /// range admits any resource holds a triple term as a
    /// ``RDFCore/Value/tripleTerm(subject:predicate:object:)`` of Swift
    /// values, and encodes back to the same triple term.
    @Test("A triple term decodes to the Swift values of its components, and encodes back")
    func tripleTermValue() throws {
        let url = URL(filePath: #filePath).deletingLastPathComponent()
            .appending(path: "Fixtures/triple-term-value.ttl")
        let graph = try TurtleDecoder().decode(try String(contentsOf: url, encoding: .utf8))
        let context = DocumentContext()
        let people = try GraphDecoder(classes: [FOAF.PersonIndividual.self], properties: [FOAF.name.self])
            .decode((any FOAF.PersonStoring).self, from: graph, context: context)
        #expect(people.count == 2)
        let decodedAlice = try #require(people.first { $0.name.first?.lexicalForm == "Alice" })
        let decodedBob = try #require(people.first { $0.name.first?.lexicalForm == "Bob" })
        #expect(decodedAlice.seeAlso.count == 1)
        guard case .tripleTerm(.individual(let subject), let predicate, .literal(let object))? = decodedAlice.seeAlso.first else {
            Issue.record("expected a triple term of an individual, a property and a literal")
            return
        }
        #expect(subject === decodedBob)
        #expect(ObjectIdentifier(predicate) == ObjectIdentifier(FOAF.name.self))
        #expect(decodedBob.name == [object])

        let encoded = try GraphEncoder(context: context).encode(people)
        #expect(encoded.isIsomorphic(to: graph))
    }

    /// The profile, as the document states it (`alice.ttl`).
    private func profile() throws -> Graph {
        let url = URL(filePath: #filePath).deletingLastPathComponent()
            .appending(path: "../ParallelTests/Fixtures/AliceProfile/alice.ttl")
        return try TurtleDecoder().decode(try String(contentsOf: url, encoding: .utf8))
    }
}
