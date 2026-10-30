import Testing
import Foundation
import IRIKit
import RDFCore
import RDFFormats
import RDF
import OWL

/// The layers RDF describes itself in, translated by `RDFTranslatorPlugin`:
/// rdf.ttl and rdfs.ttl into `RDF`, owl.ttl into `OWL` on top of it.
@Suite("RDF, RDFS and OWL translated from their documents", .tags(.generated))
struct LayerTests {
    // MARK: RDF in, Swift out

    /// `rdf:nil a rdf:List`: the individual is a member of its class, and
    /// of `rdfs:Resource`, the class of every resource (rdfs4).
    @Test func individualsAreMembersOfTheirClasses() {
        #expect((RDF.nil as AnyObject) is any RDF.List)
        #expect((RDF.nil as AnyObject) is any RDF.Resource)
        #expect(!((RDF.nil as AnyObject) is any RDF.Class))
    }

    /// `owl:ObjectProperty rdfs:subClassOf rdf:Property`: an OWL class's
    /// protocol refines the protocol of the RDF class it is a subclass of
    /// (RDF 1.2 Semantics, rule rdfs9).
    @Test func membershipFollowsSubClassOfAcrossLayers() {
        let property = OWL.ObjectPropertyIndividual()
        #expect((property as AnyObject) is any OWL.ObjectProperty)
        #expect((property as AnyObject) is any RDF.Property)
    }

    /// A property is a term type, never a module-level value: it carries its
    /// declared key and writes what its document states about it, the
    /// classes it is a member of included (`rdf:type a rdf:Property`).
    @Test func propertiesDescribeThemselvesThroughTheirKeys() throws {
        let rdf = try document("../ParallelTests/Fixtures/W3C/rdf.ttl")
        let type = SubjectTerm.iri(try #require(IRI(RDF.type.key)))
        #expect(try GraphEncoder().encode(RDF.type()) == Graph(rdf.filter { $0.subject == type }))

        let owl = try document("../../Sources/OWL/owl.ttl")
        let sameAs = SubjectTerm.iri(try #require(IRI(OWL.sameAs.key)))
        #expect(try GraphEncoder().encode(OWL.sameAs()) == Graph(owl.filter { $0.subject == sameAs }))
    }

    /// `rdfs:label` has domain `rdfs:Resource`, so every individual has it,
    /// and its values are the literals the document states.
    @Test func propertiesAreMembersOfTheirDomain() throws {
        let rdf = try document("../ParallelTests/Fixtures/W3C/rdf.ttl")
        let labels: [RDFCore.Literal] = rdf.compactMap { triple in
            guard triple.subject == .iri(IRI(of: RDF.nil)!), triple.predicate == IRI(RDF.label.key),
                  case .literal(let literal) = triple.object else { return nil }
            return literal
        }
        #expect(!labels.isEmpty)
        #expect(RDF.nil.label == labels)
    }

    /// A class is a protocol and a Swift class, and in object position it is
    /// that Swift type: `rdf:first rdfs:domain rdf:List`, written at the
    /// boundary as the IRI its declared key gives.
    @Test func classesAreTypes() throws {
        let domain = try GraphEncoder().encode(RDF.first()).filter { $0.predicate == IRI(RDF.domain.key) }
        #expect(domain.map(\.object) == [.iri(IRI(of: RDF.ListIndividual.self)!)])
    }

    /// A property in object position is its term type: `owl:onProperty`
    /// ranges over `rdf:Property`, so its values are term types, written at
    /// the boundary as the IRIs their declared keys give.
    @Test func propertiesInObjectPositionAreTheirTermTypes() throws {
        let restriction = OWL.RestrictionIndividual()
        restriction.onProperty = [RDF.first.self]
        let output = try GraphEncoder().encode(restriction)
        #expect(output.contains { $0.predicate == IRI(OWL.onProperty.key) && $0.object == .iri(IRI(RDF.first.key)!) })
    }

    /// A value set through a member is read back through it.
    @Test func propertyValuesChange() {
        let list = RDF.ListIndividual()
        list.first = [.individual(RDF.nil)]
        list.rest = [RDF.nil]
        guard case .individual(let first)? = list.first.first else {
            Issue.record("rdf:first holds the individual it was given")
            return
        }
        #expect(first === RDF.nil)
        #expect(list.rest.first === RDF.nil)
        list.rest = []
        #expect(list.rest.isEmpty)
    }

    // MARK: Swift back to RDF

    /// The RDF and RDF Schema documents come back as the same graph
    /// (RDF 1.2 Concepts §3.7).
    @Test func rdfTranslatesBackToTheSameGraph() throws {
        let input = try document("../ParallelTests/Fixtures/W3C/rdf.ttl").union(document("../ParallelTests/Fixtures/W3C/rdfs.ttl"))
        let output = try NTriplesDecoder().decode(try NTriplesEncoder().encode(RDF.ontology))
        #expect(input.isIsomorphic(to: output))
    }

    /// The OWL 2 document comes back as the same graph.
    @Test func owlTranslatesBackToTheSameGraph() throws {
        let input = try document("../../Sources/OWL/owl.ttl")
        let output = try NTriplesDecoder().decode(try NTriplesEncoder().encode(OWL.ontology))
        #expect(input.isIsomorphic(to: output))
    }

    private func document(_ path: String) throws -> Graph {
        let url = URL(filePath: #filePath).deletingLastPathComponent().appending(path: path)
        return try TurtleDecoder().decode(try String(contentsOf: url, encoding: .utf8))
    }
}
