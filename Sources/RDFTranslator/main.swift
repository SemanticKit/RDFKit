import Foundation
import IRIKit
import RDFCore
import RDFFormats

/// Translates the terms of a vocabulary's published RDF into Swift, through
/// the generators `@Ontology` uses. `RDFTranslatorPlugin` runs it on every
/// build of a target that has a `units.txt`.
///
///     RDFTranslator <output.swift> <units.txt> <module> <document>... [--layer <module> <units.txt> <document>...]...
///
/// `units.txt` holds the vocabulary's namespace on its first line, then the
/// IRIs of the terms translated so far, one per line. The documents are
/// RDF/XML (`.rdf`) or Turtle (`.ttl`). Each `--layer` is a vocabulary of a
/// target this one depends on, whose terms it names by their Swift types.
do {
    var groups: [[String]] = [[]]
    for argument in CommandLine.arguments.dropFirst() {
        if argument == "--layer" { groups.append([]) } else { groups[groups.count - 1].append(argument) }
    }
    var target = groups.removeFirst()
    guard target.count >= 3 else {
        throw TranslationError(description: "usage: RDFTranslator <output.swift> <units.txt> <module> <document>... [--layer <module> <units.txt> <document>...]...")
    }
    let output = target.removeFirst()
    let units = target.removeFirst()
    let module = target.removeFirst()
    var vocabulary = try Vocabulary.read(module: module, units: units, documents: target)
    vocabulary.dependencies = try groups.map { group in
        guard group.count >= 2 else { throw TranslationError(description: "--layer takes <module> <units.txt> <document>...") }
        return try Vocabulary.read(module: group[0], units: group[1], documents: Array(group.dropFirst(2)))
    }
    try vocabulary.source().write(to: URL(filePath: output), atomically: true, encoding: .utf8)
} catch {
    FileHandle.standardError.write(Data("error: \(error)\n".utf8))
    exit(1)
}

extension Vocabulary {
    /// A vocabulary as its units and documents give it.
    static func read(module: String, units: String, documents: [String]) throws -> Vocabulary {
        var graph = Graph()
        for path in documents {
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
        return Vocabulary(graph: graph, module: module, namespace: namespace, terms: Array(lines.dropFirst()))
    }
}

/// The error the translator reports to the build.
struct TranslationError: Error, CustomStringConvertible {
    let description: String
}
