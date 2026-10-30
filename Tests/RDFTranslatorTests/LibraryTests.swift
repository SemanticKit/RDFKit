import Testing
import Foundation
import IRIKit
import RDFCore
import RDFFormats
import RDF

/// `library.ttl`, translated into this test module by `RDFTranslatorPlugin`.
@Suite("A vocabulary and its data translated to Swift", .tags(.generated))
struct LibraryTests {
    /// `:Annual rdfs:subClassOf :Book, :Periodical`: one individual is a
    /// member of both classes and of their superclass.
    @Test func membershipFollowsSeveralSuperclasses() {
        #expect((almanac as AnyObject) is any Book)
        #expect((almanac as AnyObject) is any Periodical)
        #expect((almanac as AnyObject) is any Work)
        #expect(!((gazette as AnyObject) is any Book))
    }

    /// `:almanac a :Annual`: the named individual is a member of its class,
    /// and an individual made in Swift is an instance of the class's Swift
    /// class. No declaration names the one made in Swift, so it is a blank
    /// node at the boundary.
    @Test func individualsAreInstancesOfTheirClass() throws {
        #expect((almanac as AnyObject) is any Annual)
        let reprint = BookIndividual()
        reprint.cites = [almanac]
        reprint.title = ["Almanac, reprint"]
        let output = try NTriplesDecoder().decode(try NTriplesEncoder().encode([reprint]))
        #expect(output.count == 3)
        #expect(output.allSatisfy { if case .blankNode = $0.subject { true } else { false } })
        #expect(output.contains { $0.predicate == IRI(RDF.type.key) && $0.object == .iri(IRI(of: BookIndividual.self)!) })
        #expect(output.contains { $0.object == .iri(IRI(of: almanac)!) })
    }

    /// Values that are individuals are the individuals themselves, cycles
    /// included, and a resource can name itself.
    @Test func objectValuesAreTheIndividuals() {
        #expect(almanac.cites.count == 1)
        #expect(almanac.cites.first === gazette)
        #expect(gazette.cites.first === almanac)
        #expect(`second-edition`.cites.contains { $0 === `second-edition` })
    }

    /// Literal values keep their language tags and datatypes.
    @Test func literalValuesKeepTheirForm() throws {
        #expect(Set(almanac.title) == [
            try Literal("Almanac", languageTag: "en"),
            try Literal("Almanach", languageTag: "de"),
        ])
        // The typed literal as the document states it, decoded at the boundary.
        let url = URL(filePath: #filePath).deletingLastPathComponent().appending(path: "library.ttl")
        let document = try TurtleDecoder().decode(try String(contentsOf: url, encoding: .utf8))
        let pages: [RDFCore.Literal] = document.compactMap { triple in
            guard triple.subject == .iri(IRI(of: almanac)!), triple.predicate == IRI(pages.key),
                  case .literal(let literal) = triple.object else { return nil }
            return literal
        }
        #expect(pages.count == 1)
        #expect(almanac.pages == pages)
        #expect(gazette.title == ["Gazette"])
    }

    /// The data translates back to the same graph, blank nodes and the
    /// `rdf:List` of editors included (RDF 1.2 Concepts §3.7).
    @Test func translatesBackToTheSameGraph() throws {
        let url = URL(filePath: #filePath).deletingLastPathComponent().appending(path: "library.ttl")
        let input = try TurtleDecoder().decode(try String(contentsOf: url, encoding: .utf8))
        let output = try NTriplesDecoder().decode(try NTriplesEncoder().encode(ontology))
        #expect(input.isIsomorphic(to: output))
    }

    /// Encoding only some individuals gives only their descriptions, with
    /// the individuals they refer to written as IRIs.
    @Test func individualsTranslateBackToTheirDescriptions() throws {
        let output = try NTriplesDecoder().decode(try NTriplesEncoder().encode([gazette]))
        let subjects = Set(output.map(\.subject))
        // The gazette and the blank node of the note it refers to.
        #expect(subjects.count == 2)
        #expect(subjects.contains(.iri(IRI(of: gazette)!)))
    }
}
