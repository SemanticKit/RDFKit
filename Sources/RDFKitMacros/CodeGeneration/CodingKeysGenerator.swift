import Foundation
import SwiftSyntax

struct CodingKeysGenerator {
    static func generate(properties: [MetadataProperty]) -> EnumDeclSyntax {
        EnumDeclSyntax(
            modifiers: DeclModifierListSyntax {
                DeclModifierSyntax(name: .keyword(.public))
            },
            name: .identifier("CodingKeys"),
            inheritanceClause: InheritanceClauseSyntax {
                InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier("String")))
                InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier("CodingKey")))
                InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier("CaseIterable")))
            },
            memberBlock: MemberBlockSyntax {
                for prop in properties {
                    MemberBlockItemSyntax(
                        decl: EnumCaseDeclSyntax(
                            elements: EnumCaseElementListSyntax {
                                EnumCaseElementSyntax(
                                    name: .identifier(prop.name),
                                    rawValue: InitializerClauseSyntax(
                                        value: StringLiteralExprSyntax(content: prop.name)
                                    )
                                )
                            }
                        )
                    )
                }
            }
        )
    }
}
