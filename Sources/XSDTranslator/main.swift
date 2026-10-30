import Foundation
import XSDDefinitions

/// Translates the XML Schema datatypes RDF uses into Swift value types. The
/// `XSDTranslatorPlugin` runs it on every build of the `XSD` target.
///
///     XSDTranslator <output.swift> <document>...
///
/// The documents are the W3C's own (``XSDDefinitions/DatatypeDefinitions``):
/// the schema for schema documents of XML Schema 1.1 Part 2 (`.xsd`), the XML
/// representations of the built-in datatype definitions (`.nxsd`), and RDF
/// 1.2 Concepts (`.html`), whose §5.1 lists the datatypes RDF uses.
do {
    var arguments = CommandLine.arguments.dropFirst()
    guard let output = arguments.popFirst() else {
        throw TranslationError(description: "usage: XSDTranslator <output.swift> <document>...")
    }
    let source = try DatatypeSource(definitions: try DatatypeDefinitions(documents: Array(arguments))).render()
    try source.write(to: URL(filePath: output), atomically: true, encoding: .utf8)
} catch {
    FileHandle.standardError.write(Data("error: \(error)\n".utf8))
    exit(1)
}

/// The error the translator reports to the build.
struct TranslationError: Error, CustomStringConvertible {
    let description: String
}
