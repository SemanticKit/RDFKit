import SwiftSyntax

/// Parses annotations from a trailing closure.
struct AnnotationParser {
    static func parse(from call: FunctionCallExprSyntax) -> [ParsedAnnotation] {
        guard let trailingClosure = call.trailingClosure else { return [] }
        var annotations: [ParsedAnnotation] = []

        for statement in trailingClosure.statements {
            guard let expr = statement.item.as(ExprSyntax.self) else { continue }
            let (baseExpr, _) = unwrapChainedCalls(expr)
            guard let baseExpr, let innerCall = baseExpr.as(FunctionCallExprSyntax.self) else { continue }
            guard let funcName = innerCall.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text else { continue }

            let value: String
            if let firstArg = innerCall.arguments.first {
                if let stringLiteral = firstArg.expression.as(StringLiteralExprSyntax.self) {
                    // String literal: grab segments to avoid source formatting issues
                    let segments = stringLiteral.segments.map { $0.description }.joined()
                    value = "\"\(segments)\""
                } else {
                    value = firstArg.expression.description.trimmingCharacters(in: .whitespaces)
                }
            } else {
                value = ""
            }
            annotations.append(ParsedAnnotation(name: funcName, value: value))
        }
        return annotations
    }

    private static func unwrapChainedCalls(_ expr: ExprSyntax) -> (ExprSyntax?, [String]) {
        var current = expr
        while let callExpr = current.as(FunctionCallExprSyntax.self),
              let memberAccess = callExpr.calledExpression.as(MemberAccessExprSyntax.self) {
            if let base = memberAccess.base {
                current = base
            } else {
                break
            }
        }
        return (current, [])
    }
}
