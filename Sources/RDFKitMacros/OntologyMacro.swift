import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Entry point for the `@Ontology` macro.
///
/// Reads the ontology's DSL content from its `var body` and generates one
/// Swift type per declared term, nested inside the ontology. See
/// ``EntityGenerator`` for what each declaration becomes. It also attaches
/// ``OntologyContentMacro`` to `var body`, which turns the authored body
/// into content built from those types.
public struct OntologyMacro: MemberMacro, MemberAttributeMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        if let function = OntologyParser.contentFunction(in: declaration) {
            context.diagnose(contentFunctionDiagnostic(function))
            return []
        }
        let ontology = try OntologyParser.parse(declaration: declaration)
        if let statements = OntologyParser.bodyProperty(in: declaration).flatMap(OntologyParser.bodyStatements(of:)) {
            let spellings = UnusedSpellingVisitor()
            spellings.walk(statements)
            spellings.diagnostics.forEach(context.diagnose)
        }
        return EntityGenerator(ontology: ontology, context: context).members()
    }

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        guard let variable = member.as(VariableDeclSyntax.self),
              OntologyParser.isBodyProperty(variable),
              !variable.attributes.contains(where: { $0.as(AttributeSyntax.self)?.attributeName.trimmedDescription == "OntologyContent" })
        else { return [] }
        // A body macro on a computed property is given a getter built from
        // the property's statements, outside the authored file, so it cannot
        // look up where they were written. Pass it the file and line of the
        // opening brace instead.
        if let brace = variable.bindings.first?.accessorBlock?.leftBrace,
           let location = context.location(of: brace, at: .afterLeadingTrivia, filePathMode: .filePath),
           let file = location.file.as(StringLiteralExprSyntax.self),
           let line = location.line.as(IntegerLiteralExprSyntax.self) {
            return [AttributeSyntax(
                attributeName: IdentifierTypeSyntax(name: .identifier("OntologyContent")),
                leftParen: .leftParenToken(),
                arguments: .argumentList(LabeledExprListSyntax(separating: [
                    LabeledExprSyntax("file", file.trimmed),
                    LabeledExprSyntax("line", line.trimmed),
                ])),
                rightParen: .rightParenToken()
            )]
        }
        return [AttributeSyntax(attributeName: IdentifierTypeSyntax(name: .identifier("OntologyContent")))]
    }

    /// The error for a `content()` function, with a fix-it that writes
    /// the same body as `var body: some Content`.
    static func contentFunctionDiagnostic(_ function: FunctionDeclSyntax) -> Diagnostic {
        let body = function.body?.trimmed ?? CodeBlockSyntax(statements: [])
        // The function's attributes and modifiers, each followed by a
        // space, then `var body: some Content` and the function's body.
        let replacement = VariableDeclSyntax(
            attributes: AttributeListSyntax(function.attributes.map { $0.trimmed.with(\.trailingTrivia, .space) }),
            modifiers: DeclModifierListSyntax(function.modifiers.map { $0.trimmed.with(\.trailingTrivia, .space) }),
            bindingSpecifier: .keyword(.var, trailingTrivia: .space),
            bindings: PatternBindingListSyntax([PatternBindingSyntax(
                pattern: IdentifierPatternSyntax(identifier: .identifier("body")),
                typeAnnotation: TypeAnnotationSyntax(
                    colon: .colonToken(trailingTrivia: .space),
                    type: SomeOrAnyTypeSyntax(
                        someOrAnySpecifier: .keyword(.some, trailingTrivia: .space),
                        constraint: IdentifierTypeSyntax(name: .identifier("Content", trailingTrivia: .space))
                    )
                ),
                accessorBlock: AccessorBlockSyntax(leftBrace: body.leftBrace, accessors: .getter(body.statements), rightBrace: body.rightBrace)
            )])
        )
        return Diagnostic(
            node: function.name,
            message: OntologyDiagnostic.writeContentInBody,
            fixIt: FixIt(
                message: OntologyFixIt(message: "Write 'var body: some Content'", id: "contentInBody"),
                changes: [.replace(
                    oldNode: Syntax(function),
                    newNode: Syntax(replacement.with(\.leadingTrivia, function.leadingTrivia).with(\.trailingTrivia, function.trailingTrivia))
                )]
            )
        )
    }
}
