import SwiftSyntax

/// Reads a declaration's annotations from its trailing closure:
/// `Label("Person")` gives `Label` and `Person`, `SubClassOf(RDFS.Resource)`
/// gives `SubClassOf` and `RDFS.Resource`.
struct AnnotationParser {
    static func parse(from call: FunctionCallExprSyntax) throws -> [ParsedAnnotation] {
        guard let closure = call.trailingClosure else { return [] }
        return try closure.statements.compactMap { statement in
            guard let annotation = statement.item.as(FunctionCallExprSyntax.self),
                  let name = OntologyParser.formName(of: annotation),
                  let argument = annotation.arguments.first?.expression else { return nil }
            if let value = OntologyParser.stringValue(of: argument) {
                return ParsedAnnotation(name: name, value: value)
            }
            return ParsedAnnotation(name: name, value: try typeName(of: argument, in: name))
        }
    }

    /// The term an argument names, written as its type: `RDFS.Resource`.
    private static func typeName(of expression: ExprSyntax, in form: String) throws -> String {
        if let member = expression.as(MemberAccessExprSyntax.self),
           member.declName.baseName.tokenKind == .keyword(.self),
           let base = member.base {
            throw MacroError("Write \(form)(\(base.trimmedDescription)), without .self")
        }
        return expression.trimmedDescription
    }
}
