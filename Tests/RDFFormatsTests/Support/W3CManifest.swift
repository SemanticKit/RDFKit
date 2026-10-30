import Foundation
import IRIKit
import RDF
import RDFCore
import RDFFormats
import RDFKit

enum W3CManifestError: Error, CustomStringConvertible {
    case missingSuite
    case notInSuite(IRI)
    case malformed(IRI, String)
    case missingResult(IRI)

    var description: String {
        switch self {
        case .missingSuite: "the W3C suites are missing; run Scripts/fetch-w3c-rdf-tests.sh"
        case .notInSuite(let iri): "<\(iri)> is outside the fetched W3C suites"
        case .malformed(let iri, let reason): "manifest <\(iri)>: \(reason)"
        case .missingResult(let iri): "test <\(iri)> has no mf:result"
        }
    }
}

/// The W3C RDF test suites fetched by `Scripts/fetch-w3c-rdf-tests.sh`,
/// read through their manifests.
///
/// Manifests are Turtle, so they are read with ``TurtleDecoder``. Each
/// manifest's base IRI is its `https://w3c.github.io/rdf-tests/` address,
/// the address every manifest assumes; a document IRI maps back to the
/// fetched copy below `W3C/rdf-tests`.
struct W3CManifest {
    let root: URL
    let publishedRoot = "https://w3c.github.io/rdf-tests/"

    init() throws {
        guard let root = Bundle.module.url(forResource: "rdf-tests", withExtension: nil) else {
            throw W3CManifestError.missingSuite
        }
        self.root = root
    }

    /// Every test the manifest at `path` lists, following `mf:include`.
    static func tests(in path: String) throws -> [W3CTestCase] {
        let manifest = try W3CManifest()
        guard let iri = IRI(rawValue: manifest.publishedRoot + path) else {
            throw W3CManifestError.missingSuite
        }
        return try manifest.tests(inManifest: iri)
    }

    func file(for iri: IRI) throws -> URL {
        guard iri.rawValue.hasPrefix(publishedRoot) else { throw W3CManifestError.notInSuite(iri) }
        return root.appending(path: String(iri.rawValue.dropFirst(publishedRoot.count)))
    }

    func tests(inManifest iri: IRI) throws -> [W3CTestCase] {
        let text = try String(contentsOf: try file(for: iri), encoding: .utf8)
        let graph = try TurtleDecoder(base: iri).decode(text)
        guard let manifest = graph.subjects(
            IRI(of: RDF.type)!,
            IRI(of: TestManifest.ManifestIndividual.self)!
        ).first else {
            throw W3CManifestError.malformed(iri, "no mf:Manifest")
        }
        var tests: [W3CTestCase] = []
        for include in try graph.list(graph.object(manifest, IRI(TestManifest.include.key)!)) {
            guard case .iri(let included) = include else {
                throw W3CManifestError.malformed(iri, "mf:include names a non-IRI")
            }
            tests += try self.tests(inManifest: included)
        }
        for entry in try graph.list(graph.object(manifest, IRI(TestManifest.entries.key)!)) {
            guard let subject = entry.subject else {
                throw W3CManifestError.malformed(iri, "an entry is not a node")
            }
            tests.append(try test(subject, in: graph, manifest: iri))
        }
        return tests
    }

    func test(_ entry: SubjectTerm, in graph: Graph, manifest: IRI) throws -> W3CTestCase {
        guard case .iri(let id) = entry else { throw W3CManifestError.malformed(manifest, "a test without an IRI") }
        guard case .iri(let type)? = graph.object(entry, IRI(of: RDF.type)!),
              let kind = Self.kind(of: type) else {
            throw W3CManifestError.malformed(manifest, "<\(id)> has no known test type")
        }
        guard case .literal(let name)? = graph.object(entry, IRI(TestManifest.name.key)!),
              case .iri(let action)? = graph.object(entry, IRI(TestManifest.action.key)!) else {
            throw W3CManifestError.malformed(manifest, "<\(id)> needs mf:name and mf:action")
        }
        var resultFile: URL?
        if case .iri(let result)? = graph.object(entry, IRI(TestManifest.result.key)!) {
            resultFile = try file(for: result)
        }
        return W3CTestCase(
            id: id,
            name: name.lexicalForm,
            kind: kind,
            action: action,
            actionFile: try file(for: action),
            resultFile: resultFile
        )
    }

    static func kind(of type: IRI) -> W3CTestCase.Kind? {
        switch Optional(type) {
        case IRI(of: RDFTest.TestNTriplesPositiveSyntaxIndividual.self)!,
             IRI(of: RDFTest.TestTurtlePositiveSyntaxIndividual.self)!:
            .positiveSyntax
        case IRI(of: RDFTest.TestNTriplesNegativeSyntaxIndividual.self)!,
             IRI(of: RDFTest.TestTurtleNegativeSyntaxIndividual.self)!,
             IRI(of: RDFTest.TestXMLNegativeSyntaxIndividual.self)!:
            .negativeSyntax
        case IRI(of: RDFTest.TestTurtleEvalIndividual.self)!,
             IRI(of: RDFTest.TestXMLEvalIndividual.self)!:
            .evaluation
        case IRI(of: RDFTest.TestNTriplesPositiveC14NIndividual.self)!:
            .canonicalization
        default:
            nil
        }
    }
}

/// A decoded manifest, read by pattern.
extension Graph {
    func subjects(_ predicate: IRI, _ object: IRI) -> [SubjectTerm] {
        triples(predicate: predicate, object: .iri(object)).map(\.subject)
    }

    func object(_ subject: SubjectTerm, _ predicate: IRI) -> ObjectTerm? {
        triples(subject: subject, predicate: predicate).first?.object
    }

    /// The members of an `rdf:first` / `rdf:rest` list; none when absent.
    func list(_ head: ObjectTerm?) throws -> [ObjectTerm] {
        var members: [ObjectTerm] = []
        var node = head
        while let current = node, current != .iri(IRI(of: RDF.nil)!) {
            guard let cell = current.subject,
                  let first = object(cell, IRI(of: RDF.first)!) else {
                throw W3CManifestError.malformed(IRI(of: RDF.nil)!, "a broken list")
            }
            members.append(first)
            node = object(cell, IRI(of: RDF.rest)!)
        }
        return members
    }
}
