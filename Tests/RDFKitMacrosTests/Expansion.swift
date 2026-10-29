import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport
import Testing
@testable import RDFKitMacros

/// The macros under test, by the attribute name they are written with.
///
/// `@Ontology` attaches `@StoredRequirements` to each class protocol it
/// generates, and the expansion includes that macro's extension. This harness
/// passes the protocol's own name as the extended type (`extension Animal`);
/// the compiler passes the qualified name (`extension Zoo.Animal`).
let macroSpecs: [String: MacroSpec] = [
    "Ontology": MacroSpec(type: OntologyMacro.self),
    "OntologyContent": MacroSpec(type: OntologyContentMacro.self),
    "StoredRequirements": MacroSpec(type: StoredRequirementsMacro.self),
]

/// Expands the ontology macros on `source` and checks the result.
func assertExpansion(
    _ source: String,
    expandedSource: String,
    diagnostics: [DiagnosticSpec] = [],
    applyFixIts: [String]? = nil,
    fixedSource: String? = nil,
    sourceLocation: SourceLocation = #_sourceLocation
) {
    assertMacroExpansion(
        source,
        expandedSource: expandedSource,
        diagnostics: diagnostics,
        macroSpecs: macroSpecs,
        applyFixIts: applyFixIts,
        fixedSource: fixedSource,
        failureHandler: { failure in
            Issue.record(Comment(rawValue: failure.message), sourceLocation: sourceLocation)
        }
    )
}
