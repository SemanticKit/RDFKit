import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

/// A macro that reads the ontology content tree and generates typed term IRI constants.
///
/// Attached to an ontology struct, this macro:
/// 1. Finds the `content` computed property body
/// 2. Extracts the namespace string from `Namespace("...")`
/// 3. Finds each `Class("Name")`, `Property("Name")`, `Datatype("Name")`
/// 4. Generates a `static let Name: IRI = IRI("namespaceName")` property
///
/// This produces the same output as manually writing term enums:
///     public enum RDFSTerm {
///         public static let Class: IRI = IRI("http://www.w3.org/2000/01/rdf-schema#Class")
///     }
///
/// But the macro reads the DSL content body so the author writes the ontology
/// once using the DSL and the compiler generates the IRI references.
public struct VocabularyMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo types: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw VocabularyError("@Vocabulary can only be applied to structs")
        }

        let structName = structDecl.name.text

        guard let contentBinding = findContentProperty(in: declaration) else {
            throw VocabularyError("@Vocabulary requires a 'var content: Content' computed property")
        }

        guard let accessorBlock = contentBinding.accessorBlock,
              let codeBlock = accessorBlock.accessors.as(CodeBlockItemListSyntax.self) else {
            throw VocabularyError("Content property must have a body")
        }

        let body = CodeBlockSyntax(statements: codeBlock)

        guard let namespace = extractNamespace(from: body) else {
            throw VocabularyError("Content must include a Namespace(\"...\") declaration")
        }

        let terms = extractTerms(from: body)

        var results: [DeclSyntax] = []

        for term in terms {
            let iriString = "\(namespace)\(term.name)"
            results.append("""
            public static let \(raw: term.name): IRIKit.IRI = IRIKit.IRI(\(raw: "\"\(iriString)\""))
            """)
        }

        return results
    }
}

// MARK: - Helpers

private func findContentProperty(in declaration: some DeclGroupSyntax) -> PatternBindingSyntax? {
    for member in declaration.memberBlock.members {
        if let varDecl = member.decl.as(VariableDeclSyntax.self) {
            for binding in varDecl.bindings {
                if let identifier = binding.pattern.as(IdentifierPatternSyntax.self),
                   identifier.identifier.text == "content" {
                    return binding
                }
            }
        }
    }
    return nil
}

private func extractNamespace(from body: CodeBlockSyntax) -> String? {
    for statement in body.statements {
        guard let expr = statement.item.as(ExprSyntax.self)?.as(FunctionCallExprSyntax.self) else {
            continue
        }
        let calledName = expr.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text
        guard calledName == "Namespace" else { continue }

        guard let firstArg = expr.arguments.first,
              let stringLiteral = firstArg.expression.as(StringLiteralExprSyntax.self),
              let segment = stringLiteral.segments.first?.as(StringSegmentSyntax.self) else {
            continue
        }
        return segment.content.text
    }
    return nil
}

struct ParsedTerm {
    let name: String
}

private func extractTerms(from body: CodeBlockSyntax) -> [ParsedTerm] {
    var terms: [ParsedTerm] = []

    for statement in body.statements {
        guard let expr = statement.item.as(ExprSyntax.self) else {
            continue
        }

        let (termCall, _) = unwrapChainedCalls(expr)

        guard let termCall, let calledExpr = termCall.as(FunctionCallExprSyntax.self) else {
            continue
        }

        let calledName = calledExpr.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text

        guard calledName == "Class" || calledName == "Property" || calledName == "Datatype" else {
            continue
        }

        guard let firstArg = calledExpr.arguments.first,
              let nameLiteral = firstArg.expression.as(StringLiteralExprSyntax.self),
              let nameSegment = nameLiteral.segments.first?.as(StringSegmentSyntax.self) else {
            continue
        }

        terms.append(ParsedTerm(name: nameSegment.content.text))
    }

    return terms
}

/// Unwraps chained method calls like `.isDeclaredBy(namespace: X)`.
private func unwrapChainedCalls(_ expr: ExprSyntax) -> (ExprSyntax?, [String]) {
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

// MARK: - Errors

struct VocabularyError: Error, CustomStringConvertible {
    let message: String

    var description: String { message }

    init(_ message: String) {
        self.message = message
    }
}
