import Foundation
import IRIKit
import RDFCore
import RDFFormats

/// The documents of one Swift module: a layer of the translation.
///
/// Its graph is the merge of its documents' graphs (RDF 1.2 Semantics §4,
/// "the merge of a set of RDF graphs"): blank nodes are local to the
/// document they occur in (RDF 1.2 Concepts §3.5, "Blank node identifiers
/// are local identifiers"), so each is kept apart by the document it comes
/// from before the graphs are merged.
struct Layer {
    /// The Swift module the documents translate to.
    let module: String

    /// The document file names, for the generated file's header.
    let documents: [String]

    /// The merged graph of every document, in document order.
    let graph: Graph

    /// Reads the documents of a module with the decoder for each document's
    /// syntax. `firstDocument` is the number of documents the layers below
    /// have, so that no two documents' blank nodes meet.
    init(module: String, paths: [String], firstDocument: Int) throws {
        var graph = Graph()
        for (offset, path) in paths.enumerated() {
            let url = URL(filePath: path)
            let text = try String(contentsOf: url, encoding: .utf8)
            let decoded: Graph
            switch url.pathExtension.lowercased() {
            case "ttl": decoded = try TurtleDecoder().decode(text)
            case "nt": decoded = try NTriplesDecoder().decode(text)
            case "rdf": decoded = try RDFXMLDecoder().decode(text)
            default: throw TranslationError(description: "\(path): no decoder reads .\(url.pathExtension) documents")
            }
            let document = firstDocument + offset
            for triple in decoded {
                guard let object = triple.object.scoped(to: document) else {
                    throw TranslationError(description: "\(path): a triple term has no Swift translation yet")
                }
                graph.insert(Graph.Element(subject: triple.subject.scoped(to: document), predicate: triple.predicate, object: object))
            }
        }
        self.module = module
        self.documents = paths.map { URL(filePath: $0).lastPathComponent }
        self.graph = graph
    }
}

/// The error the translator reports to the build.
struct TranslationError: Error, CustomStringConvertible {
    let description: String
}

extension BlankNode {
    /// The same blank node, kept apart from the blank nodes of every other
    /// document.
    func scoped(to document: Int) -> BlankNode {
        try! BlankNode("\(document).\(identifier)")  // never empty
    }
}

extension SubjectTerm {
    /// The node, with a blank node kept apart from other documents'.
    func scoped(to document: Int) -> SubjectTerm {
        switch self {
        case .iri: self
        case .blankNode(let node): .blankNode(node.scoped(to: document))
        }
    }

    /// The IRI of the node, or `nil` for a blank node.
    var iri: IRI? {
        if case .iri(let iri) = self { return iri }
        return nil
    }

    /// The order the translator writes nodes in: by IRI, blank nodes last.
    static func inIRIOrder(_ lhs: SubjectTerm, _ rhs: SubjectTerm) -> Bool {
        (lhs.iri?.rawValue ?? "\u{10FFFF}") < (rhs.iri?.rawValue ?? "\u{10FFFF}")
    }
}

extension ObjectTerm {
    /// The object, with a blank node kept apart from other documents'; `nil`
    /// for a triple term.
    func scoped(to document: Int) -> ObjectTerm? {
        switch self {
        case .iri, .literal: self
        case .blankNode(let node): .blankNode(node.scoped(to: document))
        case .tripleTerm: nil
        }
    }

    /// The object as a node, when it is an IRI or a blank node.
    var node: SubjectTerm? { subject }
}
