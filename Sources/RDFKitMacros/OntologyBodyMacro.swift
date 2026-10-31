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
/// `RDFKit.Class(...)`, and each term argument a metatype, `RDFS.Class.self`.
public struct OntologyBodyMacro: BodyMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
        in context: some MacroExpansionContext
    ) throws -> [CodeBlockItemSyntax] {
        guard let body = declaration.body else {
            throw MacroError("@OntologyBody requires a 'var body: some Content' with a body")
        }
        let statements = DeclarationRewriter().rewrite(body.statements).cast(CodeBlockItemListSyntax.self)
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

/// Rewrites `Class("Class")` as `RDFKit.Class("Class")` and `Type(RDFS.Class)`
/// as `RDFKit.Type(RDFS.Class.self)`.
private final class DeclarationRewriter: SyntaxRewriter {
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
            let metatype = MemberAccessExprSyntax(
                base: argument.expression.trimmed,
                declName: DeclReferenceExprSyntax(baseName: .keyword(.self))
            )
            rewritten = rewritten.with(\.arguments, [argument.with(\.expression, ExprSyntax(metatype))])
        }
        return ExprSyntax(rewritten)
    }
}
