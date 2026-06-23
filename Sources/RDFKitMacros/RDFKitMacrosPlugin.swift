import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct RDFKitMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        OntologyMacro.self
    ]
}
