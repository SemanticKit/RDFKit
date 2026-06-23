import Foundation
import SwiftSyntax

struct InstancePropertyGenerator {
    static func generateStoredProperties(properties: [ParsedEntity]) -> [VariableDeclSyntax] {
        properties.map { prop in
            let range = prop.annotationValue(named: "Range")
            let typeName = resolveType(from: range)
            return VariableDeclSyntax(
                modifiers: DeclModifierListSyntax {
                    DeclModifierSyntax(name: .keyword(.public))
                },
                bindingSpecifier: .keyword(.let),
                bindings: PatternBindingListSyntax {
                    PatternBindingSyntax(
                        pattern: IdentifierPatternSyntax(identifier: .identifier(prop.name)),
                        typeAnnotation: TypeAnnotationSyntax(
                            type: IdentifierTypeSyntax(name: .identifier(typeName))
                        )
                    )
                }
            )
        }
    }

    static func generateInitializer(properties: [ParsedEntity]) -> InitializerDeclSyntax? {
        guard !properties.isEmpty else { return nil }

        return InitializerDeclSyntax(
            modifiers: DeclModifierListSyntax {
                DeclModifierSyntax(name: .keyword(.public))
            },
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax(
                    parameters: FunctionParameterListSyntax {
                        FunctionParameterSyntax(
                            firstName: .identifier("id"),
                            type: IdentifierTypeSyntax(name: .identifier("IRI"))
                        )
                        for prop in properties {
                            let range = prop.annotationValue(named: "Range")
                            let typeName = resolveType(from: range)
                            FunctionParameterSyntax(
                                firstName: .identifier(prop.name),
                                type: IdentifierTypeSyntax(name: .identifier(typeName))
                            )
                        }
                    }
                )
            ),
            body: CodeBlockSyntax(
                statements: CodeBlockItemListSyntax {
                    "self.id = id"
                    for prop in properties {
                        "self.\(raw: prop.name) = \(raw: prop.name)"
                    }
                }
            )
        )
    }

    private static func resolveType(from range: String) -> String {
        switch range {
        case "RDFS.Literal": return "String"
        case "RDFS.Class", "RDFS.Resource": return "IRI"
        default: return "IRI"
        }
    }
}
