import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

/// The body macro on an ontology's `func content()`.
///
/// `@Ontology` attaches it. The authored body names related terms by their
/// type, `Domain(Fauna.Animal)`, which Swift cannot evaluate as an
/// expression. A body macro owns the body, so the compiler reads it only as
/// syntax and type-checks the body this macro returns instead.
///
/// The annotations that relate a term to another term (`SubClassOf`,
/// `Domain`, `Range`, `Type`, any annotation whose argument is a type) are
/// not values: `@Ontology` writes each one as the Swift declaration it
/// describes, protocol refinement or a requirement and its type. In the
/// body this macro returns they are left out, and their lines stay blank so
/// the statements after them keep their authored lines. The body is the
/// declarations and the annotations that carry text, `Label`, `Comment`,
/// `SeeAlso`, `Deprecated`, with each declaration form qualified by its
/// module, `RDFCore.Class("Animal")`, because the ontology may declare a
/// term of the same name (`RDFS.Class`). The statements keep the authored
/// file and line, so the compiler reports an error in them at the line it
/// was written on. `content()` takes ``ContentBuilder`` from the `Ontology`
/// requirement, so the returned statements are built into `Content`.
public struct OntologyContentMacro: BodyMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
        in context: some MacroExpansionContext
    ) throws -> [CodeBlockItemSyntax] {
        guard let body = declaration.body else {
            throw MacroError("@OntologyContent requires a 'func content() -> Content' with a body")
        }
        let rewriter = ContentRewriter(declaredNames: OntologyParser.declaredNames(in: body.statements))
        let rewritten = rewriter.rewrite(body.statements).cast(CodeBlockItemListSyntax.self)
        for diagnostic in rewriter.diagnostics {
            context.diagnose(diagnostic)
        }
        // Each statement is preceded by the line it was authored on, so the
        // compiler reports an error in it at that line.
        var items: [CodeBlockItemSyntax] = []
        for (authored, statement) in zip(body.statements, rewritten) {
            if let directive = sourceLocation(of: authored, in: context) { items.append(directive) }
            items.append(statement)
        }
        if items.count > rewritten.count { items.append(CodeBlockItemSyntax(item: .decl("#sourceLocation()"))) }
        return items
    }

    /// `#sourceLocation(file:line:)` for the file and line a statement was
    /// authored on.
    private static func sourceLocation(of statement: CodeBlockItemSyntax, in context: some MacroExpansionContext) -> CodeBlockItemSyntax? {
        guard let location = context.location(of: statement, at: .afterLeadingTrivia, filePathMode: .filePath),
              let file = location.file.as(StringLiteralExprSyntax.self),
              let line = location.line.as(IntegerLiteralExprSyntax.self) else { return nil }
        return CodeBlockItemSyntax(item: .decl("#sourceLocation(file: \(file), line: \(line))"))
    }
}

/// Qualifies `Class("Animal")` as `RDFCore.Class("Animal")` and leaves out
/// the annotations that relate a term to another term, and reports the
/// spellings the DSL does not use (a generic argument, or a `.self`
/// argument) at the authored call.
private final class ContentRewriter: SyntaxRewriter {
    let declaredNames: Set<String>
    private(set) var diagnostics: [Diagnostic] = []

    init(declaredNames: Set<String>) {
        self.declaredNames = declaredNames
        super.init(viewMode: .sourceAccurate)
    }

    /// Drops the term annotations from a declaration's closure. Their lines
    /// stay as blank lines, so every statement after them keeps the line it
    /// was authored on.
    override func visit(_ node: ClosureExprSyntax) -> ExprSyntax {
        let visited = super.visit(node)
        guard var closure = visited.as(ClosureExprSyntax.self) else { return visited }
        var kept: [CodeBlockItemSyntax] = []
        var droppedLines = 0
        for item in closure.statements {
            if let call = item.item.as(FunctionCallExprSyntax.self), relatesTerms(call) {
                droppedLines += item.description.count { $0 == "\n" }
                continue
            }
            kept.append(droppedLines == 0 ? item : item.with(\.leadingTrivia, .newlines(droppedLines) + item.leadingTrivia))
            droppedLines = 0
        }
        closure.statements = CodeBlockItemListSyntax(kept)
        if droppedLines > 0 {
            closure.rightBrace = closure.rightBrace.with(\.leadingTrivia, .newlines(droppedLines) + closure.rightBrace.leadingTrivia)
        }
        return ExprSyntax(closure)
    }

    override func visit(_ node: FunctionCallExprSyntax) -> ExprSyntax {
        diagnoseUnusedSpellings(of: node)
        let visited = super.visit(node)
        guard let call = visited.as(FunctionCallExprSyntax.self),
              let reference = call.calledExpression.as(DeclReferenceExprSyntax.self),
              ParsedEntity.Kind(rawValue: reference.baseName.text) != nil else { return visited }
        let qualified: ExprSyntax = "RDFCore.\(raw: reference.baseName.text)"
        return ExprSyntax(call.with(\.calledExpression, qualified.with(\.leadingTrivia, reference.leadingTrivia)))
    }

    /// Whether a call relates the declared term to another term,
    /// `Domain(Fauna.Animal)`, which `@Ontology` writes as a Swift
    /// declaration, or is one of the spellings reported for it.
    private func relatesTerms(_ call: FunctionCallExprSyntax) -> Bool {
        if call.calledExpression.is(DeclReferenceExprSyntax.self),
           TermArgument.typePath(of: call, declaredNames: declaredNames) != nil {
            return true
        }
        return unusedSpelling(of: call) != nil
    }

    /// The form and related type of a term annotation written with a generic
    /// argument or a `.self` argument instead of the related type.
    private func unusedSpelling(of call: FunctionCallExprSyntax) -> (form: String, type: String)? {
        guard call.trailingClosure == nil, call.additionalTrailingClosures.isEmpty else { return nil }

        if let specialized = call.calledExpression.as(GenericSpecializationExprSyntax.self),
           let reference = specialized.expression.as(DeclReferenceExprSyntax.self),
           call.arguments.isEmpty,
           specialized.genericArgumentClause.arguments.count == 1,
           let argument = specialized.genericArgumentClause.arguments.first {
            return (reference.baseName.text, argument.argument.trimmedDescription)
        }

        if let reference = call.calledExpression.as(DeclReferenceExprSyntax.self),
           call.arguments.count == 1,
           let argument = call.arguments.first, argument.label == nil,
           let components = TermArgument.components(of: argument.expression),
           components.count > 1, components.last == "self" {
            return (reference.baseName.text, components.dropLast().joined(separator: "."))
        }
        return nil
    }

    private func diagnoseUnusedSpellings(of call: FunctionCallExprSyntax) {
        guard let (form, type) = unusedSpelling(of: call) else { return }
        let replacement: ExprSyntax = "\(raw: form)(\(raw: type))"
        diagnostics.append(Diagnostic(
            node: call,
            message: OntologyDiagnostic.writeRelatedTypeAsArgument(form: form, type: type),
            fixIt: FixIt(
                message: OntologyFixIt(message: "Write \(form)(\(type))"),
                changes: [.replace(oldNode: Syntax(call), newNode: Syntax(replacement.with(\.leadingTrivia, call.leadingTrivia).with(\.trailingTrivia, call.trailingTrivia)))]
            )
        ))
    }
}
