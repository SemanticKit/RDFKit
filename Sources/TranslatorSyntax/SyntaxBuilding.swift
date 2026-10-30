import SwiftSyntax
import SwiftSyntaxBuilder

// The nodes the translators build the Swift they generate from, through
// swift-syntax's typed API (DESIGN-CONTRACT rule 16): names, types and
// expressions as syntax nodes, never as Swift source text.

extension TokenSyntax {
    /// The name `name` as an identifier, in backticks, so a datatype named
    /// like a Swift keyword or standard type (`string`, `int`) is its own.
    public static func escaped(_ name: String) -> TokenSyntax {
        .identifier("`" + name + "`")
    }
}

extension TypeSyntax {
    /// The type `name`, from `module` when given (SE-0491 module selector,
    /// `XSD::SimpleType`).
    public static func named(_ name: TokenSyntax, in module: String? = nil) -> TypeSyntax {
        TypeSyntax(IdentifierTypeSyntax(
            moduleSelector: module.map { ModuleSelectorSyntax(moduleName: .identifier($0)) },
            name: name
        ))
    }

    /// The member type `name` of `base`: `decimal.Value`.
    public static func member(_ name: String, of base: TypeSyntax) -> TypeSyntax {
        TypeSyntax(MemberTypeSyntax(baseType: base, name: .identifier(name)))
    }

    /// `Wrapped?`.
    public static func optional(_ wrapped: TypeSyntax) -> TypeSyntax {
        TypeSyntax(OptionalTypeSyntax(wrappedType: wrapped))
    }

    /// `[Element]`.
    public static func array(of element: TypeSyntax) -> TypeSyntax {
        TypeSyntax(ArrayTypeSyntax(element: element))
    }

    /// `any Constraint`.
    public static func existential(_ constraint: TypeSyntax) -> TypeSyntax {
        TypeSyntax(SomeOrAnyTypeSyntax(someOrAnySpecifier: .keyword(.any), constraint: constraint))
    }

    /// A tuple type of labeled elements, `(value: V, literalForm: F)`.
    public static func tuple(_ elements: [(label: String, type: TypeSyntax)]) -> TypeSyntax {
        TypeSyntax(TupleTypeSyntax(elements: TupleTypeElementListSyntax(commaSeparated(elements.map { element in
            TupleTypeElementSyntax(firstName: .identifier(element.label), colon: .colonToken(), type: element.type)
        }))))
    }
}

extension ExprSyntax {
    /// A reference to `name`, from `module` when given.
    public static func reference(_ name: TokenSyntax, in module: String? = nil) -> ExprSyntax {
        ExprSyntax(DeclReferenceExprSyntax(
            moduleSelector: module.map { ModuleSelectorSyntax(moduleName: .identifier($0)) },
            baseName: name
        ))
    }

    /// `Self`.
    public static var selfType: ExprSyntax { reference(.keyword(.Self)) }

    /// `self`.
    public static var selfValue: ExprSyntax { reference(.keyword(.self)) }

    /// `base.name`, or the implicit member `.name` without a base.
    public static func member(_ name: TokenSyntax, of base: ExprSyntax?) -> ExprSyntax {
        ExprSyntax(MemberAccessExprSyntax(base: base, name: name))
    }

    /// `callee(label: argument, ...)`.
    public static func call(_ callee: ExprSyntax, _ arguments: [(label: String?, value: ExprSyntax)] = []) -> ExprSyntax {
        ExprSyntax(FunctionCallExprSyntax(
            calledExpression: callee,
            leftParen: .leftParenToken(),
            arguments: LabeledExprListSyntax(commaSeparated(arguments.map { LabeledExprSyntax(label: $0.label, expression: $0.value) })),
            rightParen: .rightParenToken()
        ))
    }

    /// A string literal of `text`, escaped as the literal needs.
    public static func string(_ text: String) -> ExprSyntax {
        ExprSyntax(StringLiteralExprSyntax(content: text))
    }

