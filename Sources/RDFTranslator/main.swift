import Foundation
import IRIKit
import OntologyGeneration
import RDFCore
import RDFFormats

/// Translates RDF documents into the Swift they describe, through the
/// generators `@Ontology` uses. `RDFTranslatorPlugin` runs it on every
/// build of a target that has RDF documents.
///
///     RDFTranslator <output.swift> <module> <namespace|-> <document>... [--layer <module> <namespace|-> <document>...]...
///
/// The documents are RDF/XML (`.rdf`) or Turtle (`.ttl`). Every subject
/// they state something about that no layer owns is translated. The
/// namespace nests the declarations in a Swift namespace when a module
/// holds more than one vocabulary; `-` puts them in the module itself. Each
/// `--layer` is a vocabulary this one builds on: another of its target, or
/// one of a target it depends on.
do {
    var groups: [[String]] = [[]]
    for argument in CommandLine.arguments.dropFirst() {
        if argument == "--layer" { groups.append([]) } else { groups[groups.count - 1].append(argument) }
    }
    var target = groups.removeFirst()
    guard target.count >= 3 else {
        throw TranslationError(description: "usage: RDFTranslator <output.swift> <module> <namespace|-> <document>... [--layer <module> <namespace|-> <document>...]...")
    }
    let output = target.removeFirst()
    let vocabularies = try ([target] + groups).map { group in
        guard group.count >= 2 else { throw TranslationError(description: "a vocabulary takes <module> <namespace|-> <document>...") }
        return try Vocabulary.read(module: group[0], namespace: group[1] == "-" ? nil : group[1], documents: Array(group.dropFirst(2)))
    }
    try Catalog(vocabularies).vocabularies[0].source().write(to: URL(filePath: output), atomically: true, encoding: .utf8)
} catch {
    FileHandle.standardError.write(Data("error: \(error)\n".utf8))
    exit(1)
}

extension Vocabulary {
    /// A vocabulary as its documents give it.
    static func read(module: String, namespace: String?, documents: [String]) throws -> Vocabulary {
        var graph = Graph()
        for path in documents {
            let document = try String(contentsOf: URL(filePath: path), encoding: .utf8)
            switch URL(filePath: path).pathExtension.lowercased() {
            case "rdf": graph.formUnion(try RDFXMLDecoder().decode(document))
            case "ttl": graph.formUnion(try TurtleDecoder().decode(document))
            default: throw TranslationError(description: "\(path) is neither RDF/XML (.rdf) nor Turtle (.ttl)")
            }
        }
        return Vocabulary(graph: graph, module: module, namespace: namespace)
    }
}

/// The vocabularies of one translation, the first the one translated: which
/// of them owns each subject, the Swift name of each term, and the schema
/// all their statements entail.
///
/// A subject is owned by the vocabulary most of whose subjects are in its
/// namespace, and otherwise by the first that states something about it,
/// the layers before the vocabulary translated: FOAF's `rdfs:Class` is
/// RDFS's, and its `geo:SpatialThing` FOAF's.
struct Catalog {
    let vocabularies: [Vocabulary]

    init(_ vocabularies: [Vocabulary]) {
        var vocabularies = vocabularies
        let order = Array(vocabularies.indices.dropFirst()) + [0]
        let dominant = vocabularies.map(\.dominantNamespace)
        var owner: [String: Int] = [:]
        for index in order {
            for subject in vocabularies[index].subjects where owner[subject] == nil || Vocabulary.namespace(of: subject) == dominant[index] {
                if let current = owner[subject], Vocabulary.namespace(of: subject) == dominant[current] { continue }
                owner[subject] = index
            }
        }
        for index in vocabularies.indices {
            let owned = vocabularies[index].subjects.filter { owner[$0] == index }
            vocabularies[index].own(owned)
        }
        var names: [String: String] = [:]
        for vocabulary in vocabularies {
            for term in vocabulary.terms where names[term] == nil {
                names[term] = "\(vocabulary.swiftNamespace).\(vocabulary.localName(term))"
            }
        }
        let schema = Schema(vocabularies.map(\.graph))
        for index in vocabularies.indices {
            vocabularies[index].names = names
            vocabularies[index].schema = schema
        }
        for index in vocabularies.indices {
            vocabularies[index].dependencies = vocabularies.indices.filter { $0 != index }.map { vocabularies[$0] }
        }
        self.vocabularies = vocabularies
    }
}

/// The error the translator reports to the build.
struct TranslationError: Error, CustomStringConvertible {
    let description: String
}
