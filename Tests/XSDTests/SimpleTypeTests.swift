import Testing
import Foundation
import RDFCore
import RDFFormats
import XSD

/// Each XSD datatype is a Swift value type built from a lexical form, with
/// the value space, lexical-to-value mapping and canonical mapping of XML
/// Schema 1.1 Part 2. The literals come from `mappings.ttl`, which
/// `RDFTranslatorPlugin` translates into this test module: each `Mapping`
/// pairs a literal with the literal of its value's canonical form, each
/// `Equal` gives two lexical forms of one value, and each `IllTyped` a
/// literal outside its datatype's lexical space.
@Suite("XSD datatypes as Swift value types", .tags(.datatype))
struct SimpleTypeTests {
    static var mappings: [any Mapping] { ontology.compactMap { $0 as? any Mapping } }
    static var equalities: [any Equal] { ontology.compactMap { $0 as? any Equal } }
    static var illTyped: [any IllTyped] { ontology.compactMap { $0 as? any IllTyped } }

    /// The lexical mapping gives each literal its value, and the canonical
    /// mapping writes the value as its canonical representation, which maps
    /// to the same canonical representation again.
    @Test func lexicalFormsMapToTheCanonicalFormsOfTheirValues() throws {
        #expect(Self.mappings.count == 59)
        for mapping in Self.mappings {
            let lexical = try #require(mapping.lexical.first?.literalValue)
            let canonical = try #require(mapping.canonical.first?.literalValue)
            let datatype = try #require(xsdDatatype(of: lexical), "\(lexical)")
            #expect(try canonicalForm(datatype, lexical) == canonical.lexicalForm, "\(lexical)")
            #expect(try canonicalForm(datatype, canonical) == canonical.lexicalForm, "\(canonical)")
        }
    }

    /// Every datatype RDF 1.2 Concepts §5.1 lists has a mapping in the
    /// fixture.
    @Test func everyDatatypeIsExercised() throws {
        let exercised = Set(Self.mappings.compactMap { $0.lexical.first?.literalValue.flatMap(xsdDatatype(of:))?.datatype.name })
        #expect(exercised == Set(XSD.datatypes.map { $0.datatype.name }))
    }

    /// Two lexical forms of one value give equal values: a value is the
    /// datatype's value, not its lexical form (the time line for dateTime,
    /// months and seconds for duration, the number for decimal).
    @Test func lexicalFormsOfOneValueGiveEqualValues() throws {
        #expect(Self.equalities.count == 6)
        for equality in Self.equalities {
            let left = try #require(equality.left.first?.literalValue)
            let right = try #require(equality.right.first?.literalValue)
            let datatype = try #require(xsdDatatype(of: left))
            #expect(try denoteEqualValues(datatype, left, right), "\(left) and \(right)")
        }
    }

    /// An ill-typed literal has no value: its lexical form is not in the
    /// lexical space, by the primitive's lexical representation or by a
    /// facet of the datatype's definition (RDF 1.2 Concepts §3.4).
    @Test func illTypedLiteralsHaveNoValue() throws {
        #expect(Self.illTyped.count == 43)
        for illTyped in Self.illTyped {
            let literal = try #require(illTyped.literal.first?.literalValue)
            let datatype = try #require(xsdDatatype(of: literal))
            #expect(throws: DatatypeError.illTyped, "\(literal)") { try value(datatype, literal) }
        }
    }

    /// A literal of another datatype is not a value of this one, even when
    /// its value would be: `"127"^^xsd:byte` is not an `xsd:integer`
    /// literal.
    @Test func literalsOfAnotherDatatypeAreNotValues() throws {
        let byte = try #require(`byte-largest`.lexical.first?.literalValue)
        #expect(throws: DatatypeError.otherDatatype) { try XSD.integer(byte) }
        // The value is an integer: a byte's value converts to its base.
        let value = try XSD.byte(byte)
        #expect(try XSD.integer(value.value).lexicalForm == "127")
    }

    /// The values are the value spaces of XML Schema 1.1 Part 2: numbers,
    /// the seven-property model, months and seconds, octets.
    @Test func valuesAreInTheirValueSpaces() throws {
        let endOfDay = try XSD.dateTime(try #require(`dateTime-end-of-day`.lexical.first?.literalValue))
        #expect(endOfDay.value.day == 31)
        #expect(endOfDay.value.hour == 0)
        #expect(endOfDay.value.timezoneOffset == -300)
        let duration = try XSD.duration(try #require(`duration-hours`.lexical.first?.literalValue))
        #expect(duration.value.months.isZero)
        #expect(duration.value.seconds == DecimalNumber(129_600))
        let largest = try XSD.unsignedLong(try #require(`unsignedLong-largest`.lexical.first?.literalValue))
        #expect(largest.value.int == nil)  // beyond Int: integers are unbounded
        let octets = try XSD.hexBinary(try #require(`hexBinary-lower-case`.lexical.first?.literalValue))
        #expect(octets.value == [0x0F, 0xB7])
        let notANumber = try XSD.double(try #require(`double-not-a-number`.lexical.first?.literalValue))
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
