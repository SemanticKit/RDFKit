import OntologyGeneration
import SwiftSyntax
import SwiftSyntaxMacros

/// The body macro on an ontology's `var body`.
///
/// `@Ontology` attaches it. The authored body names terms by their type,
/// `Type(RDFS.Class)`, and declares them with forms such as `Class(...)` that
/// the generated terms shadow inside RDF, RDFS and OWL. A body macro owns the
/// body, so the compiler reads it only as syntax and type-checks the body this
/// macro returns instead: the same statements, with each form qualified,
/// `RDFKit.Class(...)`. A term a form names is named again in type position,
/// `typealias _RDFS_Class = RDFS.Class`, so that the compiler checks it,
/// and the form itself, which holds nothing, is `RDFKit.Type()` (rule 7).
public struct OntologyBodyMacro: BodyMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
        in context: some MacroExpansionContext
    ) throws -> [CodeBlockItemSyntax] {
        guard let body = declaration.body else {
            throw MacroError("@OntologyBody requires a 'var body: some Content' with a body")
        }
        let rewriter = DeclarationRewriter()
        let rewritten = rewriter.rewrite(body.statements).cast(CodeBlockItemListSyntax.self)
        // The statements' own indentation, which the typealiases after them
        // take.
        let indentation = rewritten.first.map { item in
            item.leadingTrivia.pieces.reversed().prefix { if case .spaces = $0 { true } else { false } }
                .reduce(0) { count, piece in if case .spaces(let spaces) = piece { count + spaces } else { count } }
        } ?? 0
        let statements = CodeBlockItemListSyntax(Array(rewritten) + rewriter.terms.map { name, term in
            CodeBlockItemSyntax(item: .decl(DeclSyntax(TypeAliasDeclSyntax(
                leadingTrivia: [.newlines(1), .spaces(indentation)],
                typealiasKeyword: .keyword(.typealias, trailingTrivia: .space),
                name: .identifier(name),
                initializer: TypeInitializerClauseSyntax(value: TypeSyntax(stringLiteral: term))
            ))))
        })
        return [
            """
            @RDFCore.ContentBuilder func declarations() -> [any RDFCore.Content] {
            \(statements)
            }
            """,
            "return declarations()",
        ]
    }
}

/// The DSL forms in RDFKit, and those whose argument names a term.
enum DSLForm {
    static let names: Set<String> = ["Namespace", "Class", "Datatype", "Property", "Type", "SubClassOf", "Domain", "Range", "Label", "Comment"]
    static let termForms: Set<String> = ["Type", "SubClassOf", "Domain", "Range"]
}

/// Rewrites `Class("Class")` as `RDFKit.Class("Class")`, and
/// `Type(RDFS.Class)` as `RDFKit.Type()`, collecting the term it names.
private final class DeclarationRewriter: SyntaxRewriter {
    /// Each term the forms name, once, with the name of the typealias that
    /// names it in type position.
    private(set) var terms: [(name: String, term: String)] = []

    override func visit(_ node: FunctionCallExprSyntax) -> ExprSyntax {
        guard let call = super.visit(node).as(FunctionCallExprSyntax.self),
              let reference = call.calledExpression.as(DeclReferenceExprSyntax.self),
              DSLForm.names.contains(reference.baseName.text) else { return super.visit(node) }
        let form = reference.baseName.text
        var rewritten = call.with(\.calledExpression, ExprSyntax(MemberAccessExprSyntax(
            leadingTrivia: reference.leadingTrivia,
            base: DeclReferenceExprSyntax(baseName: .identifier("RDFKit")),
            declName: DeclReferenceExprSyntax(baseName: .identifier(form))
        )))
        if DSLForm.termForms.contains(form), let argument = call.arguments.first {
            let term = argument.expression.trimmedDescription
            if !terms.contains(where: { $0.term == term }) {
                terms.append(("_" + term.replacing(".", with: "_"), term))
            }
            rewritten = rewritten.with(\.arguments, [])
        }
        return ExprSyntax(rewritten)
    }
}
