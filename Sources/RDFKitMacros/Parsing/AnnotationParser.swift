import SwiftSyntax

/// Reads the annotations in a declaration's trailing closure.
struct AnnotationParser {
    static func parse(from call: FunctionCallExprSyntax) -> [ParsedAnnotation] {
        guard let closure = call.trailingClosure else { return [] }
        return closure.statements.compactMap { statement in
            guard let expression = statement.item.as(ExprSyntax.self),
                  let call = DeclarationCall(expression) else { return nil }
            return ParsedAnnotation(name: call.name, argument: call.argument)
        }
    }
}

/// A call to a DSL form, `Name(...)` or `Name<Term>(...)`, possibly followed
/// by chained modifiers such as `.deprecated()`.
struct DeclarationCall {
    let name: String
    let call: FunctionCallExprSyntax
    let argument: ParsedAnnotation.Argument

    init?(_ expression: ExprSyntax) {
        var current = expression
        // Unwrap chained modifiers: `Class("X") { ... }.deprecated()`.
        while let chained = current.as(FunctionCallExprSyntax.self),
              let member = chained.calledExpression.as(MemberAccessExprSyntax.self),
              let base = member.base {
            current = base
        }
        guard let call = current.as(FunctionCallExprSyntax.self) else { return nil }

        if let reference = call.calledExpression.as(DeclReferenceExprSyntax.self) {
            self.name = reference.baseName.text
            self.argument = Self.argument(of: call)
        } else if let specialized = call.calledExpression.as(GenericSpecializationExprSyntax.self),
                  let reference = specialized.expression.as(DeclReferenceExprSyntax.self),
                  let term = specialized.genericArgumentClause.arguments.first {
            self.name = reference.baseName.text
            self.argument = .term(term.argument.trimmedDescription)
        } else {
            return nil
        }
        self.call = call
    }

    /// The source text of the first string literal argument, without quotes.
    var stringArgument: String? {
        if case .text(let source) = argument { return source }
        return nil
    }

    private static func argument(of call: FunctionCallExprSyntax) -> ParsedAnnotation.Argument {
        guard let first = call.arguments.first?.expression else { return .none }
        if let literal = first.as(StringLiteralExprSyntax.self),
           literal.segments.allSatisfy({ $0.is(StringSegmentSyntax.self) }) {
            return .text(literal.segments.map(\.description).joined())
        }
        return .expression(first.trimmedDescription)
    }
}
