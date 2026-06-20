import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

/// Parses the ontology DSL content block.
struct OntologyParser {
    static func parse(declaration: some DeclGroupSyntax) throws -> ParsedOntology {
        guard let contentBinding = findContentProperty(in: declaration) else {
            throw MacroError("@Ontology requires a 'var content: Content' computed property")
        }

        guard let accessorBlock = contentBinding.accessorBlock,
              let codeBlock = accessorBlock.accessors.as(CodeBlockItemListSyntax.self) else {
            throw MacroError("Content property must have a body")
        }

        let body = CodeBlockSyntax(statements: codeBlock)

        guard let namespace = extractNamespace(from: body) else {
            throw MacroError("Content must include a Namespace(\"...\") declaration")
        }

        let prefixes = extractPrefixDeclarations(from: body)
        let entities = extractEntities(from: body)
        let datatypes = extractDatatypeDeclarations(from: body)
        let individuals = extractIndividualDeclarations(from: body)
        let properties = extractPropertyDeclarations(from: body)

        return ParsedOntology(
            namespace: namespace,
            prefixes: prefixes,
            entities: entities,
            datatypes: datatypes,
            individuals: individuals,
            properties: properties
        )
    }

    // MARK: - Private

    private static func findContentProperty(in declaration: some DeclGroupSyntax) -> PatternBindingSyntax? {
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

    private static func extractNamespace(from body: CodeBlockSyntax) -> String? {
        for statement in body.statements {
            guard let expr = statement.item.as(ExprSyntax.self)?.as(FunctionCallExprSyntax.self) else { continue }
            let calledName = expr.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text
            guard calledName == "Namespace" else { continue }
            guard let firstArg = expr.arguments.first,
                  let stringLiteral = firstArg.expression.as(StringLiteralExprSyntax.self),
                  let segment = stringLiteral.segments.first?.as(StringSegmentSyntax.self) else { continue }
            return segment.content.text
        }
        return nil
    }

    private static func extractPrefixDeclarations(from body: CodeBlockSyntax) -> [ParsedEntity] {
        var prefixes: [ParsedEntity] = []
        for statement in body.statements {
            guard let expr = statement.item.as(ExprSyntax.self) else { continue }
            let (baseExpr, _) = unwrapChainedCalls(expr)
            guard let baseExpr, let call = baseExpr.as(FunctionCallExprSyntax.self) else { continue }
            guard let funcName = call.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text else { continue }

            guard funcName == "Prefix" else { continue }

            guard let firstArg = call.arguments.first,
                  let nameLiteral = firstArg.expression.as(StringLiteralExprSyntax.self),
                  let nameSegment = nameLiteral.segments.first?.as(StringSegmentSyntax.self) else { continue }

            let name = nameSegment.content.text
            let annotations = AnnotationParser.parse(from: call)
            prefixes.append(ParsedEntity(name: name, kind: funcName, annotations: annotations))
        }
        return prefixes
    }

    private static func extractEntities(from body: CodeBlockSyntax) -> [ParsedEntity] {
        var entities: [ParsedEntity] = []
        for statement in body.statements {
            guard let expr = statement.item.as(ExprSyntax.self) else { continue }
            let (baseExpr, _) = unwrapChainedCalls(expr)
            guard let baseExpr, let call = baseExpr.as(FunctionCallExprSyntax.self) else { continue }
            guard let funcName = call.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text else { continue }

            let skipNames: Set<String> = ["Namespace", "Prefix"]
            guard !skipNames.contains(funcName) else { continue }

            guard funcName == "Class" else { continue }

            guard let firstArg = call.arguments.first,
                  let nameLiteral = firstArg.expression.as(StringLiteralExprSyntax.self),
                  let nameSegment = nameLiteral.segments.first?.as(StringSegmentSyntax.self) else { continue }

            let name = nameSegment.content.text

            let capitalizedName = name.prefix(1).uppercased() + name.dropFirst()
            if existingDSPTypes.contains(capitalizedName) { continue }

            let annotations = AnnotationParser.parse(from: call)
            entities.append(ParsedEntity(name: name, kind: funcName, annotations: annotations))
        }
        return entities
    }

    private static func extractDatatypeDeclarations(from body: CodeBlockSyntax) -> [ParsedEntity] {
        var datatypes: [ParsedEntity] = []
        for statement in body.statements {
            guard let expr = statement.item.as(ExprSyntax.self) else { continue }
            let (baseExpr, _) = unwrapChainedCalls(expr)
            guard let baseExpr, let call = baseExpr.as(FunctionCallExprSyntax.self) else { continue }
            guard let funcName = call.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text else { continue }

            guard funcName == "Datatype" else { continue }

            guard let firstArg = call.arguments.first,
                  let nameLiteral = firstArg.expression.as(StringLiteralExprSyntax.self),
                  let nameSegment = nameLiteral.segments.first?.as(StringSegmentSyntax.self) else { continue }

            let name = nameSegment.content.text
            let annotations = AnnotationParser.parse(from: call)
            datatypes.append(ParsedEntity(name: name, kind: funcName, annotations: annotations))
        }
        return datatypes
    }

    private static func extractIndividualDeclarations(from body: CodeBlockSyntax) -> [ParsedEntity] {
        var individuals: [ParsedEntity] = []
        for statement in body.statements {
            guard let expr = statement.item.as(ExprSyntax.self) else { continue }
            let (baseExpr, _) = unwrapChainedCalls(expr)
            guard let baseExpr, let call = baseExpr.as(FunctionCallExprSyntax.self) else { continue }
            guard let funcName = call.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text else { continue }

            guard funcName == "Individual" else { continue }

            guard let firstArg = call.arguments.first,
                  let nameLiteral = firstArg.expression.as(StringLiteralExprSyntax.self),
                  let nameSegment = nameLiteral.segments.first?.as(StringSegmentSyntax.self) else { continue }

            let name = nameSegment.content.text
            let annotations = AnnotationParser.parse(from: call)
            individuals.append(ParsedEntity(name: name, kind: funcName, annotations: annotations))
        }
        return individuals
    }

    private static func extractPropertyDeclarations(from body: CodeBlockSyntax) -> [ParsedEntity] {
        var properties: [ParsedEntity] = []
        for statement in body.statements {
            guard let expr = statement.item.as(ExprSyntax.self) else { continue }
            let (baseExpr, _) = unwrapChainedCalls(expr)
            guard let baseExpr, let call = baseExpr.as(FunctionCallExprSyntax.self) else { continue }
            guard let funcName = call.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text else { continue }

            guard funcName == "Property" else { continue }

            guard let firstArg = call.arguments.first,
                  let nameLiteral = firstArg.expression.as(StringLiteralExprSyntax.self),
                  let nameSegment = nameLiteral.segments.first?.as(StringSegmentSyntax.self) else { continue }

            let name = nameSegment.content.text
            let annotations = AnnotationParser.parse(from: call)
            properties.append(ParsedEntity(name: name, kind: funcName, annotations: annotations))
        }
        return properties
    }

    private static let existingDSPTypes: Set<String> = [
        "Class", "Property", "Individual", "Datatype",
        "SubClassOf", "SubPropertyOf",
        "Label", "Comment", "Domain", "Range",
        "SeeAlso", "IsDefinedBy", "Deprecated",
        "TypeAxiom", "RangeAxiom",
    ]

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
