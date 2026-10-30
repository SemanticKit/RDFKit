import Testing
import Foundation
import IRIKit
import RDFCore
import RDFFormats
import Samples
import XSD

/// A property whose range is an XSD datatype holds values of the
/// datatype's Swift value type (``RDFCore/DatatypeValue``), and the format
/// encoders write each as the literal of its canonical form and its
/// datatype IRI. `Samples` (samples.ttl) gives a property for each datatype;
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

    /// Literals the value types do not hold, ill-typed, not canonical, of
    /// another datatype or of a datatype with no Swift type, stay literals
    /// at the boundary: the properties hold only the values, and the
    /// individual writes every literal back as the document states it.
    @Test func otherLiteralsSurviveAndRoundTrip() throws {
        #expect(unusual.nonNegativeInteger.map(\.lexicalForm) == ["5"])
        #expect(unusual.boolean.isEmpty)
        #expect(unusual.string.isEmpty)
        let output = try GraphEncoder().encode(unusual)
        #expect(output == (try Self.description(of: unusual)), "\(output)")
    }

    /// The whole document translates back to the same graph (RDF 1.2
    /// Concepts §3.7).
    @Test func documentTranslatesBackToTheSameGraph() throws {
        let output = try NTriplesDecoder().decode(try NTriplesEncoder().encode(ontology))
        #expect(output.isIsomorphic(to: try Self.document()))
    }
}
