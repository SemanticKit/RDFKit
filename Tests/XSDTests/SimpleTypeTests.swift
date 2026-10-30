import Testing
import Foundation
import RDFCore
import RDFFormats
import Samples
import XSD

/// Each XSD datatype is a Swift value type built from a lexical form, with
/// the value space, lexical-to-value mapping and canonical mapping of XML
/// Schema 1.1 Part 2. The literals come from `mappings.ttl`, which
/// `RDFTranslatorPlugin` translates into this test module: each is the value
/// of the samples property that ranges over its datatype, so it is a value
/// of the datatype's Swift type. Each `Mapping` pairs a literal with the
/// canonical form of its value, each `Equal` gives two lexical forms of one
/// value, and each `IllTyped` a literal outside its datatype's lexical
/// space.
@Suite("XSD datatypes as Swift value types", .tags(.datatype))
struct SimpleTypeTests {
    static var mappings: [any Mapping] { ontology.compactMap { $0 as? any Mapping } }
    static var equalities: [any Equal] { ontology.compactMap { $0 as? any Equal } }
    static var illTyped: [any IllTyped] { ontology.compactMap { $0 as? any IllTyped } }

    /// The lexical mapping gives each literal its value, which writes back
    /// the literal as it was written, and the canonical mapping writes the
    /// value as its canonical representation, which maps to the same value
    /// again.
    @Test func lexicalFormsMapToTheCanonicalFormsOfTheirValues() throws {
        #expect(Self.mappings.count == 59)
        for mapping in Self.mappings {
            let canonical = try #require(mapping.canonical.first?.literalValue?.lexicalForm)
            let encoded = try EncodedValues(of: mapping)
            #expect(encoded.literals(besides: XSDTests::canonical.key).isEmpty, "\(canonical)")
            let value = try #require(encoded.datatypeValues.first, "\(canonical)")
            #expect(encoded.datatypeValues.count == 1)
            #expect(value.lexicalForm == canonical)
            #expect(try type(of: value).value(of: canonical).lexicalForm == canonical)
        }
    }

    /// Every datatype RDF 1.2 Concepts §5.1 lists has a mapping in the
    /// fixture, as a value of its Swift type.
    @Test func everyDatatypeIsExercised() throws {
        let exercised = try Self.mappings.flatMap { try EncodedValues(of: $0).datatypeValues.map { type(of: $0).datatype.name } }
        #expect(Set(exercised) == Set(try DatatypeTranslationTests.translation().datatypes.map(\.name)))
    }

    /// Two lexical forms of one value give equal values: a value is the
    /// datatype's value, not its lexical form (the time line for dateTime,
    /// months and seconds for duration, the number for decimal).
    @Test func lexicalFormsOfOneValueGiveEqualValues() throws {
        #expect(Self.equalities.count == 6)
        for equality in Self.equalities {
            let values = try EncodedValues(of: equality).datatypeValues
            #expect(values.count == 2)
            #expect(values[0].isEqual(to: values[1]), "\(values[0]) and \(values[1])")
        }
    }

    /// An ill-typed literal has no value: its lexical form is not in the
    /// lexical space, by the primitive's lexical representation or by a
    /// facet of the datatype's definition (RDF 1.2 Concepts §3.4). It stays
    /// the literal.
    @Test func illTypedLiteralsHaveNoValue() throws {
        #expect(Self.illTyped.count == 43)
        for illTyped in Self.illTyped {
            let encoded = try EncodedValues(of: illTyped)
            #expect(encoded.datatypeValues.isEmpty, "\(encoded.datatypeValues)")
            #expect(encoded.literals.count == 1)
        }
    }

    /// The values are the value spaces of XML Schema 1.1 Part 2: numbers,
    /// the seven-property model, months and seconds, octets.
    @Test func valuesAreInTheirValueSpaces() throws {
        let endOfDay = try #require(`dateTime-end-of-day`.dateTime.first)
        #expect(endOfDay.value.day == 31)
        #expect(endOfDay.value.hour == 0)
        #expect(endOfDay.value.timezoneOffset == -300)
        let duration = try #require(`duration-hours`.duration.first)
        #expect(duration.value.months.isZero)
        #expect(duration.value.seconds == DecimalNumber(129_600))
        let largest = try #require(`unsignedLong-largest`.unsignedLong.first)
        #expect(largest.value.int == nil)  // beyond Int: integers are unbounded
        let octets = try #require(`hexBinary-lower-case`.hexBinary.first)
        #expect(octets.value == [0x0F, 0xB7])
        let notANumber = try #require(`double-not-a-number`.double.first)
        #expect(notANumber.value.isNaN)
        #expect(notANumber != notANumber)  // NaN is not equal to itself
    }

    /// The datatypes the DSL and generated code write as literals of Swift:
    /// `true` is an `xsd:boolean`, `"Almanac"` an `xsd:string`.
    @Test func literalsOfSwiftAreValues() throws {
        let deprecated: [XSD.boolean] = [true]
        #expect(deprecated.map(\.lexicalForm) == ["true"])
        let title: XSD.string = "Almanac"
        #expect(title.value.text == "Almanac")
        let count: XSD.integer = 212
        #expect(count.lexicalForm == "212")
    }
}
