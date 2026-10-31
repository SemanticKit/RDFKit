import SwiftSyntax
import SwiftSyntaxBuilder
import XSDDefinitions

/// The members of the date/time datatypes and of `xsd:anyURI` beyond their
/// value, which ``DatatypeEmitter`` adds to their structs.
///
/// - A datatype whose primitive is one of the date/time primitives, whose
///   value space is the seven-property model (XML Schema 1.1 Part 2 §D.2.1),
///   is made from a lexical form by the primitive's lexical mapping
///   (`·dateTimeLexicalMap·`, §E.3.5) and gives the lexical form of the
///   primitive's canonical mapping (§E.3.6). Its `explicitTimezone` facet,
///   the last one the definitions from the primitive down to it give
///   (`required` for `xsd:dateTimeStamp`, in `derived.nxsd`), decides which
///   lexical forms it takes.
/// - `xsd:dateTime` and the datatypes derived from it are Foundation's
///   `Date` too: `date`, the point in time of a value with a timezone
///   offset and `nil` for a local value, which has none; `date(assuming:)`,
///   which reads a local value in a time zone; and `init(_: Date)`.
/// - `xsd:anyURI` and the datatypes derived from it are Foundation's `URL`
///   too: `url` and `init(_: URL)`.
///
///     public init(lexicalForm: String) throws(DatatypeError) {
///         let value = try SevenPropertyModel.dateTimeLexicalMap(lexicalForm)
///         guard value.timezoneOffset != nil else { throw .illTyped }
///         self.value = value
///     }
struct TemporalEmitter {
    let definitions: DatatypeDefinitions

    /// The primitives whose value space is the seven-property model.
    static let sevenPropertyPrimitives = ["dateTime", "time", "date", "gYearMonth", "gYear", "gMonthDay", "gDay", "gMonth"]

    /// The Swift type of the value space of each primitive this emitter
    /// gives members to: the seven-property model, and for anyURI the
    /// character sequences of string (§3.3.17).
    static let valueSpaces: [String: String] = Dictionary(
        uniqueKeysWithValues: sevenPropertyPrimitives.map { ($0, "SevenPropertyModel") } + [("anyURI", "CharacterSequence")]
    )

    /// The members of `definition`, whose value space is that of
    /// `primitive`.
    func members(of definition: SimpleTypeDefinition, primitive: SimpleTypeDefinition) -> [DeclSyntax] {
        let chain = definitions.chain(to: definition).map(\.name)
        var members: [DeclSyntax] = []
        if Self.sevenPropertyPrimitives.contains(primitive.name) {
            members.append(lexicalInitializer(definition, primitive: primitive))
            members.append(canonicalLexicalForm(primitive))
        }
        if chain.contains("dateTime") {
            members += dateView(definition)
        }
        if chain.contains("anyURI") {
            members += urlView(definition)
        }
        return members
    }

    // MARK: - Lexical and canonical mappings

    /// The `explicitTimezone` facet of `definition`: the last its chain of
    /// definitions gives, `optional` when none does.
    func explicitTimezone(of definition: SimpleTypeDefinition) -> String {
        definitions.chain(to: definition).flatMap(\.facets).last { $0.name == "explicitTimezone" }?.value ?? "optional"
    }

