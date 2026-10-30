import Foundation

/// Translates the XML Schema datatypes RDF uses into Swift value types. The
/// `XSDTranslatorPlugin` runs it on every build of the `XSD` target.
///
///     XSDTranslator <output.swift> <document>...
///
/// The documents are the W3C's own:
///
/// - `.xsd`: the schema for schema documents of XML Schema 1.1 Part 2
///   (Appendix A, `datatypes.xsd`), which declares the facets.
/// - `.nxsd`: the XML representations of the built-in datatype definitions
///   (Appendix C.1 `primitives.nxsd` and C.2 `derived.nxsd`).
/// - `.html`: RDF 1.2 Concepts, whose §5.1 lists the datatypes RDF uses.
do {
    var arguments = CommandLine.arguments.dropFirst()
    guard let output = arguments.popFirst() else {
        throw TranslationError(description: "usage: XSDTranslator <output.swift> <document>...")
    }
    let paths = Array(arguments)
    let extensions = paths.map { URL(filePath: $0).pathExtension.lowercased() }
    guard let schemaPath = zip(paths, extensions).first(where: { $1 == "xsd" })?.0 else {
        throw TranslationError(description: "no schema for schema documents (.xsd)")
    }
    guard let conceptsPath = zip(paths, extensions).first(where: { $1 == "html" })?.0 else {
        throw TranslationError(description: "no RDF 1.2 Concepts document (.html)")
    }
    let vocabulary = try FacetVocabulary(schema: try SchemaElement(document: schemaPath))
    var definitions: [String: SimpleTypeDefinition] = [:]
    for (path, pathExtension) in zip(paths, extensions) where pathExtension == "nxsd" {
        let schema = try SchemaElement(document: path)
        for element in schema.children("simpleType", in: vocabulary.namespace) {
            guard let definition = try SimpleTypeDefinition(element, vocabulary: vocabulary) else { continue }
            guard definitions[definition.name] == nil else {
                throw TranslationError(description: "\(path): xsd:\(definition.name) is defined twice")
            }
            definitions[definition.name] = definition
        }
    }
    let compatible = try CompatibleDatatypes(concepts: try String(contentsOf: URL(filePath: conceptsPath), encoding: .utf8))
    let source = try DatatypeSource(
        documents: paths.map { URL(filePath: $0).lastPathComponent },
        vocabulary: vocabulary,
        compatible: compatible,
        definitions: definitions
    ).render()
    try source.write(to: URL(filePath: output), atomically: true, encoding: .utf8)
} catch {
    FileHandle.standardError.write(Data("error: \(error)\n".utf8))
    exit(1)
}

/// The error the translator reports to the build.
struct TranslationError: Error, CustomStringConvertible {
    let description: String
}
