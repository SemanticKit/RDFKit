import SwiftSyntax

/// Reads a declaration's annotations from its trailing closure:
/// `Label("Person")` gives `Label` and `Person`, `SubClassOf(RDFS.Resource.self)`
/// gives `SubClassOf` and `RDFS.Resource`.
struct AnnotationParser {
    static func parse(from call: FunctionCallExprSyntax) -> [ParsedAnnotation] {
        guard let closure = call.trailingClosure else { return [] }
        return closure.statements.compactMap { statement in
            guard let annotation = statement.item.as(FunctionCallExprSyntax.self),
                  let name = OntologyParser.formName(of: annotation),
                  let argument = annotation.arguments.first?.expression else { return nil }
            return ParsedAnnotation(name: name, value: OntologyParser.stringValue(of: argument) ?? typeName(of: argument))
        }
    }

    /// The type a metatype expression names: `RDFS.Resource` for `RDFS.Resource.self`.
    private static func typeName(of expression: ExprSyntax) -> String {
        if let member = expression.as(MemberAccessExprSyntax.self),
           member.declName.baseName.tokenKind == .keyword(.self),
           let base = member.base {
            return base.trimmedDescription
        }
        return expression.trimmedDescription
    }
}
