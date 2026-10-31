import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import XSDDefinitions

/// Generates a datatype's lexical mapping, `init(lexicalForm:)` (XML Schema
/// 1.1 Part 2 §3.3): the lexical form normalized as the datatype's
/// whiteSpace facet says, checked against the pattern facets of its
/// derivation steps, and mapped by its primitive's lexical mapping, which
/// `XSD` implements (LexicalMapping.swift). The facets are the documents';
/// the mapping is the primitive's.
///
///     public init(lexicalForm: String) throws(DatatypeError) {
///         guard let value = try BigInteger(exactly: XSD.decimalLexicalMap(XSD.lexicalForm(lexicalForm, whiteSpace: .collapse, patterns: [["[\\-+]?[0-9]+"]]))) else {
///             throw DatatypeError.illTyped
///         }
///         self.init(value)
///     }
struct LexicalEmitter {
    let definitions: DatatypeDefinitions

    /// The lexical mapping of each primitive translated so far, by the name
    /// §3.3 gives it.
    static let lexicalMaps: [String: String] = [
        "string": "stringLexicalMap",
        "boolean": "booleanLexicalMap",
        "decimal": "decimalLexicalMap",
        "float": "floatLexicalMap",
        "double": "doubleLexicalMap",
    ]

    /// `init(lexicalForm:)` for xsd:`name`: a struct's initializes its
    /// value, and a Swift type's (`isSwiftType`) assigns `self`. A struct
    /// whose `init(_:)` checks facets (`valueThrows`) is initialized with
    /// `try`.
    func initializer(for name: String, isSwiftType: Bool, valueThrows: Bool = false) throws -> InitializerDeclSyntax {
        guard let definition = definitions.datatype(named: name) else {
            throw EmitError(description: "RDF 1.2 Concepts lists no xsd:\(name)")
        }
        let chain = definitions.chain(to: definition)
        let primitive = chain[0]
        guard let lexicalMap = Self.lexicalMaps[primitive.name], let primitiveValue = DatatypeEmitter.valueSpaces[primitive.name] else {
            throw EmitError(description: "xsd:\(name): the lexical mapping of xsd:\(primitive.name) is not translated yet")
        }
        // The whiteSpace of the nearest step that gives one (§4.3.6).
        guard let whiteSpace = chain.reversed().lazy.compactMap({ step in step.facets.last { $0.name == "whiteSpace" }?.value }).first else {
            throw EmitError(description: "xsd:\(name): no definition from xsd:\(primitive.name) gives a whiteSpace")
        }
        // Each pattern in the regex syntax of Swift (Appendix G).
        let patterns = try chain.map { step in
            try step.facets.filter { $0.name == "pattern" }.map { try PatternTranslation(xsd: $0.value).regex }
        }.filter { !$0.isEmpty }
        for pattern in patterns.joined() where (try? Regex(pattern)) == nil {
            throw EmitError(description: "xsd:\(name): its pattern translates to \(pattern), which is not a Swift regex")
        }

        let arguments = LabeledExprListSyntax {
            LabeledExprSyntax(expression: DeclReferenceExprSyntax(baseName: .identifier("lexicalForm")))
            LabeledExprSyntax(label: "whiteSpace", expression: MemberAccessExprSyntax(name: .identifier(whiteSpace)))
            if !patterns.isEmpty {
                LabeledExprSyntax(label: "patterns", expression: ArrayExprSyntax {
                    for step in patterns {
                        ArrayElementSyntax(expression: ArrayExprSyntax {
                            for pattern in step {
                                ArrayElementSyntax(expression: StringLiteralExprSyntax(content: pattern))
                            }
                        })
                    }
                })
            }
        }
        let mapped = call(lexicalMap, on: "XSD", [LabeledExprSyntax(expression: call("lexicalForm", on: "XSD", arguments))])

        let body: CodeBlockSyntax
        if isSwiftType {
            body = CodeBlockSyntax {
                InfixOperatorExprSyntax(
                    leftOperand: DeclReferenceExprSyntax(baseName: .keyword(.self)),
                    operator: AssignmentExprSyntax(),
                    rightOperand: TryExprSyntax(expression: mapped)
                )
            }
        } else if let value = chain.reversed().lazy.compactMap({ DatatypeEmitter.valueSpaces[$0.name] }).first, value != primitiveValue {
            // A value space within the primitive's: the value is the
            // primitive value's, when it is one (`BigInteger(exactly:)`).
            body = CodeBlockSyntax {
                GuardStmtSyntax(
                    conditions: [ConditionElementSyntax(condition: .optionalBinding(OptionalBindingConditionSyntax(
                        bindingSpecifier: .keyword(.let),
                        pattern: IdentifierPatternSyntax(identifier: .identifier("value")),
                        initializer: InitializerClauseSyntax(value: TryExprSyntax(expression: FunctionCallExprSyntax(
                            calledExpression: DeclReferenceExprSyntax(baseName: .identifier(value)),
                            leftParen: .leftParenToken(),
                            arguments: [LabeledExprSyntax(label: "exactly", expression: mapped)],
                            rightParen: .rightParenToken()
                        )))
                    )))],
                    body: CodeBlockSyntax {
                        ThrowStmtSyntax(expression: MemberAccessExprSyntax(base: DeclReferenceExprSyntax(baseName: .identifier("DatatypeError")), name: .identifier("illTyped")))
                    }
                )
                if valueThrows {
                    TryExprSyntax(expression: selfInit(DeclReferenceExprSyntax(baseName: .identifier("value"))))
                } else {
                    selfInit(DeclReferenceExprSyntax(baseName: .identifier("value")))
                }
            }
        } else {
            body = CodeBlockSyntax {
                TryExprSyntax(expression: selfInit(mapped))
            }
        }

        let patternNote = patterns.isEmpty ? "" : ", that matches its patterns"
        return InitializerDeclSyntax(
            leadingTrivia: doc([
                "The value of xsd:\(name) a lexical form denotes: its lexical mapping, ·\(lexicalMap)·, of the",
                "form after whiteSpace \(whiteSpace)\(patternNote) (XML Schema 1.1 Part 2 §3.3, §4.3.6).",
                "",
                "- Throws: `DatatypeError.illTyped` when the form is not in the lexical space.",
            ]),
            modifiers: [DeclModifierSyntax(name: .keyword(.public))],
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax {
                    FunctionParameterSyntax(firstName: .identifier("lexicalForm"), type: TypeSyntax("String"))
                },
                effectSpecifiers: FunctionEffectSpecifiersSyntax(throwsClause: ThrowsClauseSyntax(
                    throwsSpecifier: .keyword(.throws),
                    leftParen: .leftParenToken(),
                    type: TypeSyntax("DatatypeError"),
                    rightParen: .rightParenToken()
                ))
            ),
            body: body
        )
    }

    /// `base.name(arguments)`.
    private func call(_ name: String, on base: String, _ arguments: LabeledExprListSyntax) -> FunctionCallExprSyntax {
        FunctionCallExprSyntax(
            calledExpression: MemberAccessExprSyntax(base: DeclReferenceExprSyntax(baseName: .identifier(base)), name: .identifier(name)),
            leftParen: .leftParenToken(),
            arguments: arguments,
            rightParen: .rightParenToken()
        )
    }

    /// `self.init(value)`.
    private func selfInit(_ value: some ExprSyntaxProtocol) -> FunctionCallExprSyntax {
        FunctionCallExprSyntax(
            calledExpression: MemberAccessExprSyntax(base: DeclReferenceExprSyntax(baseName: .keyword(.self)), declName: DeclReferenceExprSyntax(baseName: .keyword(.`init`))),
            leftParen: .leftParenToken(),
            arguments: [LabeledExprSyntax(expression: value)],
            rightParen: .rightParenToken()
        )
    }

    private func doc(_ lines: [String]) -> Trivia {
        Trivia(pieces: lines.flatMap { [TriviaPiece.docLineComment($0.isEmpty ? "///" : "/// \($0)"), .newlines(1)] })
    }
}
