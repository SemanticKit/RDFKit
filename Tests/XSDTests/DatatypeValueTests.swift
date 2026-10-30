import Testing
import Foundation
import IRIKit
import RDFCore
import RDFFormats
import Samples
import XSD

/// A property whose range is an XSD datatype holds values of the
/// datatype's Swift value type (``RDFCore/DatatypeValue``), and the format
/// encoders write each as a literal: the one it was decoded from, or its
/// canonical form with its datatype IRI. `Samples` (samples.ttl) gives a property for each datatype;
/// `typical` and `unusual` in `mappings.ttl` give them values.
@Suite("Literal-ranged properties hold the XSD value types", .tags(.datatype, .generated, .boundary))
struct DatatypeValueTests {
    static func document() throws -> Graph {
        let url = URL(filePath: #filePath).deletingLastPathComponent().appending(path: "mappings.ttl")
        return try TurtleDecoder().decode(try String(contentsOf: url, encoding: .utf8))
    }

    /// The triples the document states about one individual.
    static func description(of individual: any Resource) throws -> Graph {
        let subject = SubjectTerm.iri(try #require(IRI(of: individual)))
        return Graph(try document().filter { $0.subject == subject })
    }

    /// Each property is typed by its range, and its values are the values
    /// of the document's literals.
    @Test func propertiesAreTypedByTheirDatatypes() throws {
        let integer: [XSD.integer] = typical.integer
        let instant: [XSD.dateTime] = typical.dateTime
        let flag: [XSD.boolean] = typical.boolean
        #expect(integer.map(\.lexicalForm) == ["12345678901234567890"])
        #expect(instant.first?.value.timezoneOffset == 60)
        #expect(flag.first?.value == true)
        #expect(typical.string == ["Almanac"])
        #expect(typical.nonNegativeInteger.first?.value.isZero == true)
    }

    /// The values encode back to the document's literals: the canonical
    /// lexical form, with the datatype IRI the datatype's declared key
    /// gives, one for each of the 39 datatypes.
    @Test func valuesEncodeToTheirLiterals() throws {
        let output = try GraphEncoder().encode(typical)
        #expect(output == (try Self.description(of: typical)), "\(output)")
        #expect(output.count == 40)  // rdf:type and one value of each datatype
    }

    /// A literal of a datatype derived from the range's primitive, well-typed
    /// in its own datatype, whose value is in the range's value space, is a
    /// value of the range, and writes back as the literal it was: one not in
    /// canonical form, one of a datatype the range is derived from, one of a
    /// datatype derived from the range, and one of another datatype derived
    /// from the same primitive (RDF 1.2 Concepts §5: the literal value is the
    /// lexical-to-value mapping of its lexical form).
    @Test func literalsOfRelatedDatatypesAreValuesOfTheRange() throws {
        let counts: [XSD.nonNegativeInteger] = unusual.nonNegativeInteger
        #expect(Set(counts.map(\.lexicalForm)) == ["5", "7", "3", "4"])
        #expect(Set(counts.map(\.literalForm.lexicalForm)) == ["5", "07", "3", "4"])
        #expect(Set(counts.map(\.literalForm.datatype.name)) == ["nonNegativeInteger", "integer", "unsignedByte"])
        #expect(counts.contains(try XSD.nonNegativeInteger(lexicalForm: "7")))  // "07" is 7
        #expect(unusual.boolean.map(\.value) == [true])
        #expect(unusual.boolean.map(\.literalForm.lexicalForm) == ["1"])
        #expect(unusual.byte.map(\.lexicalForm) == ["5"])
        #expect(unusual.byte.map(\.literalForm.datatype.name) == ["unsignedByte"])
    }

    /// Literals that denote no value of the range stay literals at the
    /// boundary: ill-typed, outside the range's value space, of another
    /// primitive, language-tagged, or of a datatype with no Swift type. The
    /// properties hold only the values, and the individual writes every
    /// literal back as the document states it.
    @Test func otherLiteralsSurviveAndRoundTrip() throws {
        let kept = try EncodedValues(of: unusual)
        #expect(Set(kept.literals(of: Samples.nonNegativeInteger.key).map(\.lexicalForm)) == ["-1", "-2"])
        #expect(kept.literals(of: Samples.boolean.key).map(\.lexicalForm) == ["yes"])
        #expect(unusual.decimal.isEmpty)
        #expect(kept.literals(of: Samples.decimal.key).map(\.lexicalForm) == ["1.5"])
        #expect(unusual.string.isEmpty)
        #expect(Set(kept.literals(of: Samples.string.key).map(\.lexicalForm)) == ["x", "y"])
        let output = try GraphEncoder().encode(unusual)
        #expect(output == (try Self.description(of: unusual)), "\(output)")
    }

    /// A decoder reads a document's literals into the XSD value types, and
    /// keeps the literals that denote none as literals: the decoded
    /// individuals encode back to the document's triples (rule 20, Literal
    /// is the boundary node).
    @Test func decodedLiteralsAreValuesOrStayLiterals() throws {
        let document = try Self.document()
        let context = DocumentContext()
        let samples = try GraphDecoder(classes: [Samples.SampleIndividual.self])
            .decode((any Samples.SampleStoring).self, from: document, context: context)
        let decodedTypical = try #require(samples.first { context.iri(of: $0) == IRI(of: typical) })
        let decodedUnusual = try #require(samples.first { context.iri(of: $0) == IRI(of: unusual) })
        #expect(decodedTypical.dateTime == typical.dateTime)
        #expect(decodedTypical.base64Binary == typical.base64Binary)
        #expect(Set(decodedUnusual.nonNegativeInteger.map(\.lexicalForm)) == ["5", "7", "3", "4"])
        #expect(decodedUnusual.boolean.map(\.value) == [true])
        #expect(decodedUnusual.storage.keptLiterals(of: Samples.booleanValue.self).map(\.lexicalForm) == ["yes"])
        let expected = try Self.description(of: typical).union(try Self.description(of: unusual))
        #expect(try GraphEncoder(context: context).encode([decodedTypical, decodedUnusual]) == expected)
    }

    /// Setting a property states its values anew: the literals kept for it,
    /// which Swift cannot see through the accessor, are no longer written.
    @Test func settingAPropertyReplacesItsKeptLiterals() throws {
        let context = DocumentContext()
        let decoded = try GraphDecoder(classes: [Samples.SampleIndividual.self])
            .decode(Samples.SampleIndividual.self, for: [try #require(IRI(of: unusual))], from: try Self.document(), context: context)
        let sample = try #require(decoded.first)
        sample.boolean = [false]
        #expect(sample.storage.keptLiterals(of: Samples.booleanValue.self).isEmpty)
        let written = try GraphEncoder(context: context).encode([sample]).filter { $0.predicate == IRI(Samples.boolean.key) }
        #expect(written.compactMap { if case .literal(let literal) = $0.object { literal.lexicalForm } else { nil } } == ["false"])
        sample.nonNegativeInteger.append(try XSD.nonNegativeInteger(lexicalForm: "1"))
        #expect(sample.storage.keptLiterals(of: Samples.nonNegativeIntegerValue.self).isEmpty)
    }

    /// `RDFTranslatorPlugin` reads each literal with the range's Swift type
    /// while it translates, and writes the value it denotes as that value
    /// type: every translated individual of `mappings.ttl` holds the values
    /// a decoder reads from the document, each written with the same lexical
    /// form and datatype, and keeps the same literals.
    @Test func translatedValuesAreTheDecodedValues() throws {
        let context = DocumentContext()
        let decoded = try GraphDecoder(classes: [Samples.SampleIndividual.self, MappingIndividual.self, EqualIndividual.self, IllTypedIndividual.self])
            .decode((any Samples.SampleStoring).self, from: try Self.document(), context: context)
        let translated = ontology.compactMap { $0 as? any Samples.SampleStoring }
        #expect(translated.count == decoded.count)
        for individual in translated {
            let iri = try #require(IRI(of: individual))
            let match = try #require(decoded.first { context.iri(of: $0) == iri }, "\(iri)")
            let values = try EncodedValues(of: individual)
            let decodedValues = try EncodedValues(of: match)
            #expect(values.values.count == decodedValues.values.count, "\(iri)")
            for value in values.values {
                #expect(decodedValues.values.contains { decodedValue in
                    // A value that is not equal to itself (NaN) is compared by its
                    // type and written form.
                    value.property == decodedValue.property
                        && type(of: value.value) == type(of: decodedValue.value)
                        && (value.value.isEqual(to: decodedValue.value) || !value.value.isEqual(to: value.value))
                        && value.value.literalForm.lexicalForm.unicodeScalars.elementsEqual(decodedValue.value.literalForm.lexicalForm.unicodeScalars)
                        && value.value.literalForm.datatype == decodedValue.value.literalForm.datatype
                }, "\(iri): \(value.property) \(value.value.literalForm.lexicalForm)")
            }
            #expect(Set(values.literals.map(\.literal)) == Set(decodedValues.literals.map(\.literal)), "\(iri)")
        }
    }

    /// The whole document translates back to the same graph (RDF 1.2
    /// Concepts §3.7).
    @Test func documentTranslatesBackToTheSameGraph() throws {
        let output = try NTriplesDecoder().decode(try NTriplesEncoder().encode(ontology))
        #expect(output.isIsomorphic(to: try Self.document()))
    }

    /// The samples vocabulary translates back to the graph of `samples.ttl`.
    @Test func samplesTranslateBackToTheSameGraph() throws {
        let url = URL(filePath: #filePath).deletingLastPathComponent().appending(path: "Fixtures/Samples/samples.ttl")
        let input = try TurtleDecoder().decode(try String(contentsOf: url, encoding: .utf8))
        let output = try NTriplesDecoder().decode(try NTriplesEncoder().encode(Samples.ontology))
        #expect(output.isIsomorphic(to: input))
    }
}
