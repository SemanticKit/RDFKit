
import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

/// Entry point for the @Ontology macro.
///
/// Parses DSL content and generates Entity-conforming types with nested Metadata.
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
        var results: [DeclSyntax] = []

        for entity in ontology.entities {
            let generated = EntityGenerator.generate(
                entity: entity,
                ontology: ontology
            )
            results.append(contentsOf: generated)
        }

        return results
    }
}
