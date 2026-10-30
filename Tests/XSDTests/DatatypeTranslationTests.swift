import Testing
import Foundation
import RDFCore
import XSD
import XSDDefinitions

/// The datatypes and their hierarchy come from translating the W3C
/// documents in `Sources/XSD/W3C`, not from Swift written by hand.
///
/// The schema documents of XML Schema 1.1 Part 2 give the definitions and
/// their hierarchy (Appendix C, `primitives.nxsd` and `derived.nxsd`), and
/// RDF 1.2 Concepts §5.1 selects which of them RDF uses: Appendix C also
/// defines `ID`, `IDREF`, `ENTITY`, `QName` and `NOTATION`, which RDF 1.2
/// leaves out. These tests read the documents themselves, as text, and
/// compare them with the translation (``XSDDefinitions/DatatypeDefinitions``,
/// which both translators use) and with the Swift types the fixtures' values
/// have.
@Suite("XSD datatypes translated from the W3C documents", .tags(.datatype, .generated))
struct DatatypeTranslationTests {
    static let documents = URL(filePath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        .appending(path: "Sources/XSD/W3C")

    /// The translation of the stored documents, as the build makes it.
    static func translation() throws -> DatatypeDefinitions {
        let paths = try FileManager.default.contentsOfDirectory(atPath: documents.path)
            .filter { ["xsd", "nxsd", "html"].contains(URL(filePath: $0).pathExtension) }
            .sorted()
            .map { documents.appending(path: $0).path }
        return try DatatypeDefinitions(documents: paths)
    }

    /// The names RDF 1.2 Concepts §5.1 lists in `tab-xsd-datatypes`, read as
    /// text.
    static func listed() throws -> (names: [String], namespace: String) {
        let html = try String(contentsOf: documents.appending(path: "rdf12-concepts.html"), encoding: .utf8)
        let table = try #require(html.range(of: "id=\"tab-xsd-datatypes\"").flatMap { start in
            html.range(of: "</table>", range: start.upperBound..<html.endIndex).map { html[start.upperBound..<$0.lowerBound] }
        })
        let names = table.components(separatedBy: "<code>xsd:").dropFirst().map { String($0.prefix { $0 != "<" }) }
        let namespace = try #require(html.range(of: "<td>xsd</td>").flatMap { cell in
            html.range(of: "<code>", range: cell.upperBound..<html.endIndex).map { code in
                String(html[code.upperBound...].prefix { $0 != "<" })
            }
        })
        return (names, namespace)
    }

    /// The base of each top-level `<xs:simpleType name="...">` of the
    /// schema documents: the `base` of the first `<xs:restriction>` in it.
    static func definedBases() throws -> [String: String] {
        var bases: [String: String] = [:]
        for document in ["primitives.nxsd", "derived.nxsd"] {
            let text = try String(contentsOf: documents.appending(path: document), encoding: .utf8)
            for definition in text.components(separatedBy: "<xs:simpleType name=\"").dropFirst() {
                let name = String(definition.prefix { $0 != "\"" })
                let body = definition.components(separatedBy: "</xs:simpleType>")[0]
                guard let restriction = body.range(of: "<xs:restriction base=\"xs:") else { continue }
                bases[name] = String(body[restriction.upperBound...].prefix { $0 != "\"" })
            }
        }
        return bases
    }

    /// The translated set is the list of RDF 1.2 Concepts §5.1, "the
    /// RDF-compatible XSD types", each a definition of the schema documents,
    /// and the built-in datatypes RDF 1.2 leaves out are defined there but
    /// not translated.
    @Test func translatedSetIsTheRDFCompatibleXSDTypes() throws {
        let translation = try Self.translation()
        let listed = try Self.listed()
        let bases = try Self.definedBases()
        #expect(listed.names.count == 39)
        #expect(translation.datatypes.map(\.name) == listed.names)
        #expect(translation.namespace == listed.namespace)
        for name in listed.names {
            #expect(bases[name] != nil, "\(name) has a definition in the schema documents")
        }
        for name in ["ID", "IDREF", "ENTITY", "QName", "NOTATION"] {
            #expect(bases[name] != nil, "\(name) has a definition in the schema documents")
            #expect(translation.defined.contains { $0.name == name })
            #expect(translation.datatype(named: name) == nil, "\(name) is not translated")
        }
    }

    /// The Swift types are the translated set: each value the fixtures give
    /// the samples properties is of a Swift type whose declared key is a
    /// listed datatype, the §5.1 namespace followed by its name, and every
    /// listed datatype has one (``SimpleTypeTests/everyDatatypeIsExercised()``).
    @Test func swiftTypesAreTheTranslatedSet() throws {
        let listed = try Self.listed()
        let types = try SimpleTypeTests.mappings.flatMap { try EncodedValues(of: $0).datatypeValues.map { type(of: $0) } }
        #expect(Set(types.map { $0.datatype.name }) == Set(listed.names))
        for datatype in types {
            #expect(datatype.datatype.stringValue == listed.namespace + datatype.datatype.name)
        }
    }

    /// Each datatype's base is the base of its definition in the schema
    /// documents of XML Schema 1.1 Part 2 Appendix C, as the Swift type's
    /// `Base` gives it, and a primitive's base is `anyAtomicType`, which has
    /// no Swift type.
    @Test func hierarchyIsTheSchemaDocuments() throws {
        let bases = try Self.definedBases()
        let types = try SimpleTypeTests.mappings.flatMap { try EncodedValues(of: $0).datatypeValues.map { type(of: $0) } }
        #expect(!types.isEmpty)
        for datatype in types {
            let name = datatype.datatype.name
            let base = try #require(bases[name], "\(name)")
            #expect((baseName(of: datatype) ?? "anyAtomicType") == base, "\(name)")
        }
    }
}
