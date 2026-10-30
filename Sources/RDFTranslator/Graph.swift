import Foundation
import IRIKit
import RDFCore
import RDFFormats

/// A node of the merged graph the translator reads: an IRI, or a blank node
/// scoped to the document it occurs in (RDF 1.2 Concepts §3.5: "Blank node
/// identifiers are local identifiers").
enum NodeID: Hashable {
    case iri(String)
    case blank(document: Int, label: String)

    var iri: String? {
        if case .iri(let iri) = self { return iri }
        return nil
    }
}

/// The object of a statement: a node or a literal.
enum ObjectValue: Hashable {
    case node(NodeID)
    case literal(Literal)

    var node: NodeID? {
        if case .node(let node) = self { return node }
        return nil
    }
}

/// One triple of a document, with its blank nodes scoped to the document.
struct Statement: Hashable {
    let subject: NodeID
    let predicate: String
    let object: ObjectValue
}

/// The documents of one Swift module: a layer of the translation.
struct Layer {
    /// The Swift module the documents translate to.
    let module: String

    /// The document file names, for the generated file's header.
    let documents: [String]

    /// The triples of every document, in document order.
    let statements: [Statement]
}

/// The error the translator reports to the build.
struct TranslationError: Error, CustomStringConvertible {
    let description: String
}

extension Layer {
    /// Reads the documents of a module with the decoder for each document's
    /// syntax.
    static func read(module: String, paths: [String], firstDocument: Int) throws -> Layer {
        var statements: [Statement] = []
        for (offset, path) in paths.enumerated() {
            let url = URL(filePath: path)
            let text = try String(contentsOf: url, encoding: .utf8)
            let triples: Graph
            switch url.pathExtension.lowercased() {
            case "ttl":
                triples = try TurtleDecoder().decode(text)
            case "nt":
                triples = try NTriplesDecoder().decode(text)
            default:
                throw TranslationError(description: "\(path): no decoder reads .\(url.pathExtension) documents")
            }
            let document = firstDocument + offset
            for triple in triples {
                statements.append(Statement(
                    subject: node(triple.subject, document),
                    predicate: triple.predicate.rawValue,
                    object: try object(triple.object, document, path)
                ))
            }
        }
        return Layer(module: module, documents: paths.map { URL(filePath: $0).lastPathComponent }, statements: statements)
    }

    private static func node(_ subject: SubjectTerm, _ document: Int) -> NodeID {
        switch subject {
        case .iri(let iri): .iri(iri.rawValue)
        case .blankNode(let node): .blank(document: document, label: node.identifier)
        }
    }

    private static func object(_ object: ObjectTerm, _ document: Int, _ path: String) throws -> ObjectValue {
        switch object {
        case .iri(let iri): .node(.iri(iri.rawValue))
        case .blankNode(let node): .node(.blank(document: document, label: node.identifier))
        case .literal(let literal): .literal(literal)
        case .tripleTerm:
            throw TranslationError(description: "\(path): a triple term has no Swift translation yet")
        }
    }
}
