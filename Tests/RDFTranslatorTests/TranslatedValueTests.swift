import Testing
import Foundation
import IRIKit
import RDFCore
import RDFFormats
import XSD

/// `RDFTranslatorPlugin` reads each literal the documents give a property
/// whose range is an XSD datatype with the range's Swift type while it
/// translates, and writes the value the literal denotes as that value
/// type, `XSD::nonNegativeInteger(lexicalForm: "02", writtenAs: XSD::integer.self)`:
/// only a literal that denotes no value of the range stays a literal
/// (DESIGN-CONTRACT rule 20, decision D6 A). The translated individuals of
/// `library.ttl` hold the values a decoder reads from the same document,
/// each written as the document writes it.
@Suite("Literals translated as the values they denote", .tags(.generated, .boundary))
struct TranslatedValueTests {
    static func document() throws -> Graph {
        let url = URL(filePath: #filePath).deletingLastPathComponent().appending(path: "library.ttl")
        return try TurtleDecoder().decode(try String(contentsOf: url, encoding: .utf8))
    }

    /// The values and kept literals of one property, the same on the
    /// translated individual and on the one decoded from the document:
    /// equal values, each written with the same lexical form and datatype.
    private func expectSame<Value: DatatypePropertyValue>(
        _ property: Value.Type,
        _ translated: any PropertyValueStoring,
        _ decoded: any PropertyValueStoring,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        let translatedValues = translated.storage[property].value
        let decodedValues = decoded.storage[property].value
        #expect(translatedValues == decodedValues, sourceLocation: sourceLocation)
        #expect(translatedValues.map(\.literalForm.lexicalForm) == decodedValues.map(\.literalForm.lexicalForm), sourceLocation: sourceLocation)
        #expect(translatedValues.map(\.literalForm.datatype) == decodedValues.map(\.literalForm.datatype), sourceLocation: sourceLocation)
        #expect(Set(translated.storage.keptLiterals(of: property)) == Set(decoded.storage.keptLiterals(of: property)), sourceLocation: sourceLocation)
    }

    /// Every XSD-ranged value of every translated individual is the value,
    /// and the kept literals are the literals, that `GraphDecoder` reads from
    /// `library.ttl`: `212` (an `xsd:integer` literal) is the
    /// `xsd:nonNegativeInteger` 212 written as `xsd:integer`, `"02"` is 2
    /// written `"02"`, and `"third"` and the language-tagged titles stay
    /// literals.
    @Test func translatedValuesAreTheDecodedValues() throws {
        let context = DocumentContext()
        let decoded = try GraphDecoder(classes: [BookIndividual.self, AnnualIndividual.self, PeriodicalIndividual.self])
            .decode((any WorkStoring).self, from: try Self.document(), context: context)
        let translated: [any WorkStoring] = [almanac, gazette, `second-edition`, `third-edition`]
        for individual in translated {
            let iri = try #require(IRI(of: individual))
            let match = try #require(decoded.first { context.iri(of: $0) == iri }, "\(iri)")
            expectSame(titleValue.self, individual, match)
            expectSame(pagesValue.self, individual, match)
            expectSame(editionValue.self, individual, match)
            expectSame(publishedValue.self, individual, match)
        }
        #expect(almanac.pages.map(\.literalForm.datatype) == [XSD.integer.datatype])
        #expect(`second-edition`.edition.map(\.literalForm.lexicalForm) == ["02"])
        #expect(`third-edition`.storage.keptLiterals(of: editionValue.self).map(\.lexicalForm) == ["third"])
    }

    /// Stating the values as values leaves the round trip unchanged: the
    /// translated data encodes back to the graph of `library.ttl` (RDF 1.2
    /// Concepts §3.7).
    @Test func libraryTranslatesBackUnchanged() throws {
        let output = try NTriplesDecoder().decode(try NTriplesEncoder().encode(ontology))
        #expect(output.isIsomorphic(to: try Self.document()))
    }
}
