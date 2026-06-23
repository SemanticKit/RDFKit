import Foundation
import SwiftSyntax

struct MetadataInitializerGenerator {
    static func generate(properties: [MetadataProperty]) -> VariableDeclSyntax {
        VariableDeclSyntax(
            modifiers: DeclModifierListSyntax {
                DeclModifierSyntax(name: .keyword(.public))
                DeclModifierSyntax(name: .keyword(.static))
            },
            bindingSpecifier: .keyword(.let),
            bindings: PatternBindingListSyntax {
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(identifier: .identifier("metadata")),
                    typeAnnotation: TypeAnnotationSyntax(
                        type: IdentifierTypeSyntax(name: .identifier("Metadata"))
                    ),
                    initializer: InitializerClauseSyntax(
                        value: FunctionCallExprSyntax(
                            calledExpression: DeclReferenceExprSyntax(
                                baseName: .identifier("Metadata")
                            ),
                            arguments: LabeledExprListSyntax {
                                for prop in properties {
                                    LabeledExprSyntax(
                                        label: .identifier(prop.name),
                                        colon: .colonToken(),
                                        expression: StringLiteralExprSyntax(content: prop.value)
                                    )
                                }
                            }
                        )
                    )
                )
            }
        )
    }
}
