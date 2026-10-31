import SwiftSyntax
import SwiftSyntaxMacros

/// Entry point for the @Ontology macro.
///
/// Reads the ontology's body and generates the Swift types its declarations
/// declare.
public struct OntologyMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo types: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.is(StructDeclSyntax.self) else {
            throw MacroError("@Ontology can only be applied to structs")
        }

        let ontology = try OntologyParser.parse(declaration: declaration)
        return ontology.classes.map { ClassGenerator.generate(class: $0, in: ontology) }
    }
}
