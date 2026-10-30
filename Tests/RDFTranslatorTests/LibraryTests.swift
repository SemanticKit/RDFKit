import Testing
import Foundation
import RDFCore
import RDFFormats
import RDFRuntime
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

    /// `:almanac a :Annual`: the individual is an instance of the Swift
    /// class of its class, and an individual made in Swift is one too.
    @Test func individualsAreInstancesOfTheirClass() throws {
        #expect(type(of: almanac) == AnnualIndividual.self)
        let reprint = BookIndividual(iri: "https://library.example/vocabulary#reprint")
        reprint.cites = [almanac]
        reprint.title = ["Almanac, reprint"]
        let output = try NTriplesDecoder().decode(try NTriplesEncoder().encode([reprint]))
        #expect(output.count == 3)
        #expect(output.contains { $0.predicate.rawValue == "http://www.w3.org/1999/02/22-rdf-syntax-ns#type" && $0.object == .iri("https://library.example/vocabulary#Book") })
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
        #expect(almanac.pages == [try Literal("212", datatype: "http://www.w3.org/2001/XMLSchema#nonNegativeInteger")])
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
        #expect(subjects.contains(.iri("https://library.example/vocabulary#gazette")))
    }
}
