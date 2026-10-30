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

    /// `rdf:nil a rdf:List`: the individual is a member of its class.
    @Test func individualsAreMembersOfTheirClasses() {
        #expect((RDF.nil as AnyObject) is any RDF.List)
        #expect((RDF.type as AnyObject) is any RDF.Property)
        #expect((OWL.sameAs as AnyObject) is any RDF.Property)
        #expect(!((RDF.type as AnyObject) is any RDF.Class))
    }

    /// `owl:ObjectProperty rdfs:subClassOf rdf:Property`: an OWL class's
    /// protocol refines the protocol of the RDF class it is a subclass of
    /// (RDF 1.2 Semantics, rule rdfs9).
    @Test func membershipFollowsSubClassOfAcrossLayers() {
        #expect((OWL.topObjectProperty as AnyObject) is any OWL.ObjectProperty)
        #expect((OWL.topObjectProperty as AnyObject) is any RDF.Property)
    }

    /// `rdfs:label` has domain `rdfs:Resource`, so every resource has it,
    /// and its values are the literals the document states.
    @Test func propertiesAreMembersOfTheirDomain() {
        #expect(RDF.type.label == ["type"])
        #expect(OWL.sameAs.comment == ["The property that determines that two given individuals are equal."])
        // `rdfs:domain` has domain `rdf:Property`.
        #expect(RDF.first.domain.count == 1)
    }

    /// A class is a protocol and a Swift class, and in object position it is
    /// that Swift type: `rdf:first rdfs:domain rdf:List`.
    @Test func classesAreTypes() throws {
        #expect((RDF.nil as AnyObject) is any RDF.List)
        #expect(RDF.first.domain.contains { $0 == RDF.ListIndividual.self })
        // At the boundary, the class is written as the IRI its declared key gives.
        let domain = try GraphEncoder().encode(RDF.first).filter { $0.predicate == IRI(RDF.domainValue.key) }
        #expect(domain.map(\.object) == [.iri(IRI(of: RDF.ListIndividual.self)!)])
    }

    /// A value set through a member is read back through it.
    @Test func propertyValuesChange() {
        let property = RDF.value
        let labels = property.label
        property.label = ["value", "valeur"]
        #expect(property.label == ["value", "valeur"])
        property.label = labels
        #expect(property.label == ["value"])
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
