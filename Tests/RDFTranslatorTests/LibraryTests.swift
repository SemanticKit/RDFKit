import Testing
import Foundation
import IRIKit
import RDFCore
import RDFFormats
import RDF
import XSD

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

    /// The literals the document states about one individual for one
    /// property, decoded at the boundary.
    private func literals(of individual: any RDFCore.Resource, _ property: TermKey) throws -> [RDFCore.Literal] {
        let url = URL(filePath: #filePath).deletingLastPathComponent().appending(path: "library.ttl")
        let document = try TurtleDecoder().decode(try String(contentsOf: url, encoding: .utf8))
        let subject = SubjectTerm.iri(try #require(IRI(of: individual)))
        return document.compactMap { triple in
            guard triple.subject == subject, triple.predicate == IRI(property),
                  case .literal(let literal) = triple.object else { return nil }
            return literal
        }
    }

    /// `:title` ranges over `xsd:string`, so its values are `XSD.string`
    /// values. The almanac's titles are language-tagged strings, which are
    /// not `xsd:string` values: they stay literals, with their language
    /// tags, and the individual writes them back as they are.
    @Test func literalValuesKeepTheirForm() throws {
        let titles: [XSD.string] = gazette.title
        #expect(titles == ["Gazette"])
        #expect(almanac.title.isEmpty)
        let kept = almanac.storage[PropertyLiterals<titleValue>.self].value
        #expect(Set(kept) == Set(try literals(of: almanac, title.key)))
        #expect(kept.allSatisfy { $0.languageTag != nil })
    }

    /// A property whose range is an XSD datatype holds values of the
    /// datatype's Swift value type, built from the document's literals at
    /// the boundary.
    @Test func datatypeValuesAreTheDatatypesValueTypes() throws {
        let pageCounts: [XSD.nonNegativeInteger] = almanac.pages
        #expect(pageCounts == (try literals(of: almanac, pages.key).map { try XSD.nonNegativeInteger($0) }))
        #expect(pageCounts.first?.value.int == 212)
        let years: [XSD.gYear] = almanac.published
        #expect(years == (try literals(of: almanac, published.key).map { try XSD.gYear($0) }))
    }

    /// Literals a datatype's value type cannot write back as they are, one
    /// not canonical (`"02"`) and one ill-typed (`"third"`), stay literals
    /// beside the property's values, as does a literal of a datatype with no
    /// Swift type, and the data translates back to the same graph
    /// (``translatesBackToTheSameGraph()``).
    @Test func otherLiteralsStayLiterals() throws {
        let editions: [XSD.positiveInteger] = `second-edition`.edition + `third-edition`.edition
        #expect(editions.isEmpty)
        let kept = `second-edition`.storage[PropertyLiterals<editionValue>.self].value
            + `third-edition`.storage[PropertyLiterals<editionValue>.self].value
        #expect(kept == (try literals(of: `second-edition`, edition.key) + literals(of: `third-edition`, edition.key)))
        #expect(throws: DatatypeError.illTyped) { try XSD.positiveInteger(try #require(kept.last)) }
        let catalogueNumbers: [RDFCore.Literal] = almanac.catalogueNumber
        #expect(catalogueNumbers == (try literals(of: almanac, catalogueNumber.key)))
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
