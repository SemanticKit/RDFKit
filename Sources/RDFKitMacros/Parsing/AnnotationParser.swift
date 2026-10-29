import SwiftSyntax

/// Reads the annotations in a declaration's trailing closure.
struct AnnotationParser {
    static func parse(from call: FunctionCallExprSyntax) throws -> [ParsedAnnotation] {
        guard let closure = call.trailingClosure else { return [] }
        return try closure.statements.compactMap { statement in
            guard let expression = statement.item.as(ExprSyntax.self),
                  let call = try DeclarationCall(expression) else { return nil }
            return ParsedAnnotation(name: call.name, argument: call.argument)
        }
    }
}

/// A call to a DSL form, `Name(...)`, possibly followed by chained modifiers
/// such as `.deprecated()`.
struct DeclarationCall {
    let name: String
    let call: FunctionCallExprSyntax
    let argument: ParsedAnnotation.Argument

    init?(_ expression: ExprSyntax) throws {
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
            if BootstrapTerm.termForms.contains(name) {
                guard let term = TermArgument.typePath(of: call) else {
                    throw MacroError("Write \(name) with the related type as its argument: \(name)(Fauna.Animal)")
                }
                self.argument = .term(term)
            } else {
                self.argument = Self.argument(of: call)
            }
        } else if let specialized = call.calledExpression.as(GenericSpecializationExprSyntax.self),
                  let reference = specialized.expression.as(DeclReferenceExprSyntax.self),
                  BootstrapTerm.termForms.contains(reference.baseName.text) {
            let name = reference.baseName.text
            throw MacroError("Write \(name) with the related type as its argument: \(name)(Fauna.Animal)")
        } else {
            return nil
        }
        self.call = call
    }

    /// The value of the first string literal argument, with escapes resolved.
    var stringArgument: String? {
        if case .text(let source) = argument { return source }
        return nil
    }

    private static func argument(of call: FunctionCallExprSyntax) -> ParsedAnnotation.Argument {
        guard let first = call.arguments.first?.expression else { return .none }
        // `representedLiteralValue` resolves escapes, raw delimiters and
        // multi-line indentation, and is nil for interpolated literals.
        if let literal = first.as(StringLiteralExprSyntax.self),
           let value = literal.representedLiteralValue {
            return .text(value)
        }
        return .expression(first.trimmedDescription)
    }
}

/// The related type given to a term annotation: `Fauna.Animal` in
/// `Domain(Fauna.Animal)`.
enum TermArgument {
    /// The type spelling of a call's only argument, when the call is
    /// `Name(Path.To.Type)`: one unlabeled argument that is a plain type path,
    /// with no trailing closure. A `.self` path is not a type path.
    static func typePath(of call: FunctionCallExprSyntax) -> String? {
        guard call.trailingClosure == nil,
              call.additionalTrailingClosures.isEmpty,
              call.arguments.count == 1,
              let argument = call.arguments.first,
              argument.label == nil,
              let components = components(of: argument.expression),
              components.last != "self" else { return nil }
        return components.joined(separator: ".")
    }

    private static func components(of expression: ExprSyntax) -> [String]? {
        if let reference = expression.as(DeclReferenceExprSyntax.self), reference.argumentNames == nil {
            return [reference.baseName.text]
        }
        if let member = expression.as(MemberAccessExprSyntax.self),
           let base = member.base,
           let prefix = components(of: base) {
            return prefix + [member.declName.baseName.text]
        }
        return nil
    }
}
