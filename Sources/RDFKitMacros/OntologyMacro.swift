import SwiftDiagnostics
import SwiftSyntax
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
        if declaration.is(StructDeclSyntax.self), OntologyParser.bodyProperty(in: declaration) == nil {
            context.diagnose(missingBodyDiagnostic(declaration))
            return []
        }
        let ontology = try OntologyParser.parse(declaration: declaration)
        diagnoseUnusedSpellings(in: declaration, context: context)
        return EntityGenerator.generate(ontology: ontology, in: context)
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
            return ["@OntologyContent(file: \(file), line: \(line))"]
        }
        return ["@OntologyContent"]
    }

    /// Reports the spellings of a term annotation the DSL does not use,
    /// `Domain<Fauna.Animal>()` and `Domain(Fauna.Animal.self)`, at the
    /// authored call, with a fix-it. They are reported here, where the
    /// authored `var body` is in its file, and not by the body macro.
    static func diagnoseUnusedSpellings(in declaration: some DeclGroupSyntax, context: some MacroExpansionContext) {
        guard let statements = OntologyParser.bodyProperty(in: declaration).flatMap(OntologyParser.bodyStatements(of:)) else { return }
        let rewriter = ContentRewriter(declaredNames: OntologyParser.declaredNames(in: statements))
        _ = rewriter.rewrite(statements)
        for diagnostic in rewriter.diagnostics {
            context.diagnose(diagnostic)
        }
    }

    /// The error for a `content()` function, with a fix-it that writes the
    /// same body as `var body: some Content`.
    static func contentFunctionDiagnostic(_ function: FunctionDeclSyntax) -> Diagnostic {
        let attributes = function.attributes.map { $0.trimmedDescription + " " }.joined()
        let modifiers = function.modifiers.map { $0.trimmedDescription + " " }.joined()
        let body = function.body?.trimmedDescription ?? "{}"
        let replacement: DeclSyntax = "\(raw: attributes)\(raw: modifiers)var body: some Content \(raw: body)"
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

    /// The error for an ontology with no `var body`, with a fix-it that adds
    /// an empty `var body: some Content` to write the content in.
    static func missingBodyDiagnostic(_ declaration: some DeclGroupSyntax) -> Diagnostic {
        let members = declaration.memberBlock.members
        let member = MemberBlockItemSyntax(decl: DeclSyntax("\n    var body: some Content {\n    }"))
        let name = declaration.as(StructDeclSyntax.self)?.name
        return Diagnostic(
            node: name.map(Syntax.init) ?? Syntax(declaration),
            message: OntologyDiagnostic.missingBody,
            fixIt: FixIt(
                message: OntologyFixIt(message: "Add 'var body: some Content'", id: "missingBody"),
                changes: [.replace(
                    oldNode: Syntax(members),
                    newNode: Syntax(MemberBlockItemListSyntax([member] + Array(members)))
                )]
            )
        )
    }
}
