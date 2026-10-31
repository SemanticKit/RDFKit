import SwiftSyntax
import SwiftSyntaxBuilder
import XSDDefinitions

/// Generates the Swift type of `xsd:duration` and of each datatype derived
/// from it, `xsd:yearMonthDuration` and `xsd:dayTimeDuration` (RDF 1.2
/// Concepts §5.1), on the value space of durations, ``DurationValue``.
///
/// A derived datatype's lexical space is its base's restricted by the
/// patterns `derived.nxsd` gives it, and its value space is the values that
/// have a representation in that lexical space (XML Schema 1.1 Part 2
/// §4.3.4.4: "the lexical space of the derived type is restricted"). The
/// patterns of one derivation step are alternatives, and every step's apply
/// (§4.3.4.3).
///
///     /// xsd:yearMonthDuration (http://www.w3.org/TR/xmlschema11-2/#yearMonthDuration)
///     public struct yearMonthDuration: RDFS.Literal, Hashable, Sendable {
///         static let patterns: [[String]] = [["[^DT]*"]]
///         public let value: DurationValue
///         public init(_ value: DurationValue) throws(DatatypeError)
///         public init(lexicalForm: String) throws(DatatypeError)
///         public var lexicalForm: String
///     }
struct DurationEmitter {
    let definitions: DatatypeDefinitions

    /// The primitive datatype whose value space this emitter translates.
    static let primitive = "duration"

    /// The Swift type of xsd:duration, or `nil` when `name` is not derived
    /// from it.
    func datatype(named name: String) throws -> DeclSyntax? {
        guard let definition = definitions.datatype(named: name) else { return nil }
        let chain = definitions.chain(to: definition)
        guard chain.first?.name == Self.primitive, let value = DatatypeEmitter.valueSpaces[Self.primitive] else { return nil }
        let patterns = chain.map { $0.facets.filter { $0.name == "pattern" }.map(\.value) }.filter { !$0.isEmpty }
        return DeclSyntax(valueType(definition, valueType: TypeSyntax(stringLiteral: value), patterns: patterns))
    }

