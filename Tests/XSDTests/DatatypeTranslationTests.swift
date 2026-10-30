import Testing
import Foundation
import XSD

/// The datatypes and their hierarchy come from translating the W3C
/// documents in `Sources/XSD/W3C`, not from Swift written by hand. These
/// tests read the documents themselves and compare.
@Suite("XSD datatypes translated from the W3C documents", .tags(.datatype, .generated))
struct DatatypeTranslationTests {
    static let documents = URL(filePath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        .appending(path: "Sources/XSD/W3C")

    /// The translated set is the list of RDF 1.2 Concepts §5.1, "the
    /// RDF-compatible XSD types", and each datatype's IRI is the `xsd`
    /// namespace of §1.4 followed by its name.
    @Test func translatedSetIsTheRDFCompatibleXSDTypes() throws {
        let html = try String(contentsOf: Self.documents.appending(path: "rdf12-concepts.html"), encoding: .utf8)
        let table = try #require(html.range(of: "id=\"tab-xsd-datatypes\"").flatMap { start in
            html.range(of: "</table>", range: start.upperBound..<html.endIndex).map { html[start.upperBound..<$0.lowerBound] }
        })
        let listed = table.components(separatedBy: "<code>xsd:").dropFirst().map { String($0.prefix { $0 != "<" }) }
        #expect(listed.count == 39)
        #expect(XSD.datatypes.map { $0.datatype.name } == listed)
        let namespace = try #require(html.range(of: "<td>xsd</td>").flatMap { cell in
            html.range(of: "<code>", range: cell.upperBound..<html.endIndex).map { code in
                String(html[code.upperBound...].prefix { $0 != "<" })
            }
        })
        for datatype in XSD.datatypes {
            #expect(datatype.datatype.stringValue == namespace + datatype.datatype.name)
        }
    }

    /// Each datatype's base is the base of its definition in the schema
    /// documents of XML Schema 1.1 Part 2 Appendix C, and a primitive's base
    /// is `anyAtomicType`, which has no Swift type. The documents are read
    /// here as text: each top-level `<xs:simpleType name="...">` and the
    /// `base` of the first `<xs:restriction>` in it.
    @Test func hierarchyIsTheSchemaDocuments() throws {
        var bases: [String: String] = [:]
        for document in ["primitives.nxsd", "derived.nxsd"] {
            let text = try String(contentsOf: Self.documents.appending(path: document), encoding: .utf8)
            for definition in text.components(separatedBy: "<xs:simpleType name=\"").dropFirst() {
                let name = String(definition.prefix { $0 != "\"" })
                let body = definition.components(separatedBy: "</xs:simpleType>")[0]
                guard let restriction = body.range(of: "<xs:restriction base=\"xs:") else { continue }
                bases[name] = String(body[restriction.upperBound...].prefix { $0 != "\"" })
            }
        }
        for datatype in XSD.datatypes {
            let name = datatype.datatype.name
            let base = try #require(bases[name], "\(name)")
            let translated = datatype.base.map { $0.datatype.name } ?? "anyAtomicType"
            #expect(translated == base, "\(name)")
        }
        let byteBase = XSD.byte.base.map(ObjectIdentifier.init)
        #expect(byteBase == ObjectIdentifier(XSD.short.self))
    }
}
