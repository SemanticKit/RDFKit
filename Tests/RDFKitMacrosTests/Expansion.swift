import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport
import Testing
@testable import RDFKitMacros

/// The macros under test, by the attribute name they are written with.
let macroSpecs: [String: MacroSpec] = [
    "Ontology": MacroSpec(type: OntologyMacro.self),
    "OntologyContent": MacroSpec(type: OntologyContentMacro.self),
    "IndividualStoring": MacroSpec(type: IndividualStoringMacro.self),
]

/// Expands the ontology macros on `source` and checks the result.
func assertExpansion(
    _ source: String,
    expandedSource: String,
    diagnostics: [DiagnosticSpec] = [],
    applyFixIts: [String]? = nil,
    fixedSource: String? = nil,
    testFileName: String = "test.swift",
    sourceLocation: SourceLocation = #_sourceLocation
) {
    assertMacroExpansion(
        source,
        expandedSource: expandedSource,
        diagnostics: diagnostics,
        macroSpecs: macroSpecs,
        applyFixIts: applyFixIts,
        fixedSource: fixedSource,
        testFileName: testFileName,
        failureHandler: { failure in
            Issue.record(Comment(rawValue: failure.message), sourceLocation: sourceLocation)
        }
    )
}
