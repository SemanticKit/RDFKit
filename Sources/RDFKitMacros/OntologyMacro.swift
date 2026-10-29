import SwiftSyntax
import SwiftSyntaxMacros

/// Entry point for the `@Ontology` macro.
///
/// Reads the ontology's DSL content and generates one Swift type per declared
/// term, nested inside the ontology. See ``EntityGenerator`` for what each
/// declaration becomes.
public struct OntologyMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let ontology = try OntologyParser.parse(declaration: declaration)
        return EntityGenerator.generate(ontology: ontology)
    }
}
