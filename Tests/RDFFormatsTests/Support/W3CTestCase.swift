import Foundation
import IRIKit
import Testing

/// One test from a W3C RDF test manifest.
struct W3CTestCase: Sendable, CustomTestStringConvertible {
    enum Kind: Sendable {
        case positiveSyntax
        case negativeSyntax
        case evaluation
        case canonicalization
    }

    /// The test's IRI, as the manifest names it.
    let id: IRI
    let name: String
    let kind: Kind
    /// The document the test reads, and its IRI, which is its base IRI.
    let action: IRI
    let actionFile: URL
    /// The document the test expects, for evaluation and canonicalization tests.
    let resultFile: URL?

    var testDescription: String { "\(name) <\(id)>" }

    func readAction() throws -> String {
        try String(contentsOf: actionFile, encoding: .utf8)
    }

    func readResult() throws -> String {
        guard let resultFile else { throw W3CManifestError.missingResult(id) }
        return try String(contentsOf: resultFile, encoding: .utf8)
    }
}