    private func valueType(_ definition: SimpleTypeDefinition, valueType: TypeSyntax, patterns: [[String]]) -> StructDeclSyntax {
        let name = definition.name
        let isRestricted = !patterns.isEmpty
        let throwsClause = ThrowsClauseSyntax(
            throwsSpecifier: .keyword(.throws),
            leftParen: .leftParenToken(),
            type: TypeSyntax("DatatypeError"),
            rightParen: .rightParenToken()
        )
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
                if isRestricted {
                    patternsDecl(name, patterns: patterns)
                }
                VariableDeclSyntax(
                    leadingTrivia: doc(["The value, in the value space of xsd:\(Self.primitive)."]),
                    modifiers: [DeclModifierSyntax(name: .keyword(.public))],
                    bindingSpecifier: .keyword(isRestricted ? .let : .var),
                    bindings: [PatternBindingSyntax(
                        pattern: IdentifierPatternSyntax(identifier: .identifier("value")),
                        typeAnnotation: TypeAnnotationSyntax(type: valueType)
                    )]
                )
                InitializerDeclSyntax(
                    leadingTrivia: doc(isRestricted
                        ? ["A value of xsd:\(name): a duration with a lexical representation its patterns allow.",
                           "",
                           "- Throws: `DatatypeError.illTyped` for a duration outside its value space."]
                        : ["A value of xsd:\(name)."]),
                    modifiers: [DeclModifierSyntax(name: .keyword(.public))],
                    signature: FunctionSignatureSyntax(
                        parameterClause: FunctionParameterClauseSyntax {
                            FunctionParameterSyntax(firstName: .wildcardToken(), secondName: .identifier("value"), type: valueType)
                        },
                        effectSpecifiers: isRestricted ? FunctionEffectSpecifiersSyntax(throwsClause: throwsClause) : nil
                    ),
                    body: CodeBlockSyntax {
                        if isRestricted {
                            guardStatement(
                                condition: ExprSyntax(FunctionCallExprSyntax(
                                    callee: MemberAccessExprSyntax(
                                        base: MemberAccessExprSyntax(base: DeclReferenceExprSyntax(baseName: .identifier("value")), name: .identifier("representations")),
                                        name: .identifier("contains")
                                    )
                                ) {
                                    LabeledExprSyntax(
                                        label: .identifier("where"),
                                        colon: .colonToken(),
                                        expression: MemberAccessExprSyntax(base: DeclReferenceExprSyntax(baseName: .keyword(.Self)), name: .identifier("allows"))
                                    )
                                })
                            )
                        }
                        assignment(to: "value", ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier("value"))))
                    }
                )
                InitializerDeclSyntax(
                    leadingTrivia: doc([
                        "The value of xsd:\(name) a lexical form denotes, by ·durationMap· (XML Schema 1.1 Part 2 §E.2).",
                        "",
                        "- Throws: `DatatypeError.illTyped` for a form outside the lexical space of xsd:\(name).",
                    ]),
                    modifiers: [DeclModifierSyntax(name: .keyword(.public))],
                    signature: FunctionSignatureSyntax(
                        parameterClause: FunctionParameterClauseSyntax {
                            FunctionParameterSyntax(firstName: .identifier("lexicalForm"), type: TypeSyntax("String"))
                        },
                        effectSpecifiers: FunctionEffectSpecifiersSyntax(throwsClause: throwsClause)
                    ),
                    body: CodeBlockSyntax {
                        if isRestricted {
                            guardStatement(condition: ExprSyntax(FunctionCallExprSyntax(
                                callee: MemberAccessExprSyntax(base: DeclReferenceExprSyntax(baseName: .keyword(.Self)), name: .identifier("allows"))
                            ) {
                                LabeledExprSyntax(expression: DeclReferenceExprSyntax(baseName: .identifier("lexicalForm")))
                            }))
                        }
                        assignment(to: "value", ExprSyntax(TryExprSyntax(expression: FunctionCallExprSyntax(
                            callee: DeclReferenceExprSyntax(baseName: .identifier("DurationValue"))
                        ) {
                            LabeledExprSyntax(
                                label: .identifier("lexicalForm"),
                                colon: .colonToken(),
                                expression: DeclReferenceExprSyntax(baseName: .identifier("lexicalForm"))
                            )
                        })))
                    }
                )
                lexicalFormDecl(name, isRestricted: isRestricted)
                if isRestricted {
                    allowsDecl()
                }
            }
        )
    }

    /// `static let patterns: [[String]] = [["[^DT]*"]]`, one array for each
    /// derivation step that gives patterns.
    private func patternsDecl(_ name: String, patterns: [[String]]) -> VariableDeclSyntax {
        VariableDeclSyntax(
            leadingTrivia: doc(["The patterns that restrict the lexical space of xsd:\(name), for each derivation step (XML Schema 1.1 Part 2 §4.3.4)."]),
            modifiers: [DeclModifierSyntax(name: .keyword(.static))],
            bindingSpecifier: .keyword(.let),
            bindings: [PatternBindingSyntax(
                pattern: IdentifierPatternSyntax(identifier: .identifier("patterns")),
                typeAnnotation: TypeAnnotationSyntax(type: ArrayTypeSyntax(element: ArrayTypeSyntax(element: TypeSyntax("String")))),
                initializer: InitializerClauseSyntax(value: ArrayExprSyntax {
                    for step in patterns {
                        ArrayElementSyntax(expression: ArrayExprSyntax {
                            for pattern in step {
                                ArrayElementSyntax(expression: StringLiteralExprSyntax(content: pattern))
                            }
                        })
                    }
                })
            )]
        )
    }

    /// `public var lexicalForm: String`, the canonical representation of the
    /// value in the datatype's lexical space.
    private func lexicalFormDecl(_ name: String, isRestricted: Bool) -> VariableDeclSyntax {
        let canonical = MemberAccessExprSyntax(base: DeclReferenceExprSyntax(baseName: .identifier("value")), name: .identifier("canonicalForm"))
        let body: ExprSyntax
        if isRestricted {
            // value.representations.first(where: Self.allows) ?? value.canonicalForm
            body = ExprSyntax(InfixOperatorExprSyntax(
                leftOperand: FunctionCallExprSyntax(
                    callee: MemberAccessExprSyntax(
                        base: MemberAccessExprSyntax(base: DeclReferenceExprSyntax(baseName: .identifier("value")), name: .identifier("representations")),
                        name: .identifier("first")
                    )
                ) {
                    LabeledExprSyntax(
                        label: .identifier("where"),
                        colon: .colonToken(),
                        expression: MemberAccessExprSyntax(base: DeclReferenceExprSyntax(baseName: .keyword(.Self)), name: .identifier("allows"))
                    )
                },
                operator: BinaryOperatorExprSyntax(operator: .binaryOperator("??")),
                rightOperand: canonical
            ))
        } else {
            body = ExprSyntax(canonical)
        }
        return VariableDeclSyntax(
            leadingTrivia: doc(isRestricted
                ? ["The canonical representation of the value in the lexical space of xsd:\(name) (XML Schema 1.1 Part 2 §E.2)."]
                : ["The canonical representation of the value, by ·durationCanonicalMap· (XML Schema 1.1 Part 2 §E.2)."]),
            modifiers: [DeclModifierSyntax(name: .keyword(.public))],
            bindingSpecifier: .keyword(.var),
            bindings: [PatternBindingSyntax(
                pattern: IdentifierPatternSyntax(identifier: .identifier("lexicalForm")),
                typeAnnotation: TypeAnnotationSyntax(type: TypeSyntax("String")),
                accessorBlock: AccessorBlockSyntax(accessors: .getter(CodeBlockItemListSyntax {
                    CodeBlockItemSyntax(item: .expr(body))
                }))
            )]
        )
    }

    /// Whether a representation is in the restricted lexical space: it
    /// matches, as a whole (§G.1: "implicitly anchored"), one pattern of each
    /// step.
    ///
    ///     static func allows(_ lexicalForm: String) -> Bool {
    ///         patterns.allSatisfy { step in
    ///             step.contains { pattern in (try? Regex(pattern).wholeMatch(in: lexicalForm)) != nil }
    ///         }
    ///     }
    private func allowsDecl() -> FunctionDeclSyntax {
        let match = InfixOperatorExprSyntax(
            leftOperand: TupleExprSyntax {
                LabeledExprSyntax(expression: TryExprSyntax(
                    questionOrExclamationMark: .postfixQuestionMarkToken(),
                    expression: FunctionCallExprSyntax(
                        callee: MemberAccessExprSyntax(
                            base: FunctionCallExprSyntax(callee: DeclReferenceExprSyntax(baseName: .identifier("Regex"))) {
                                LabeledExprSyntax(expression: DeclReferenceExprSyntax(baseName: .identifier("pattern")))
                            },
                            name: .identifier("wholeMatch")
                        )
                    ) {
                        LabeledExprSyntax(
                            label: .identifier("in"),
                            colon: .colonToken(),
                            expression: DeclReferenceExprSyntax(baseName: .identifier("lexicalForm"))
                        )
                    }
                ))
            },
            operator: BinaryOperatorExprSyntax(operator: .binaryOperator("!=")),
            rightOperand: NilLiteralExprSyntax()
        )
        let stepMatches = FunctionCallExprSyntax(
            callee: MemberAccessExprSyntax(base: DeclReferenceExprSyntax(baseName: .identifier("step")), name: .identifier("contains")),
            trailingClosure: closure(parameter: "pattern", body: ExprSyntax(match))
        ) {}
        let allSteps = FunctionCallExprSyntax(
            callee: MemberAccessExprSyntax(base: DeclReferenceExprSyntax(baseName: .identifier("patterns")), name: .identifier("allSatisfy")),
            trailingClosure: closure(parameter: "step", body: ExprSyntax(stepMatches))
        ) {}
        return FunctionDeclSyntax(
            leadingTrivia: doc(["Whether a representation matches, as a whole, one pattern of each derivation step (XML Schema 1.1 Part 2 §4.3.4.3)."]),
            modifiers: [DeclModifierSyntax(name: .keyword(.static))],
            name: .identifier("allows"),
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax {
                    FunctionParameterSyntax(firstName: .wildcardToken(), secondName: .identifier("lexicalForm"), type: TypeSyntax("String"))
                },
                returnClause: ReturnClauseSyntax(type: TypeSyntax("Bool"))
            ),
            body: CodeBlockSyntax {
                CodeBlockItemSyntax(item: .expr(ExprSyntax(allSteps)))
            }
        )
    }

    /// `{ parameter in body }`.
    private func closure(parameter: String, body: ExprSyntax) -> ClosureExprSyntax {
        ClosureExprSyntax(
            signature: ClosureSignatureSyntax(parameterClause: .simpleInput(ClosureShorthandParameterListSyntax {
                ClosureShorthandParameterSyntax(name: .identifier(parameter))
            })),
            statements: CodeBlockItemListSyntax {
                CodeBlockItemSyntax(item: .expr(body))
            }
        )
    }

    /// `guard condition else { throw .illTyped }`.
    private func guardStatement(condition: ExprSyntax) -> GuardStmtSyntax {
        GuardStmtSyntax(
            conditions: [ConditionElementSyntax(condition: .expression(condition))],
            body: CodeBlockSyntax {
                ThrowStmtSyntax(expression: MemberAccessExprSyntax(name: .identifier("illTyped")))
            }
        )
    }

    /// `self.name = value`.
    private func assignment(to name: String, _ value: ExprSyntax) -> InfixOperatorExprSyntax {
        InfixOperatorExprSyntax(
            leftOperand: MemberAccessExprSyntax(base: DeclReferenceExprSyntax(baseName: .keyword(.self)), name: .identifier(name)),
            operator: AssignmentExprSyntax(),
            rightOperand: value
        )
    }

    private func doc(_ lines: [String]) -> Trivia {
        Trivia(pieces: lines.flatMap { [TriviaPiece.docLineComment($0.isEmpty ? "///" : "/// \($0)"), .newlines(1)] })
    }
}
