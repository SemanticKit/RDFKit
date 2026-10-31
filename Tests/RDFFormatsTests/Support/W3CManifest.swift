import Foundation
import IRIKit
import RDFCore
import RDFFormats

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
/// Manifests are Turtle, so they are read with ``TurtleDecoder``, and walked
/// by their triples: the manifest's `mf:include` and `mf:entries` lists, and
/// each entry's `rdf:type`, `mf:name`, `mf:action` and `mf:result`, as the
/// test manifest vocabulary (`Vocabularies/TestManifest/test-manifest.ttl`)
/// and the RDF test vocabulary (`Vocabularies/RDFTest/rdftest.ttl`) define
/// them. Each manifest's base IRI is its `https://w3c.github.io/rdf-tests/`
/// address, the address every manifest assumes; a document IRI maps back to
/// the fetched copy below `W3C/rdf-tests`.
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

    /// The tests of one manifest, in the order its lists give them.
    func tests(inManifest iri: IRI) throws -> [W3CTestCase] {
        let text = try String(contentsOf: try file(for: iri), encoding: .utf8)
        let statements = Statements(try TurtleDecoder(base: iri).decode(text))
        guard let manifest = statements.subjects.first(where: { statements.has($0, type: Vocabulary.mf("Manifest")) }) else {
            throw W3CManifestError.malformed(iri, "no mf:Manifest")
        }
        var tests: [W3CTestCase] = []
        for list in statements.objects(of: manifest, Vocabulary.mf("include")) {
            for include in try statements.members(of: list, in: iri) {
                guard case .iri(let included) = include else {
                    throw W3CManifestError.malformed(iri, "mf:include names a non-IRI")
                }
                tests += try self.tests(inManifest: included)
            }
        }
        for list in statements.objects(of: manifest, Vocabulary.mf("entries")) {
            for entry in try statements.members(of: list, in: iri) {
                guard case .iri(let id) = entry else {
                    throw W3CManifestError.malformed(iri, "a test without an IRI")
                }
                tests.append(try test(id, in: statements, manifest: iri))
            }
        }
        return tests
    }

    /// One `mf:ManifestEntry`: its name, action, result and test type.
    func test(_ id: IRI, in statements: Statements, manifest: IRI) throws -> W3CTestCase {
        let entry = SubjectTerm.iri(id)
        guard case .literal(let name)? = statements.objects(of: entry, Vocabulary.mf("name")).first,
              case .iri(let action)? = statements.objects(of: entry, Vocabulary.mf("action")).first else {
            throw W3CManifestError.malformed(manifest, "<\(id)> needs mf:name and mf:action")
        }
        var resultFile: URL?
        if case .iri(let result)? = statements.objects(of: entry, Vocabulary.mf("result")).first {
            resultFile = try file(for: result)
        }
        let types = statements.objects(of: entry, Vocabulary.rdf("type")).lazy.compactMap { object -> IRI? in
            if case .iri(let type) = object { return type }
            return nil
        }
        guard let kind = W3CTestCase.Kind(types: types, hasResult: resultFile != nil) else {
            throw W3CManifestError.malformed(manifest, "<\(id)> has no known test type")
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
}

/// The terms of the test vocabularies a manifest is read by, derived from
/// their namespaces when asked for.
enum Vocabulary {
    /// A term of the test manifest vocabulary, `mf:`.
    static func mf(_ name: String) -> IRI {
        IRI(rawValue: "http://www.w3.org/2001/sw/DataAccess/tests/test-manifest#" + name)!
    }

    /// A term of the RDF vocabulary, `rdf:`.
    static func rdf(_ name: String) -> IRI {
        IRI(rawValue: "http://www.w3.org/1999/02/22-rdf-syntax-ns#" + name)!
    }

    /// The namespace of the RDF test vocabulary, `rdft:`.
    static var rdftNamespace: String { "http://www.w3.org/ns/rdftest#" }
}

/// A manifest's triples, indexed once by subject and predicate.
struct Statements {
    /// The subjects, in the order the manifest first states them.
    let subjects: [SubjectTerm]
    private let objects: [SubjectTerm: [IRI: [ObjectTerm]]]

    init(_ graph: Graph) {
        var subjects: [SubjectTerm] = []
        var objects: [SubjectTerm: [IRI: [ObjectTerm]]] = [:]
        for triple in graph {
            if objects[triple.subject] == nil { subjects.append(triple.subject) }
            objects[triple.subject, default: [:]][triple.predicate, default: []].append(triple.object)
        }
        self.subjects = subjects
        self.objects = objects
    }

    /// The objects of a subject's triples of a predicate.
    func objects(of subject: SubjectTerm, _ predicate: IRI) -> [ObjectTerm] {
        objects[subject]?[predicate] ?? []
    }

    /// Whether a subject is stated to be an instance of a class.
    func has(_ subject: SubjectTerm, type: IRI) -> Bool {
        objects(of: subject, Vocabulary.rdf("type")).contains(.iri(type))
    }

    /// The members of an RDF list, in order, up to `rdf:nil`.
    func members(of list: ObjectTerm, in manifest: IRI) throws -> [ObjectTerm] {
        var members: [ObjectTerm] = []
        var cell = list
        while cell != .iri(Vocabulary.rdf("nil")) {
            let subject: SubjectTerm
            switch cell {
            case .iri(let iri): subject = .iri(iri)
            case .blankNode(let node): subject = .blankNode(node)
            default: throw W3CManifestError.malformed(manifest, "a list cell that is a literal")
            }
            guard let first = objects(of: subject, Vocabulary.rdf("first")).first,
                  let rest = objects(of: subject, Vocabulary.rdf("rest")).first else {
                throw W3CManifestError.malformed(manifest, "a broken list")
            }
            members.append(first)
            cell = rest
        }
        return members
    }
}

extension W3CTestCase.Kind {
    /// The kind of test an entry is, by its classes in the RDF test
    /// vocabulary.
    ///
    /// The RDF/XML manifests state their evaluation tests are members of
    /// `rdft:TestXMLEval`, a class the published test vocabulary does not
    /// declare (it declares `rdft:XMLEval`, "A positive RDF/XML evaluation
    /// test"). Of the RDF/XML entries, only evaluation tests name an expected
    /// outcome (`mf:result`), so an entry of no declared class with a result
    /// is an evaluation test.
    init?(types: some Sequence<IRI>, hasResult: Bool) {
        for type in types where type.rawValue.hasPrefix(Vocabulary.rdftNamespace) {
            switch type.rawValue.dropFirst(Vocabulary.rdftNamespace.count) {
            case "TestNTriplesPositiveSyntax", "TestTurtlePositiveSyntax":
                self = .positiveSyntax
                return
            case "TestNTriplesNegativeSyntax", "TestTurtleNegativeSyntax", "TestXMLNegativeSyntax":
                self = .negativeSyntax
                return
            case "TestTurtleEval", "XMLEval":
                self = .evaluation
                return
            case "TestNTriplesPositiveC14N":
                self = .canonicalization
                return
            default:
                continue
            }
        }
        guard hasResult else { return nil }
        self = .evaluation
    }
}
