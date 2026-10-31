import Foundation
import IRIKit
import RDFCore
import RDFFormats

/// Translates the terms of a vocabulary's published RDF into Swift, through
/// the generators `@Ontology` uses. `RDFTranslatorPlugin` runs it on every
/// build of a target that has a `units.txt`.
///
///     RDFTranslator <output.swift> <units.txt> <module> <document>...
///
/// `units.txt` holds the vocabulary's namespace on its first line, then the
/// IRIs of the terms translated so far, one per line. The documents are
/// RDF/XML (`.rdf`) or Turtle (`.ttl`).
do {
    var arguments = CommandLine.arguments.dropFirst()
    guard let output = arguments.popFirst(), let units = arguments.popFirst(), let module = arguments.popFirst() else {
        throw TranslationError(description: "usage: RDFTranslator <output.swift> <units.txt> <module> <document>...")
    }
    var graph = Graph()
    for path in arguments {
        let document = try String(contentsOf: URL(filePath: path), encoding: .utf8)
        switch URL(filePath: path).pathExtension.lowercased() {
        case "rdf": graph.formUnion(try RDFXMLDecoder().decode(document))
        case "ttl": graph.formUnion(try TurtleDecoder().decode(document))
        default: throw TranslationError(description: "\(path) is neither RDF/XML (.rdf) nor Turtle (.ttl)")
        }
    }
    let lines = try String(contentsOf: URL(filePath: units), encoding: .utf8)
        .split(whereSeparator: \.isNewline)
        .map { $0.trimmingCharacters(in: .whitespaces) }
        .filter { !$0.isEmpty && !$0.hasPrefix("#") }
    guard let namespace = lines.first else {
        throw TranslationError(description: "\(units) names no namespace")
    }
    let vocabulary = Vocabulary(graph: graph, module: module, namespace: namespace, terms: Array(lines.dropFirst()))
    try vocabulary.source().write(to: URL(filePath: output), atomically: true, encoding: .utf8)
} catch {
    FileHandle.standardError.write(Data("error: \(error)\n".utf8))
    exit(1)
}

/// The error the translator reports to the build.
struct TranslationError: Error, CustomStringConvertible {
    let description: String
}
