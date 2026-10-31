import SwiftSyntax
import SwiftSyntaxBuilder
import XSDDefinitions

/// Generates the lexical and canonical mappings of the datatypes whose value
/// space is a finite sequence of octets, `[UInt8]`: `xsd:hexBinary` and
/// `xsd:base64Binary` (XML Schema 1.1 Part 2 §3.3.15–16), and any datatype
/// derived from them. ``DatatypeEmitter`` gives each its struct; this adds
/// an extension that maps a lexical form to the value and the value to its
/// canonical representation, with the algorithms of `OctetSequence`.
///
///     extension XSD.hexBinary {
///         public init(lexicalForm: String) throws(DatatypeError)
///         public var canonicalForm: String { get }
///     }
struct BinaryEmitter {
    let definitions: DatatypeDefinitions

    /// The mappings of each primitive whose value space is a sequence of
    /// octets: the names of its lexical and canonical mapping and where the
    /// specification gives them.
    static let mappings: [String: (lexical: String, canonical: String, section: String)] = [
        "hexBinary": ("hexBinaryMap", "hexBinaryCanonical", "§3.3.15.2, §E.4"),
        "base64Binary": ("base64BinaryMap", "base64BinaryCanonical", "§3.3.16.2"),
    ]

    /// The extensions for the datatypes among `names` whose primitive has
    /// octet-sequence mappings, in the order of `names`.
    func extensions(for names: [String]) -> [ExtensionDeclSyntax] {
        names.compactMap { name in
            guard let definition = definitions.datatype(named: name),
                  let primitive = definitions.chain(to: definition).first,
                  let mapping = Self.mappings[primitive.name] else { return nil }
            return mappingExtension(name, primitive: primitive.name, mapping: mapping)
        }
    }

    private func mappingExtension(_ name: String, primitive: String, mapping: (lexical: String, canonical: String, section: String)) -> ExtensionDeclSyntax {
        ExtensionDeclSyntax(
            leadingTrivia: doc(["The lexical and canonical mappings of xsd:\(primitive) (XML Schema 1.1 Part 2 \(mapping.section))."]),
            extendedType: MemberTypeSyntax(baseType: IdentifierTypeSyntax(name: .identifier("XSD")), name: .identifier(name)),
            memberBlock: MemberBlockSyntax {
                InitializerDeclSyntax(
                    leadingTrivia: doc([
                        "The value ·\(mapping.lexical)· maps `lexicalForm` to.",
                        "",
                        "- Throws: `DatatypeError.illTyped` when `lexicalForm` is not in the",
                        "  lexical space of xsd:\(primitive).",
                    ]),
                    modifiers: [DeclModifierSyntax(name: .keyword(.public))],
                    signature: FunctionSignatureSyntax(
                        parameterClause: FunctionParameterClauseSyntax {
                            FunctionParameterSyntax(firstName: .identifier("lexicalForm"), type: IdentifierTypeSyntax(name: .identifier("String")))
                        },
                        effectSpecifiers: FunctionEffectSpecifiersSyntax(
                            throwsClause: ThrowsClauseSyntax(
                                throwsSpecifier: .keyword(.throws),
                                leftParen: .leftParenToken(),
                                type: IdentifierTypeSyntax(name: .identifier("DatatypeError")),
                                rightParen: .rightParenToken()
                            )
                        )
                    ),
                    body: CodeBlockSyntax {
                        FunctionCallExprSyntax(
                            callee: MemberAccessExprSyntax(base: DeclReferenceExprSyntax(baseName: .keyword(.self)), name: .keyword(.`init`))
                        ) {
                            LabeledExprSyntax(expression: TryExprSyntax(expression: octetSequenceCall(mapping.lexical, argument: "lexicalForm")))
                        }
                    }
                )
                VariableDeclSyntax(
                    leadingTrivia: doc(["The canonical representation of the value, ·\(mapping.canonical)·."]),
                    modifiers: [DeclModifierSyntax(name: .keyword(.public))],
                    bindingSpecifier: .keyword(.var),
                    bindings: [PatternBindingSyntax(
                        pattern: IdentifierPatternSyntax(identifier: .identifier("canonicalForm")),
                        typeAnnotation: TypeAnnotationSyntax(type: IdentifierTypeSyntax(name: .identifier("String"))),
                        accessorBlock: AccessorBlockSyntax(accessors: .getter(CodeBlockItemListSyntax {
                            octetSequenceCall(mapping.canonical, argument: "value")
                        }))
                    )]
                )
            }
        )
    }

    /// `OctetSequence.<function>(<argument>)`.
    private func octetSequenceCall(_ function: String, argument: String) -> FunctionCallExprSyntax {
        FunctionCallExprSyntax(
            callee: MemberAccessExprSyntax(base: DeclReferenceExprSyntax(baseName: .identifier("OctetSequence")), name: .identifier(function))
        ) {
            LabeledExprSyntax(expression: DeclReferenceExprSyntax(baseName: .identifier(argument)))
        }
    }

    private func doc(_ lines: [String]) -> Trivia {
        Trivia(pieces: lines.flatMap { [TriviaPiece.docLineComment($0.isEmpty ? "///" : "/// \($0)"), .newlines(1)] })
    }
}
