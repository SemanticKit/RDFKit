import SwiftSyntax
import SwiftSyntaxBuilder
import XSDDefinitions

/// Generates the Swift value type of an XML Schema datatype (D6): a struct
/// in `XSD`, conforming to `RDFS.Literal`, whose value is the Swift type of
/// its primitive's value space.
///
///     extension XSD {
///         /// xsd:string (http://www.w3.org/TR/xmlschema11-2/#string)
///         public struct string: RDFS.Literal, Hashable, Sendable {
///             public var value: String
///             public init(_ value: String)
///         }
///     }
struct DatatypeEmitter {
    let definitions: DatatypeDefinitions

    /// The Swift type of the value space of each datatype translated so far.
    /// A datatype takes the value space of the nearest datatype it is
    /// derived from that has one.
    static let valueSpaces: [String: String] = [
        "string": "String",
        "boolean": "Bool",
        "double": "Double",
    ]

    func emit(_ names: [String]) throws -> String {
        let structs = try names.map { try datatype(named: $0) }
        let file = SourceFileSyntax {
            ImportDeclSyntax(path: [ImportPathComponentSyntax(name: .identifier("RDFKit"))])
            ExtensionDeclSyntax(
                extendedType: TypeSyntax("XSD"),
                memberBlock: MemberBlockSyntax {
                    for type in structs { type }
                }
            )
        }
        return file.formatted().description + "\n"
    }

    private func datatype(named name: String) throws -> StructDeclSyntax {
        guard let definition = definitions.datatype(named: name) else {
            throw EmitError(description: "RDF 1.2 Concepts lists no xsd:\(name)")
        }
        guard let primitive = definitions.chain(to: definition).reversed().first(where: { Self.valueSpaces[$0.name] != nil }),
              let value = Self.valueSpaces[primitive.name] else {
            throw EmitError(description: "xsd:\(name) has no value space translated yet")
        }
        let valueType = TypeSyntax(stringLiteral: value)
        return StructDeclSyntax(
            leadingTrivia: doc(["xsd:\(name)" + (definition.source.map { " (\($0))" } ?? "")]),
            modifiers: [DeclModifierSyntax(name: .keyword(.public))],
            name: .identifier(name),
            inheritanceClause: InheritanceClauseSyntax {
                InheritedTypeSyntax(type: TypeSyntax("RDFS.Literal"))
                InheritedTypeSyntax(type: TypeSyntax("Hashable"))
                InheritedTypeSyntax(type: TypeSyntax("Sendable"))
            },
            memberBlock: MemberBlockSyntax {
                VariableDeclSyntax(
                    leadingTrivia: doc(["The value, in the value space of xsd:\(primitive.name)."]),
                    modifiers: [DeclModifierSyntax(name: .keyword(.public))],
                    bindingSpecifier: .keyword(.var),
                    bindings: [PatternBindingSyntax(
                        pattern: IdentifierPatternSyntax(identifier: .identifier("value")),
                        typeAnnotation: TypeAnnotationSyntax(type: valueType)
                    )]
                )
                InitializerDeclSyntax(
                    leadingTrivia: doc(["A value of xsd:\(name)."]),
                    modifiers: [DeclModifierSyntax(name: .keyword(.public))],
                    signature: FunctionSignatureSyntax(parameterClause: FunctionParameterClauseSyntax {
                        FunctionParameterSyntax(firstName: .wildcardToken(), secondName: .identifier("value"), type: valueType)
                    }),
                    body: CodeBlockSyntax {
                        InfixOperatorExprSyntax(
                            leftOperand: MemberAccessExprSyntax(base: DeclReferenceExprSyntax(baseName: .keyword(.self)), name: .identifier("value")),
                            operator: AssignmentExprSyntax(),
                            rightOperand: DeclReferenceExprSyntax(baseName: .identifier("value"))
                        )
                    }
                )
            }
        )
    }

    private func doc(_ lines: [String]) -> Trivia {
        Trivia(pieces: lines.flatMap { [TriviaPiece.docLineComment("/// \($0)"), .newlines(1)] })
    }
}
