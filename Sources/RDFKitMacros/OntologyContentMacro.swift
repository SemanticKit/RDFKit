import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

/// The body macro on an ontology's `var body`.
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
/// declarations and the annotations that carry text, `Label`,
/// `Comment`, `SeeAlso`, `Deprecated`, with each declaration form qualified
/// by its module, `RDFCore.Class("Animal")`, because the ontology may
/// declare a term of the same name (`RDF.Class`). The statements keep the
/// authored file and line, so the compiler reports an error in them at the
/// line it was written on. `var body` takes ``ContentBuilder`` from the `Ontology`
/// requirement, so the returned statements are built into `some Content`.
public struct OntologyContentMacro: BodyMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
        in context: some MacroExpansionContext
    ) throws -> [CodeBlockItemSyntax] {
        guard let body = declaration.body else {
            throw MacroError("@OntologyContent requires a 'var body: some Content' with a body")
        }
        let rewriter = ContentRewriter(declaredNames: OntologyParser.declaredNames(in: body.statements))
        let rewritten = rewriter.rewrite(body.statements).cast(CodeBlockItemListSyntax.self)
        // Each statement is preceded by the line it was authored on, so the
        // compiler reports an error in it at that line.
        let anchor = BraceAnchor(node, body: body)
        var items: [CodeBlockItemSyntax] = []
        for (authored, statement) in zip(body.statements, rewritten) {
            if let directive = sourceLocation(of: authored, in: context) ?? anchor?.sourceLocation(of: authored) {
                items.append(directive)
            }
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

/// The file and line of the opening brace of `var body`, which `@Ontology`
/// passes as `@OntologyContent(file:line:)`. The getter a body macro on a
/// computed property is given is built outside the authored file, so the
/// line of each statement is counted from the brace.
private struct BraceAnchor {
    let file: StringLiteralExprSyntax
    let line: Int
    let brace: TokenSyntax

    init?(_ attribute: AttributeSyntax, body: CodeBlockSyntax) {
        guard case .argumentList(let arguments) = attribute.arguments,
              let file = arguments.first(where: { $0.label?.text == "file" })?.expression.as(StringLiteralExprSyntax.self),
              let line = arguments.first(where: { $0.label?.text == "line" })?.expression.as(IntegerLiteralExprSyntax.self),
              let value = Int(line.literal.text) else { return nil }
        self.file = file.trimmed
        self.line = value
        self.brace = body.leftBrace
    }

    func sourceLocation(of statement: CodeBlockItemSyntax) -> CodeBlockItemSyntax? {
        guard statement.root == brace.root else { return nil }
        let converter = SourceLocationConverter(fileName: "", tree: statement.root)
        let offset = converter.location(for: statement.positionAfterSkippingLeadingTrivia).line
            - converter.location(for: brace.positionAfterSkippingLeadingTrivia).line
        return CodeBlockItemSyntax(item: .decl("#sourceLocation(file: \(file), line: \(raw: line + offset))"))
    }
}

/// Qualifies `Class("Animal")` as `RDFCore.Class("Animal")` and leaves out
/// the annotations that relate a term to another term, including the
/// generic-argument and `.self` spellings, which `@Ontology` reports.
private final class ContentRewriter: SyntaxRewriter {
    let declaredNames: Set<String>

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
            if let call = item.item.as(FunctionCallExprSyntax.self), relatedTerm(of: call) != nil {
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

    /// The DSL forms RDFCore declares. An ontology may declare a term of the
    /// same name (`Class`, `Label`), whose generated type would otherwise
    /// shadow the form inside the ontology.
    static let forms: Set<String> = Set(ParsedEntity.Kind.allCases.map(\.rawValue))
        .union(["Namespace", "Prefix", "Label", "Comment", "SeeAlso", "Deprecated"])

    override func visit(_ node: FunctionCallExprSyntax) -> ExprSyntax {
        let visited = super.visit(node)
        guard let call = visited.as(FunctionCallExprSyntax.self),
              let reference = call.calledExpression.as(DeclReferenceExprSyntax.self),
              Self.forms.contains(reference.baseName.text) else { return visited }
        let qualified: ExprSyntax = "RDFCore.\(raw: reference.baseName.text)"
        return ExprSyntax(call.with(\.calledExpression, qualified.with(\.leadingTrivia, reference.leadingTrivia)))
    }

    /// The form and related type of an annotation that relates the declared
    /// term to another term, `Domain(Fauna.Animal)`, which `@Ontology` writes
    /// as a declaration, or of one of the spellings reported for it.
    private func relatedTerm(of call: FunctionCallExprSyntax) -> (form: String, type: String)? {
        if let reference = call.calledExpression.as(DeclReferenceExprSyntax.self),
           let term = TermArgument.typePath(of: call, declaredNames: declaredNames) {
            return (reference.baseName.text, term)
        }
        return UnusedSpelling.of(call)
    }
}

/// A term annotation written with a generic argument or a `.self` argument
/// instead of the related type, which the DSL does not use. `@Ontology`
/// reports it at the authored call: it reads the authored body, which is in
/// the source file, while the body macro on `var body` is given a copy.
enum UnusedSpelling {
    /// The form and related type of a term annotation written with a generic
    /// argument or a `.self` argument instead of the type.
    static func of(_ call: FunctionCallExprSyntax) -> (form: String, type: String)? {
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

    /// The error for a call written with one of these spellings, with a
    /// fix-it to the related type as the argument.
    static func diagnostic(for call: FunctionCallExprSyntax) -> Diagnostic? {
        guard let (form, type) = of(call) else { return nil }
        let replacement: ExprSyntax = "\(raw: form)(\(raw: type))"
        return Diagnostic(
            node: call,
            message: OntologyDiagnostic.writeRelatedTypeAsArgument(form: form, type: type),
            fixIt: FixIt(
                message: OntologyFixIt(message: "Write \(form)(\(type))"),
                changes: [.replace(oldNode: Syntax(call), newNode: Syntax(replacement.with(\.leadingTrivia, call.leadingTrivia).with(\.trailingTrivia, call.trailingTrivia)))]
            )
        )
    }
}

/// Reports every ``UnusedSpelling`` in an ontology's authored body.
final class UnusedSpellingVisitor: SyntaxVisitor {
    private(set) var diagnostics: [Diagnostic] = []

    init() { super.init(viewMode: .sourceAccurate) }

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        if let diagnostic = UnusedSpelling.diagnostic(for: node) { diagnostics.append(diagnostic) }
        return .visitChildren
    }
}
