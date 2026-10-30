import SwiftSyntax

/// Reads the annotations in a declaration's trailing closure.
struct AnnotationParser {
    static func parse(from call: FunctionCallExprSyntax, declaredNames: Set<String>) -> [ParsedAnnotation] {
        guard let closure = call.trailingClosure else { return [] }
        return closure.statements.compactMap { statement in
            guard let expression = statement.item.as(ExprSyntax.self),
                  let call = DeclarationCall(expression, declaredNames: declaredNames) else { return nil }
            return ParsedAnnotation(name: call.name, argument: call.argument, syntax: Syntax(call.call))
        }
    }
}

/// A call to a DSL form, `Name(...)`, possibly followed by chained modifiers
/// such as `.deprecated()`.
struct DeclarationCall {
    let name: String
    let call: FunctionCallExprSyntax
    let argument: ParsedAnnotation.Argument

    init?(_ expression: ExprSyntax, declaredNames: Set<String>) {
        var current = expression
        // Unwrap chained modifiers: `Class("X") { ... }.deprecated()`.
        while let chained = current.as(FunctionCallExprSyntax.self),
              let member = chained.calledExpression.as(MemberAccessExprSyntax.self),
              let base = member.base {
            current = base
        }
        guard let call = current.as(FunctionCallExprSyntax.self),
              let reference = call.calledExpression.as(DeclReferenceExprSyntax.self) else { return nil }
        self.name = reference.baseName.text
        self.call = call
        if ParsedEntity.Kind(rawValue: name) == nil,
           let term = TermArgument.typePath(of: call, declaredNames: declaredNames) {
            self.argument = .term(term)
        } else {
            self.argument = Self.argument(of: call)
        }
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
///
/// Which annotations relate terms is read from how they are written, not
/// from a list of annotation names: an annotation whose only argument names
/// a type relates the declared term to that type. Annotations that carry
/// text take a string literal, which the macro reads at compile time for
/// DocC, so a name in that position is always a type.
enum TermArgument {
    /// The type spelling of a call's only argument, when the call is
    /// `Name(Path.To.Type)`: one unlabeled argument that is a qualified type
    /// path (or the bare name of a term this ontology declares), with no
    /// trailing closure. A `.self` path is not a type path.
    static func typePath(of call: FunctionCallExprSyntax, declaredNames: Set<String>) -> String? {
        guard call.trailingClosure == nil,
              call.additionalTrailingClosures.isEmpty,
              call.arguments.count == 1,
              let argument = call.arguments.first,
              argument.label == nil,
              let components = components(of: argument.expression),
              components.last != "self" else { return nil }
        if components.count == 1, !declaredNames.contains(components[0]) { return nil }
        return components.joined(separator: ".")
    }

    /// The components of a member path such as `Fauna.Animal`, including a
    /// trailing `self`.
    static func components(of expression: ExprSyntax) -> [String]? {
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
