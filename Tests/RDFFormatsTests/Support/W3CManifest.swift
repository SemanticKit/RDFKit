import Foundation
import IRIKit
import RDF
import RDFCore
import RDFFormats
import RDFTest
import TestManifest

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

    /// The tests of one manifest, decoded from the manifest's Turtle into the
    /// Swift types of the published test vocabularies, `TestManifest`
    /// (test-manifest.ttl) and `RDFTest` (rdftest.ttl), and classified by
    /// those types.
    func tests(inManifest iri: IRI) throws -> [W3CTestCase] {
        let text = try String(contentsOf: try file(for: iri), encoding: .utf8)
        let graph = try TurtleDecoder(base: iri).decode(text)
        let context = DocumentContext()
        let decoder = GraphDecoder(classes: Self.classes, individuals: [RDF.nil])
        guard let manifest = try decoder.decode((any TestManifest.Manifest).self, from: graph, context: context).first else {
            throw W3CManifestError.malformed(iri, "no mf:Manifest")
        }
        var tests: [W3CTestCase] = []
        for include in try manifest.include.flatMap(Self.members) {
            guard case .individual(let included) = include, let included = context.iri(of: included) else {
                throw W3CManifestError.malformed(iri, "mf:include names a non-IRI")
            }
            tests += try self.tests(inManifest: included)
        }
        var entries: [(entry: any RDFCore.Resource, id: IRI)] = []
        for member in try manifest.entries.flatMap(Self.members) {
            guard case .individual(let entry) = member, let id = context.iri(of: entry) else {
                throw W3CManifestError.malformed(iri, "a test without an IRI")
            }
            entries.append((entry, id))
        }
        // Every member of mf:entries is an mf:ManifestEntry ("One entry in
        // rdf:type list of entries"), which has the entry's name, action and
        // result.
        let described = DocumentContext()
        let descriptions = try GraphDecoder(classes: []).decode(
            TestManifest.ManifestEntryIndividual.self, for: entries.map(\.id), from: graph, context: described
        )
        for ((entry, id), description) in zip(entries, descriptions) {
            tests.append(try test(entry, id: id, description, context: described, manifest: iri))
        }
        return tests
    }

    func test(
        _ entry: any RDFCore.Resource,
        id: IRI,
        _ description: TestManifest.ManifestEntryIndividual,
        context: DocumentContext,
        manifest: IRI
    ) throws -> W3CTestCase {
        guard let name = description.name.first,
              case .individual(let action)? = description.action.first,
              let actionIRI = context.iri(of: action) else {
            throw W3CManifestError.malformed(manifest, "<\(id)> needs mf:name and mf:action")
        }
        var resultFile: URL?
        if case .individual(let result)? = description.result.first, let resultIRI = context.iri(of: result) {
            resultFile = try file(for: resultIRI)
        }
        guard let kind = Self.kind(of: entry, hasResult: resultFile != nil) else {
            throw W3CManifestError.malformed(manifest, "<\(id)> has no known test type")
        }
        return W3CTestCase(
            id: id,
            name: name.lexicalForm,
            kind: kind,
            action: actionIRI,
            actionFile: try file(for: actionIRI),
            resultFile: resultFile
        )
    }

    /// The classes of the published test vocabularies a manifest's
    /// individuals are decoded as.
    static let classes: [any DecodableResource.Type] = [
        TestManifest.ManifestIndividual.self,
        RDFTest.TestNTriplesPositiveSyntaxIndividual.self,
        RDFTest.TestNTriplesNegativeSyntaxIndividual.self,
        RDFTest.TestNTriplesPositiveC14NIndividual.self,
        RDFTest.TestTurtlePositiveSyntaxIndividual.self,
        RDFTest.TestTurtleNegativeSyntaxIndividual.self,
        RDFTest.TestTurtleEvalIndividual.self,
        RDFTest.XMLEvalIndividual.self,
        RDFTest.TestXMLNegativeSyntaxIndividual.self,
    ]

    /// The kind of test an entry is, by the Swift type of its class.
    ///
    /// The RDF/XML manifests state their evaluation tests are members of
    /// `rdft:TestXMLEval`, a class the published test vocabulary does not
    /// declare (it declares `rdft:XMLEval`, "A positive RDF/XML evaluation
    /// test"), so those entries decode with no class of it. Of the RDF/XML
    /// entries, only evaluation tests name an expected outcome (`mf:result`).
    static func kind(of entry: any RDFCore.Resource, hasResult: Bool) -> W3CTestCase.Kind? {
        switch entry {
        case is any RDFTest.TestNTriplesPositiveSyntax, is any RDFTest.TestTurtlePositiveSyntax:
            .positiveSyntax
        case is any RDFTest.TestNTriplesNegativeSyntax, is any RDFTest.TestTurtleNegativeSyntax, is any RDFTest.TestXMLNegativeSyntax:
            .negativeSyntax
        case is any RDFTest.TestTurtleEval, is any RDFTest.XMLEval:
            .evaluation
        case is any RDFTest.TestNTriplesPositiveC14N:
            .canonicalization
        case is any RDFTest.Test:
            nil
        default:
            hasResult ? .evaluation : nil
        }
    }

    /// The members of an `rdf:List`, in order, up to `rdf:nil`.
    static func members(of list: any RDF.List) throws -> [RDFCore.Value] {
        var members: [RDFCore.Value] = []
        var cell = list
        while cell !== RDF.nil {
            guard let first = cell.first.first, let rest = cell.rest.first else {
                throw W3CManifestError.malformed(IRI(of: RDF.nil)!, "a broken list")
            }
            members.append(first)
            cell = rest
        }
        return members
    }
}