    /// `[element, ...]`.
    public static func array(_ elements: [ExprSyntax]) -> ExprSyntax {
        ExprSyntax(ArrayExprSyntax(elements: ArrayElementListSyntax(commaSeparated(elements.map { ArrayElementSyntax(expression: $0) }))))
    }

    /// `try expression`, or `try?` when `optional`.
    public static func `try`(_ expression: ExprSyntax, optional: Bool = false) -> ExprSyntax {
        ExprSyntax(TryExprSyntax(questionOrExclamationMark: optional ? .postfixQuestionMarkToken() : nil, expression: expression))
    }

    /// `left ?? right`.
    public static func coalescing(_ left: ExprSyntax, _ right: ExprSyntax) -> ExprSyntax {
        ExprSyntax(InfixOperatorExprSyntax(
            leftOperand: left,
            operator: BinaryOperatorExprSyntax(operator: .binaryOperator("??")),
            rightOperand: right
        ))
    }

    /// `target = value`.
    public static func assignment(_ target: ExprSyntax, _ value: ExprSyntax) -> ExprSyntax {
        ExprSyntax(InfixOperatorExprSyntax(leftOperand: target, operator: AssignmentExprSyntax(), rightOperand: value))
    }
}

extension Trivia {
    /// DocC documentation: a doc line comment for each line, the empty
    /// lines `///`.
    public static func documentation(_ lines: [String]) -> Trivia {
        Trivia(pieces: lines.flatMap { line -> [TriviaPiece] in
            [.docLineComment(line.isEmpty ? "///" : "/// " + line), .newlines(1)]
        })
    }
}

extension DeclModifierListSyntax {
    /// The modifiers `keywords`, in order.
    public static func of(_ keywords: Keyword...) -> DeclModifierListSyntax {
        DeclModifierListSyntax(keywords.map { DeclModifierSyntax(name: .keyword($0)) })
    }
}

extension InheritanceClauseSyntax {
    /// `: Type, ...`.
    public static func of(_ types: TypeSyntax...) -> InheritanceClauseSyntax {
        InheritanceClauseSyntax(inheritedTypes: InheritedTypeListSyntax(commaSeparated(types.map { InheritedTypeSyntax(type: $0) })))
    }
}

extension CodeBlockSyntax {
    /// A body of these statements and expressions.
    public static func of(_ items: [CodeBlockItemSyntax.Item]) -> CodeBlockSyntax {
        CodeBlockSyntax(statements: CodeBlockItemListSyntax(items.map { CodeBlockItemSyntax(item: $0) }))
    }
}

extension FunctionEffectSpecifiersSyntax {
    /// `throws`, or `throws(Error)` with a thrown type.
    public static func throwing(_ error: TypeSyntax? = nil) -> FunctionEffectSpecifiersSyntax {
        FunctionEffectSpecifiersSyntax(throwsClause: ThrowsClauseSyntax(
            throwsSpecifier: .keyword(.throws),
            leftParen: error == nil ? nil : .leftParenToken(),
            type: error,
            rightParen: error == nil ? nil : .rightParenToken()
        ))
    }
}

extension FunctionParameterClauseSyntax {
    /// `(label name: Type, ...)`; a parameter with no label is `_ name`.
    public static func of(_ parameters: [(label: String?, name: String, type: TypeSyntax)]) -> FunctionParameterClauseSyntax {
        FunctionParameterClauseSyntax(parameters: FunctionParameterListSyntax(commaSeparated(parameters.map { parameter in
            if let label = parameter.label, label == parameter.name {
                return FunctionParameterSyntax(firstName: .identifier(label), colon: .colonToken(), type: parameter.type)
            }
            return FunctionParameterSyntax(
                firstName: parameter.label.map { .identifier($0) } ?? .wildcardToken(),
                secondName: .identifier(parameter.name),
                colon: .colonToken(),
                type: parameter.type
            )
        })))
    }
}

/// `elements`, each but the last followed by a comma.
public func commaSeparated<Element: WithTrailingCommaSyntax>(_ elements: [Element]) -> [Element] {
    elements.enumerated().map { index, element in
        index < elements.count - 1 ? element.with(\.trailingComma, .commaToken()) : element
    }
}
