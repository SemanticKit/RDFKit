import SwiftSyntax
import SwiftSyntaxMacros

/// Entry point for the `@Ontology` macro.
///
/// Reads the ontology's DSL content from its `func content()` and generates
/// one Swift type per declared term, nested inside the ontology. See
/// ``EntityGenerator`` for what each declaration becomes. It also attaches
/// ``OntologyContentMacro`` to `content()`, which turns the authored body
/// into content built from those types.
public struct OntologyMacro: MemberMacro, MemberAttributeMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let ontology = try OntologyParser.parse(declaration: declaration)
        return EntityGenerator.generate(ontology: ontology)
    }

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        guard let function = member.as(FunctionDeclSyntax.self),
              OntologyParser.isContentFunction(function),
              !function.attributes.contains(where: { $0.as(AttributeSyntax.self)?.attributeName.trimmedDescription == "OntologyContent" })
        else { return [] }
        return ["@OntologyContent"]
    }
}
