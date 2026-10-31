import OntologyGeneration
import SwiftSyntax
import SwiftSyntaxMacros

/// Entry point for the @Ontology macro.
///
/// Reads the ontology's body and generates the Swift types its declarations
/// declare. It also attaches ``OntologyBodyMacro`` to `var body`, which owns
/// the authored body so that it is read only as syntax.
public struct OntologyMacro: MemberMacro, MemberAttributeMacro {
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
            + ontology.properties.compactMap { PropertyGenerator.generate(property: $0, in: ontology) }
    }

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        guard let variable = member.as(VariableDeclSyntax.self),
              OntologyParser.isBody(variable) else { return [] }
        return ["@OntologyBody"]
    }
}
