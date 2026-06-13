import SwiftCompilerPlugin
import SwiftSyntaxMacros

/// Registers RDFKit compiler-plugin macros with Swift.
@main
struct RDFKitMacrosPlugin: CompilerPlugin {
    /// The macro implementations exported by this compiler plugin.
    let providingMacros: [Macro.Type] = [
        OntologyModuleMacro.self
    ]
}
