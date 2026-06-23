import Foundation
import SwiftSyntax

struct StoredPropertyGenerator {
    static func generate(properties: [MetadataProperty]) -> [VariableDeclSyntax] {
        properties.map { prop in
            VariableDeclSyntax(
                modifiers: DeclModifierListSyntax {
                    DeclModifierSyntax(name: .keyword(.public))
                },
                bindingSpecifier: .keyword(.let),
                bindings: PatternBindingListSyntax {
                    PatternBindingSyntax(
                        pattern: IdentifierPatternSyntax(identifier: .identifier(prop.name)),
                        typeAnnotation: TypeAnnotationSyntax(
                            type: IdentifierTypeSyntax(name: .identifier(prop.typeName))
                        )
                    )
                }
            )
        }
    }
}
