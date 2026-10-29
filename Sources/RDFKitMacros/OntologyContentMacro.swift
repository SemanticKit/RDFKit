import SwiftSyntax
import SwiftSyntaxMacros

/// The body macro on an ontology's `func content()`.
///
/// `@Ontology` attaches it. The authored body names related terms by their
/// type, `Domain(Fauna.Animal)`, which Swift cannot evaluate as an
/// expression. A body macro owns the body, so the compiler reads it only as
/// syntax and type-checks the body this macro returns instead: the same
/// statements, with each term annotation written as the annotation type for
/// that term, `Domain<Fauna.Animal>()`, built by ``ContentBuilder``.
public struct OntologyContentMacro: BodyMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
        in context: some MacroExpansionContext
    ) throws -> [CodeBlockItemSyntax] {
        guard let body = declaration.body else {
            throw MacroError("@OntologyContent requires a 'func content() -> Content' with a body")
        }
        let statements = TermAnnotationRewriter().rewrite(body.statements).cast(CodeBlockItemListSyntax.self)
        return [
            """
            @RDFCore.ContentBuilder func authoredContent() -> RDFCore.Content {
            \(statements)
            }
            """,
            "return authoredContent()",
        ]
    }
}

/// Rewrites `Domain(Fauna.Animal)` as `Domain<Fauna.Animal>()`, for every
/// term annotation form.
private final class TermAnnotationRewriter: SyntaxRewriter {
    override func visit(_ node: FunctionCallExprSyntax) -> ExprSyntax {
        let visited = super.visit(node)
        guard let call = visited.as(FunctionCallExprSyntax.self),
              let reference = call.calledExpression.as(DeclReferenceExprSyntax.self),
              BootstrapTerm.termForms.contains(reference.baseName.text),
              let term = TermArgument.typePath(of: call) else { return visited }
        let rewritten: ExprSyntax = "\(raw: reference.baseName.text)<\(raw: term)>()"
        return rewritten
            .with(\.leadingTrivia, call.leadingTrivia)
            .with(\.trailingTrivia, call.trailingTrivia)
    }
}