    /// `init(lexicalForm:)`, by the primitive's lexical mapping, with the
    /// `explicitTimezone` facet's constraint.
    private func lexicalInitializer(_ definition: SimpleTypeDefinition, primitive: SimpleTypeDefinition) -> DeclSyntax {
        let timezone = explicitTimezone(of: definition)
        let mapping = primitive.name + "LexicalMap"
        let constraint: String? = switch timezone {
        case "required": "The `explicitTimezone` facet is `required`: a lexical form without a timezone is ill-typed."
        case "prohibited": "The `explicitTimezone` facet is `prohibited`: a lexical form with a timezone is ill-typed."
        default: nil
        }
        let comparison: TokenSyntax? = switch timezone {
        case "required": .binaryOperator("!=")
        case "prohibited": .binaryOperator("==")
        default: nil
        }
        return DeclSyntax(InitializerDeclSyntax(
            leadingTrivia: doc([
                "The value of xsd:\(definition.name) a lexical form denotes, by ·\(mapping)· (XML Schema 1.1 Part 2 §E.3.5).",
            ] + (constraint.map { ["", $0] } ?? []) + [
                "",
                "- Throws: ``DatatypeError/illTyped`` when the lexical form is not in the lexical space.",
            ]),
            modifiers: [DeclModifierSyntax(name: .keyword(.public))],
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax {
                    FunctionParameterSyntax(firstName: .identifier("lexicalForm"), type: IdentifierTypeSyntax(name: .identifier("String")))
                },
                effectSpecifiers: FunctionEffectSpecifiersSyntax(throwsClause: ThrowsClauseSyntax(
                    throwsSpecifier: .keyword(.throws),
                    leftParen: .leftParenToken(),
                    type: IdentifierTypeSyntax(name: .identifier("DatatypeError")),
                    rightParen: .rightParenToken()
                ))
            ),
            body: CodeBlockSyntax {
                VariableDeclSyntax(
                    bindingSpecifier: .keyword(.let),
                    bindings: [PatternBindingSyntax(
                        pattern: IdentifierPatternSyntax(identifier: .identifier("value")),
                        initializer: InitializerClauseSyntax(value: TryExprSyntax(expression: call(
                            member(reference("SevenPropertyModel"), mapping),
                            [(nil, reference("lexicalForm"))]
                        )))
                    )]
                )
                if let comparison {
                    GuardStmtSyntax(
                        conditions: [ConditionElementSyntax(condition: .expression(ExprSyntax(InfixOperatorExprSyntax(
                            leftOperand: member(reference("value"), "timezoneOffset"),
                            operator: BinaryOperatorExprSyntax(operator: comparison),
                            rightOperand: NilLiteralExprSyntax()
                        ))))],
                        body: CodeBlockSyntax {
                            ThrowStmtSyntax(expression: MemberAccessExprSyntax(declName: DeclReferenceExprSyntax(baseName: .identifier("illTyped"))))
                        }
                    )
                }
                assignValue(reference("value"))
            }
        ))
    }

    /// `canonicalLexicalForm`, by the primitive's canonical mapping.
    private func canonicalLexicalForm(_ primitive: SimpleTypeDefinition) -> DeclSyntax {
        let mapping = primitive.name + "CanonicalMap"
        return computedProperty(
            "canonicalLexicalForm",
            type: IdentifierTypeSyntax(name: .identifier("String")),
            doc: ["The canonical lexical form of the value, by ·\(mapping)· (XML Schema 1.1 Part 2 §E.3.6)."],
            body: call(member(reference("SevenPropertyModel"), mapping), [(nil, reference("value"))])
        )
    }

    // MARK: - Foundation views

    /// `date`, `date(assuming:)` and `init(_: Date)`.
    private func dateView(_ definition: SimpleTypeDefinition) -> [DeclSyntax] {
        let date = IdentifierTypeSyntax(name: .identifier("Date"))
        return [
            computedProperty(
                "date",
                type: OptionalTypeSyntax(wrappedType: date),
                doc: [
                    "The point in time the value is, when it has a timezone offset.",
                    "",
                    "A value without one is a local time (§3.3.7), at no single point in time, and has no date: `date(assuming:)` reads it in a time zone.",
                ],
                body: member(reference("value"), "date")
            ),
            DeclSyntax(FunctionDeclSyntax(
                leadingTrivia: doc([
                    "The point in time the value is, its local time read in `timeZone` when it has no timezone offset of its own.",
                ]),
                modifiers: [DeclModifierSyntax(name: .keyword(.public))],
                name: .identifier("date"),
                signature: FunctionSignatureSyntax(
                    parameterClause: FunctionParameterClauseSyntax {
                        FunctionParameterSyntax(firstName: .identifier("assuming"), secondName: .identifier("timeZone"), type: IdentifierTypeSyntax(name: .identifier("TimeZone")))
                    },
                    returnClause: ReturnClauseSyntax(type: date)
                ),
                body: CodeBlockSyntax {
                    call(member(reference("value"), "date"), [("assuming", reference("timeZone"))])
                }
            )),
            initializer(
                parameter: "date",
                type: date,
                doc: ["The value of xsd:\(definition.name) that is `date`, in UTC (`Z`), to the microsecond."],
                value: call(reference("SevenPropertyModel"), [(nil, reference("date"))])
            ),
        ]
    }

    /// `url` and `init(_: URL)`.
    private func urlView(_ definition: SimpleTypeDefinition) -> [DeclSyntax] {
        let url = IdentifierTypeSyntax(name: .identifier("URL"))
        return [
            computedProperty(
                "url",
                type: OptionalTypeSyntax(wrappedType: url),
                doc: ["The value as a URL, `nil` when Foundation reads no URL in its characters."],
                body: call(reference("URL"), [("string", member(reference("value"), "text"))])
            ),
            initializer(
                parameter: "url",
                type: url,
                doc: ["The value of xsd:\(definition.name) that is the characters of `url`."],
                value: call(reference("CharacterSequence"), [(nil, member(reference("url"), "absoluteString"))])
            ),
        ]
    }

    // MARK: - Syntax

    private func reference(_ name: String) -> ExprSyntax {
        ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(name)))
    }

    private func member(_ base: ExprSyntax, _ name: String) -> ExprSyntax {
        ExprSyntax(MemberAccessExprSyntax(base: base, name: .identifier(name)))
    }

    private func call(_ callee: ExprSyntax, _ arguments: [(label: String?, value: ExprSyntax)]) -> ExprSyntax {
        ExprSyntax(FunctionCallExprSyntax(
            calledExpression: callee,
            leftParen: .leftParenToken(),
            arguments: LabeledExprListSyntax {
                for argument in arguments {
                    LabeledExprSyntax(
                        label: argument.label.map { .identifier($0) },
                        colon: argument.label.map { _ in .colonToken() },
                        expression: argument.value
                    )
                }
            },
            rightParen: .rightParenToken()
        ))
    }

    /// `self.value = value`.
    private func assignValue(_ value: ExprSyntax) -> InfixOperatorExprSyntax {
        InfixOperatorExprSyntax(
            leftOperand: MemberAccessExprSyntax(base: DeclReferenceExprSyntax(baseName: .keyword(.self)), name: .identifier("value")),
            operator: AssignmentExprSyntax(),
            rightOperand: value
        )
    }

    private func computedProperty(_ name: String, type: some TypeSyntaxProtocol, doc lines: [String], body: ExprSyntax) -> DeclSyntax {
        DeclSyntax(VariableDeclSyntax(
            leadingTrivia: doc(lines),
            modifiers: [DeclModifierSyntax(name: .keyword(.public))],
            bindingSpecifier: .keyword(.var),
            bindings: [PatternBindingSyntax(
                pattern: IdentifierPatternSyntax(identifier: .identifier(name)),
                typeAnnotation: TypeAnnotationSyntax(type: type),
                accessorBlock: AccessorBlockSyntax(accessors: .getter(CodeBlockItemListSyntax {
                    body
                }))
            )]
        ))
    }

    /// `public init(_ parameter: Type) { self.value = value }`.
    private func initializer(parameter: String, type: some TypeSyntaxProtocol, doc lines: [String], value: ExprSyntax) -> DeclSyntax {
        DeclSyntax(InitializerDeclSyntax(
            leadingTrivia: doc(lines),
            modifiers: [DeclModifierSyntax(name: .keyword(.public))],
            signature: FunctionSignatureSyntax(parameterClause: FunctionParameterClauseSyntax {
                FunctionParameterSyntax(firstName: .wildcardToken(), secondName: .identifier(parameter), type: type)
            }),
            body: CodeBlockSyntax {
                assignValue(value)
            }
        ))
    }

    private func doc(_ lines: [String]) -> Trivia {
        Trivia(pieces: lines.flatMap { [TriviaPiece.docLineComment($0.isEmpty ? "///" : "/// \($0)"), .newlines(1)] })
    }
}
