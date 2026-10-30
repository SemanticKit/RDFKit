import SwiftSyntax
import SwiftSyntaxBuilder

// The few shapes the generated Swift repeats, built from SwiftSyntax's typed
// nodes: member access, calls, `.self`, `any`, arrays, accessors and member
// lists laid out as the generated declarations are.

extension ExprSyntaxProtocol {
    /// `self.name`: a member of this expression.
    func member(_ name: String) -> ExprSyntax {
        member(.declared(name))
    }

    /// `self.name`, for a name given as a token, such as `.keyword(.self)`.
    func member(_ name: TokenSyntax) -> ExprSyntax {
        ExprSyntax(MemberAccessExprSyntax(base: self, declName: DeclReferenceExprSyntax(baseName: name)))
    }

    /// `Type.self`: the metatype of the type this expression names.
    var dotSelf: ExprSyntax {
        member(.keyword(.self))
    }

    /// `self(arguments)`.
    func call(_ arguments: LabeledExprSyntax...) -> ExprSyntax {
        call(arguments)
    }

    /// `self(arguments)`.
    func call(_ arguments: [LabeledExprSyntax]) -> ExprSyntax {
        ExprSyntax(FunctionCallExprSyntax(
            calledExpression: self,
            leftParen: .leftParenToken(),
            arguments: LabeledExprListSyntax(separating: arguments),
            rightParen: .rightParenToken()
        ))
    }

    /// `self[argument]`.
    func subscripted(_ argument: some ExprSyntaxProtocol) -> ExprSyntax {
        ExprSyntax(SubscriptCallExprSyntax(
            calledExpression: self,
            arguments: LabeledExprListSyntax([LabeledExprSyntax(expression: argument)])
        ))
    }

    /// `try self`.
    var tried: ExprSyntax {
        ExprSyntax(TryExprSyntax(expression: self))
    }

    /// `self as type`.
    func `as`(_ type: some TypeSyntaxProtocol) -> ExprSyntax {
        ExprSyntax(AsExprSyntax(expression: self, type: type))
    }

    /// `self = value`.
    func assigned(_ value: some ExprSyntaxProtocol) -> ExprSyntax {
        ExprSyntax(InfixOperatorExprSyntax(leftOperand: self, operator: AssignmentExprSyntax(), rightOperand: value))
    }

    /// `self + other`.
    func plus(_ other: some ExprSyntaxProtocol) -> ExprSyntax {
        ExprSyntax(InfixOperatorExprSyntax(leftOperand: self, operator: BinaryOperatorExprSyntax(text: "+"), rightOperand: other))
    }
}

extension ExprSyntax {
    /// A reference to a declaration by name: `container`, `newValue`.
    static func named(_ name: String) -> ExprSyntax {
        ExprSyntax(DeclReferenceExprSyntax(baseName: .declared(name)))
    }

    /// A reference by a keyword: `Self`, `self`.
    static func keyword(_ keyword: Keyword) -> ExprSyntax {
        ExprSyntax(DeclReferenceExprSyntax(baseName: .keyword(keyword)))
    }

    /// A string literal of the text, escaped or raw as its text needs.
    static func string(_ text: String) -> ExprSyntax {
        ExprSyntax(StringLiteralExprSyntax(content: text))
    }

    /// `[elements]`, on one line.
    static func array(_ elements: [ExprSyntax]) -> ExprSyntax {
        ExprSyntax(ArrayExprSyntax(expressions: elements))
    }

    /// `[elements]`, one element to a line, each with a trailing comma.
    static func list(_ elements: [ExprSyntax]) -> ExprSyntax {
        guard !elements.isEmpty else { return array([]) }
        return ExprSyntax(ArrayExprSyntax(
            elements: ArrayElementListSyntax(elements.map { element in
                ArrayElementSyntax(leadingTrivia: .newline, expression: element, trailingComma: .commaToken())
            }),
            rightSquare: .rightSquareToken(leadingTrivia: .newline)
        ))
    }

    /// A type used as an expression: `[any Fauna.Animal]` in `[any Fauna.Animal].self`.
    static func type(_ type: some TypeSyntaxProtocol) -> ExprSyntax {
        ExprSyntax(TypeExprSyntax(type: type))
    }
}

extension LabeledExprListSyntax {
    /// The arguments, separated by commas.
    init(separating arguments: [LabeledExprSyntax]) {
        self.init(arguments.enumerated().map { index, argument in
            index < arguments.count - 1 ? argument.with(\.trailingComma, .commaToken()) : argument
        })
    }
}

extension LabeledExprSyntax {
    /// An argument with a label: `for: key`.
    init(_ label: String, _ expression: some ExprSyntaxProtocol) {
        self.init(label: label, expression: expression)
    }
}

extension TypeSyntax {
    /// `any constraint`.
    static func any(_ constraint: TypeSyntax) -> TypeSyntax {
        TypeSyntax(SomeOrAnyTypeSyntax(someOrAnySpecifier: .keyword(.any), constraint: constraint))
    }

    /// `[element]`.
    static func array(_ element: TypeSyntax) -> TypeSyntax {
        TypeSyntax(ArrayTypeSyntax(element: element))
    }

    /// `base.Type`.
    static func metatype(_ base: TypeSyntax) -> TypeSyntax {
        TypeSyntax(MetatypeTypeSyntax(baseType: base, metatypeSpecifier: .keyword(.Type)))
    }

