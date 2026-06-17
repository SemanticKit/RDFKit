import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct RDFKitMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        VocabularyMacro.self
    ]
}
