import SwiftParser
import SwiftSyntax
import SwiftSyntaxBuilder

// The shapes the translated Swift repeats, built from SwiftSyntax's typed
// nodes: names with module selectors, member access, calls, `.self`, `any`,
// arrays, accessors and declarations laid out a member to a line.

extension TokenSyntax {
    /// The identifier of a name RDF gives, in backticks when Swift requires
    /// them: a keyword, or a name Swift's identifier grammar does not allow,
    /// which is then a raw identifier (SE-0451), `` `resource 3` ``.
    static func swift(_ name: String) -> TokenSyntax {
        .identifier(name.isValidSwiftIdentifier(for: .variableName) && !reservedTypeMembers.contains(name) ? name : "`" + name + "`")
    }

    /// Names that are identifiers but mean something else after a type and
    /// a dot: `RDF::Resource.Type` is a metatype.
    private static let reservedTypeMembers: Set<String> = ["Type", "Protocol", "Self", "self", "init"]
}

extension SwiftReference {
    /// The module selector of a public declaration: `RDF::`.
    private var moduleSelector: ModuleSelectorSyntax? {
        module.map { ModuleSelectorSyntax(moduleName: .swift($0)) }
    }

    /// The declaration as a type: `RDF::Property`.
    var type: TypeSyntax {
        TypeSyntax(IdentifierTypeSyntax(moduleSelector: moduleSelector, name: .swift(name)))
    }

    /// The declaration as an expression: `RDF::nil`, `RDF::type.self`.
    var expression: ExprSyntax {
        ExprSyntax(DeclReferenceExprSyntax(moduleSelector: moduleSelector, baseName: .swift(name)))
    }

    /// A declaration of RDFCore, the runtime: `RDFCore::Literal`.
    static func rdfCore(_ name: String) -> SwiftReference {
        SwiftReference(module: "RDFCore", name: name)
    }

    /// A declaration of the standard library: `Swift::Encoder`.
    static func swift(_ name: String) -> SwiftReference {
        SwiftReference(module: "Swift", name: name)
    }

    /// A declaration of this module, named without a module selector.
    static func local(_ name: String) -> SwiftReference {
        SwiftReference(module: nil, name: name)
    }
}

extension ExprSyntaxProtocol {
    /// `self.name`.
    func member(_ name: String) -> ExprSyntax {
        member(.swift(name))
    }

    /// `self.name`, for a name given as a token, such as `.keyword(.self)`.
    func member(_ name: TokenSyntax) -> ExprSyntax {
        ExprSyntax(MemberAccessExprSyntax(base: self, declName: DeclReferenceExprSyntax(baseName: name)))
    }

    /// `Type.self`.
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

    /// `try! self`.
    var forceTried: ExprSyntax {
        ExprSyntax(TryExprSyntax(questionOrExclamationMark: .exclamationMarkToken(), expression: self))
    }

    /// `self as type`.
    func `as`(_ type: TypeSyntax) -> ExprSyntax {
        ExprSyntax(AsExprSyntax(expression: self, type: type))
    }

    /// `self = value`.
    func assigned(_ value: some ExprSyntaxProtocol) -> ExprSyntax {
        ExprSyntax(InfixOperatorExprSyntax(leftOperand: self, operator: AssignmentExprSyntax(), rightOperand: value))
    }

    /// `self()`: a call of the closure this expression is, at once.
    var called: ExprSyntax {
        call([])
    }
}

extension ExprSyntax {
    /// A declaration of this module by name: `container`, `` `resource 3` ``.
    static func named(_ name: String) -> ExprSyntax {
        ExprSyntax(DeclReferenceExprSyntax(baseName: .swift(name)))
    }

    /// `Self`, `self`.
    static func keyword(_ keyword: Keyword) -> ExprSyntax {
        ExprSyntax(DeclReferenceExprSyntax(baseName: .keyword(keyword)))
    }

    /// `.name`: a member of the type the context gives, `.class`.
    static func implicitMember(_ name: String) -> ExprSyntax {
        ExprSyntax(MemberAccessExprSyntax(declName: DeclReferenceExprSyntax(baseName: .identifier(name))))
    }

    /// A string literal of the text, escaped or raw as its text needs.
    static func string(_ text: String) -> ExprSyntax {
        ExprSyntax(StringLiteralExprSyntax(content: text))
    }

    /// `nil`.
    static var `nil`: ExprSyntax {
        ExprSyntax(NilLiteralExprSyntax())
    }

    /// `_`, the left side of an assignment that discards its value.
    static var discard: ExprSyntax {
        ExprSyntax(DiscardAssignmentExprSyntax())
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

    /// A type used as an expression: `[RDFCore::Literal]` in `[RDFCore::Literal].self`.
    static func type(_ type: TypeSyntax) -> ExprSyntax {
        ExprSyntax(TypeExprSyntax(type: type))
    }

    /// `{ statements }`: a closure of the statements, one to a line.
    static func closure(_ statements: [CodeBlockItemSyntax.Item]) -> ExprSyntax {
        ExprSyntax(ClosureExprSyntax(statements: CodeBlockItemListSyntax(statements.map { CodeBlockItemSyntax(item: $0) })))
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

    /// `A & B`, or the one type when there is one.
    static func composition(_ types: [TypeSyntax]) -> TypeSyntax {
        guard types.count > 1 else { return types[0] }
        return TypeSyntax(CompositionTypeSyntax(elements: CompositionTypeElementListSyntax(types.enumerated().map { index, type in
            CompositionTypeElementSyntax(type: type, ampersand: index < types.count - 1 ? .binaryOperator("&") : nil)
        })))
    }

    /// `(type)`.
    static func parenthesized(_ type: TypeSyntax) -> TypeSyntax {
        TypeSyntax(TupleTypeSyntax(elements: TupleTypeElementListSyntax([TupleTypeElementSyntax(type: type)])))
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
    /// `public`, or `private` for a declaration other modules do not see.
    static func access(_ isPublic: Bool) -> DeclModifierListSyntax {
        [DeclModifierSyntax(name: .keyword(isPublic ? .public : .private))]
    }

    /// `public`.
    static var `public`: DeclModifierListSyntax { access(true) }

    /// `public static`.
    static var publicStatic: DeclModifierListSyntax {
        [DeclModifierSyntax(name: .keyword(.public)), DeclModifierSyntax(name: .keyword(.static))]
    }

    /// The modifiers with `final` after them.
    var final: DeclModifierListSyntax {
        self + [DeclModifierSyntax(name: .keyword(.final))]
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
    init(_ parameters: [(label: String, name: String, type: TypeSyntax)]) {
        self.init(parameters: FunctionParameterListSyntax(parameters.enumerated().map { index, parameter in
            FunctionParameterSyntax(
                firstName: .identifier(parameter.label),
                secondName: .identifier(parameter.name),
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

extension AttributeListSyntax {
    /// `@available(*, deprecated)`, on a line of its own.
    static var deprecated: AttributeListSyntax {
        [.attribute(AttributeSyntax(
            attributeName: IdentifierTypeSyntax(name: .identifier("available")),
            leftParen: .leftParenToken(),
            arguments: .availability(AvailabilityArgumentListSyntax([
                AvailabilityArgumentSyntax(argument: .token(.binaryOperator("*")), trailingComma: .commaToken()),
                AvailabilityArgumentSyntax(argument: .token(.keyword(.deprecated))),
            ])),
            rightParen: .rightParenToken(),
            trailingTrivia: .newline
        ))]
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
