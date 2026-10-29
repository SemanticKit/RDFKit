import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

/// The body macro on an ontology's `func content()`.
///
/// `@Ontology` attaches it. The authored body names related terms by their
/// type, `Domain(Fauna.Animal)`, which Swift cannot evaluate as an
/// expression. A body macro owns the body, so the compiler reads it only as
/// syntax and type-checks the body this macro returns instead: the same
/// statements, with each annotation written as the property term it stands
/// for, which `@Ontology` generates from RDF.swift, RDFS.swift and OWL.swift:
/// `Label("Animal")` as `RDFS.label("Animal")` and `Domain(Fauna.Animal)` as
/// `RDFS.domain<Fauna.Animal>()`. Each declaration form is qualified by its
/// module, `RDFCore.Class("Animal")`, because the ontology may declare a term
/// of the same name (`RDFS.Class`). The statements keep the authored
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

/// Rewrites `Domain(Fauna.Animal)` as `RDFS.domain<Fauna.Animal>()`,
/// `Label("Animal")` as `RDFS.label("Animal")` and `Class("Animal")` as
/// `RDFCore.Class("Animal")`, and reports the spellings
/// the DSL does not use (`Domain<Fauna.Animal>()`, `Domain(Fauna.Animal.self)`)
/// at the authored call.
private final class ContentRewriter: SyntaxRewriter {
    let declaredNames: Set<String>
    private(set) var diagnostics: [Diagnostic] = []

    init(declaredNames: Set<String>) {
        self.declaredNames = declaredNames
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: FunctionCallExprSyntax) -> ExprSyntax {
        let isUnusedSpelling = diagnoseUnusedSpellings(of: node)
        let visited = super.visit(node)
        // A spelling the DSL does not use is reported and left as written.
        if isUnusedSpelling { return visited }
        guard let call = visited.as(FunctionCallExprSyntax.self),
              let reference = call.calledExpression.as(DeclReferenceExprSyntax.self) else { return visited }

        let form = reference.baseName.text
        if ParsedEntity.Kind(rawValue: form) != nil {
            let qualified: ExprSyntax = "RDFCore.\(raw: form)"
            return ExprSyntax(call.with(\.calledExpression, qualified.with(\.leadingTrivia, reference.leadingTrivia)))
        }
        guard let annotation = BootstrapTerm.term(writtenAs: form) else { return visited }
        guard let term = TermArgument.typePath(of: call, declaredNames: declaredNames) else {
            let written: ExprSyntax = "\(raw: annotation)"
            return ExprSyntax(call.with(\.calledExpression, written.with(\.leadingTrivia, reference.leadingTrivia)))
        }
        let rewritten: ExprSyntax = "\(raw: annotation)<\(raw: term)>()"
        return rewritten
            .with(\.leadingTrivia, call.leadingTrivia)
            .with(\.trailingTrivia, call.trailingTrivia)
    }

    /// Reports `Domain<Fauna.Animal>()` and `Domain(Fauna.Animal.self)`, and
    /// returns whether the call is one of them.
    private func diagnoseUnusedSpellings(of call: FunctionCallExprSyntax) -> Bool {
        guard call.trailingClosure == nil, call.additionalTrailingClosures.isEmpty else { return false }

        if let specialized = call.calledExpression.as(GenericSpecializationExprSyntax.self),
           let reference = specialized.expression.as(DeclReferenceExprSyntax.self),
           call.arguments.isEmpty,
           specialized.genericArgumentClause.arguments.count == 1,
           let argument = specialized.genericArgumentClause.arguments.first {
            let form = reference.baseName.text
            let type = argument.argument.trimmedDescription
            diagnose(call, form: form, type: type)
            return true
        }

        if let reference = call.calledExpression.as(DeclReferenceExprSyntax.self),
           call.arguments.count == 1,
           let argument = call.arguments.first, argument.label == nil,
           let components = TermArgument.components(of: argument.expression),
           components.count > 1, components.last == "self" {
            diagnose(call, form: reference.baseName.text, type: components.dropLast().joined(separator: "."))
            return true
        }
        return false
    }

    private func diagnose(_ call: FunctionCallExprSyntax, form: String, type: String) {
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

private extension Trivia {
    /// This trivia without the newlines before its first non-whitespace piece,
    /// keeping the indentation.
    var droppingLeadingNewlines: Trivia {
        Trivia(pieces: pieces.drop { piece in
            if case .newlines = piece { return true }
            if case .carriageReturnLineFeeds = piece { return true }
            return false
        })
    }
}