    /// `(A & B)`.
    static func composition(_ types: [TypeSyntax]) -> TypeSyntax {
        let composition = CompositionTypeSyntax(elements: CompositionTypeElementListSyntax(types.enumerated().map { index, type in
            CompositionTypeElementSyntax(type: type, ampersand: index < types.count - 1 ? .binaryOperator("&") : nil)
        }))
        return TypeSyntax(TupleTypeSyntax(elements: TupleTypeElementListSyntax([TupleTypeElementSyntax(type: composition)])))
    }
}

extension InheritanceClauseSyntax {
    /// `: A, B`.
    init(_ types: [TypeSyntax]) {
        self.init(inheritedTypes: InheritedTypeListSyntax(types.enumerated().map { index, type in
            InheritedTypeSyntax(type: type, trailingComma: index < types.count - 1 ? .commaToken() : nil)
        }))
    }
}

extension DeclModifierListSyntax {
    /// The modifiers for an access level spelled `public ` or `package `,
    /// or none for an empty spelling.
    init(access: String) {
        switch access.trimmingCharacters(in: .whitespaces) {
        case "public": self = [DeclModifierSyntax(name: .keyword(.public))]
        case "package": self = [DeclModifierSyntax(name: .keyword(.package))]
        default: self = []
        }
    }

    /// The modifiers with `static` after them.
    var andStatic: DeclModifierListSyntax {
        self + [DeclModifierSyntax(name: .keyword(.static))]
    }
}

extension MemberBlockSyntax {
    /// A member block whose members are separated by a blank line.
    init(spaced members: [DeclSyntax]) {
        self.init(members: MemberBlockItemListSyntax(members.enumerated().map { index, member in
            MemberBlockItemSyntax(decl: index == 0 ? member : member.with(\.leadingTrivia, .newlines(2) + member.leadingTrivia))
        }))
    }

    /// A member block whose members follow each other line by line.
    init(_ members: [DeclSyntax]) {
        self.init(members: MemberBlockItemListSyntax(members.map { MemberBlockItemSyntax(decl: $0) }))
    }
}

extension CodeBlockSyntax {
    /// A block of the statements, one to a line.
    init(_ statements: [CodeBlockItemSyntax.Item]) {
        self.init(statements: CodeBlockItemListSyntax(statements.map { CodeBlockItemSyntax(item: $0) }))
    }
}

extension AccessorBlockSyntax {
    /// `{ get set }`: a protocol's requirement of a settable property.
    static var getSet: AccessorBlockSyntax {
        AccessorBlockSyntax(accessors: .accessors(AccessorDeclListSyntax([
            AccessorDeclSyntax(accessorSpecifier: .keyword(.get)),
            AccessorDeclSyntax(accessorSpecifier: .keyword(.set)),
        ])))
    }

    /// A getter with one expression: `{ value }`.
    static func getter(_ expression: some ExprSyntaxProtocol) -> AccessorBlockSyntax {
        AccessorBlockSyntax(accessors: .getter(CodeBlockItemListSyntax([CodeBlockItemSyntax(item: .expr(ExprSyntax(expression)))])))
    }
}

extension VariableDeclSyntax {
    /// `modifiers let/var name: type = value` or `{ accessors }`.
    init(
        leadingTrivia: Trivia = [],
        attributes: AttributeListSyntax = [],
        modifiers: DeclModifierListSyntax = [],
        _ specifier: Keyword,
        _ name: TokenSyntax,
        type: TypeSyntax? = nil,
        value: ExprSyntax? = nil,
        accessors: AccessorBlockSyntax? = nil
    ) {
        self.init(
            leadingTrivia: leadingTrivia,
            attributes: attributes,
            modifiers: modifiers,
            bindingSpecifier: .keyword(specifier),
            bindings: PatternBindingListSyntax([PatternBindingSyntax(
                pattern: IdentifierPatternSyntax(identifier: name),
                typeAnnotation: type.map { TypeAnnotationSyntax(type: $0) },
                initializer: value.map { InitializerClauseSyntax(value: $0) },
                accessorBlock: accessors
            )])
        )
    }
}

extension FunctionParameterClauseSyntax {
    /// `(label name: type)`, or `()` for no parameter.
    init(_ parameters: [(label: String, name: String?, type: TypeSyntax)]) {
        self.init(parameters: FunctionParameterListSyntax(parameters.enumerated().map { index, parameter in
            FunctionParameterSyntax(
                firstName: .identifier(parameter.label),
                secondName: parameter.name.map { .identifier($0) },
                type: parameter.type,
                trailingComma: index < parameters.count - 1 ? .commaToken() : nil
            )
        }))
    }
}

extension FunctionEffectSpecifiersSyntax {
    /// `throws`.
    static var throwing: FunctionEffectSpecifiersSyntax {
        FunctionEffectSpecifiersSyntax(throwsClause: ThrowsClauseSyntax(throwsSpecifier: .keyword(.throws)))
    }
}

extension Trivia {
    /// `///` documentation comment lines, each ending a line.
    static func documentation(_ lines: [String]) -> Trivia {
        Trivia(pieces: lines.flatMap { line -> [TriviaPiece] in
            [.docLineComment(line.isEmpty ? "///" : "/// " + line), .newlines(1)]
        })
    }
}
