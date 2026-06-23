import Foundation
import SwiftSyntax

struct MetadataGenerator {
    static func generate(properties: [MetadataProperty]) -> StructDeclSyntax {
        let codingKeys = CodingKeysGenerator.generate(properties: properties)
        let storedProps = StoredPropertyGenerator.generate(properties: properties)

        return StructDeclSyntax(
            modifiers: DeclModifierListSyntax {
                DeclModifierSyntax(name: .keyword(.public))
            },
            name: .identifier("Metadata"),
            inheritanceClause: InheritanceClauseSyntax {
                InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier("ContentMetadata")))
            },
            memberBlock: MemberBlockSyntax {
                MemberBlockItemSyntax(
                    decl: TypeAliasDeclSyntax(
                        modifiers: DeclModifierListSyntax {
                            DeclModifierSyntax(name: .keyword(.public))
                        },
                        name: .identifier("ID"),
                        initializer: TypeInitializerClauseSyntax(
                            value: IdentifierTypeSyntax(name: .identifier("IRI"))
                        )
                    )
                )

                MemberBlockItemSyntax(decl: codingKeys)

                for prop in storedProps {
                    MemberBlockItemSyntax(decl: prop)
                }
            }
        )
    }
}
