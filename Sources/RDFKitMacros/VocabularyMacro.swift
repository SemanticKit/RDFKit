import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

/// A macro that reads the ontology content tree and generates typed term structs.
///
/// Attached to an ontology struct, this macro:
/// 1. Finds the `content` computed property body
/// 2. Extracts the namespace string from `Namespace("...")`
/// 3. For each `Class("Name")`, `Property("Name")`, `Individual("Name")`, `Datatype("Name")`:
///    a. Reads the trailing closure to discover annotations
///    b. Generates a `{Name}Term` struct conforming to `OntologyTerm` + contribution protocols
///    c. Generates a `static let {Name} = {Name}Term()` property
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
            let swiftName = sanitizeTypeName(term.name)
            let termStructName = "\(swiftName)Term"
            let staticName = sanitizePropertyName(term.name)

            // Build contribution protocol conformances (deduplicated)
            var conformances: [String] = ["RDFCore.OntologyTerm"]
            var seenProtocols: Set<String> = ["OntologyTerm"]
            for annotation in term.annotations {
                if let protocolName = annotation.contributionProtocol,
                   !seenProtocols.contains(protocolName) {
                    conformances.append("RDFCore.\(protocolName)")
                    seenProtocols.insert(protocolName)
                }
            }
            let conformanceList = conformances.joined(separator: ", ")

            // Build children array from annotations
            var childrenElements: [String] = []
            for annotation in term.annotations {
                if let initializer = annotation.childrenInitializer {
                    childrenElements.append("                \(initializer)")
                }
            }
            let childrenBody = childrenElements.joined(separator: ",\n")

            // Generate the term struct
            results.append("""
            public struct \(raw: termStructName): \(raw: conformanceList) {
                public let name: String = \(raw: "\"\(term.name)\"")
                public let iri: IRIKit.IRI
                public let kind: RDFCore.TermKind = \(raw: term.kindEnum)

                public init(_ iri: IRIKit.IRI) {
                    self.iri = iri
                }

                public var children: [any RDFCore.Node] {
                    [
            \(raw: childrenBody)
                    ]
                }

                public func callAsFunction() -> \(raw: termStructName) { self }
            }
            """)

            results.append("""
            public static let \(raw: staticName) = \(raw: termStructName)(\(raw: "\"\(iriString)\""))
            """)
        }

        return results
    }
}

// MARK: - Parsed Types

struct ParsedTerm {
    let name: String
    let kind: TermKindValue
    let annotations: [ParsedAnnotation]

    var kindEnum: String {
        switch kind {
        case .class: return ".class"
        case .property: return ".property"
        case .individual: return ".individual"
        case .datatype: return ".datatype"
        }
    }
}

enum TermKindValue {
    case `class`
    case property
    case individual
    case datatype
}

struct ParsedAnnotation {
    let name: String
    /// The raw argument text from the DSL call, e.g. "RDFS.Class" or "\"Class\""
    let argumentText: String

    /// The ContributionAnnotation type name, derived from the function name.
    /// Convention: `{FunctionName}AnnotationValue`
    var contributionTypeName: String? {
        switch name {
        case "isDeclaredBy": return "IsDeclaredByAnnotation"
        case "OWLDeprecated": return "OWLDeprecatedAnnotationValue"
        default: return "\(name)AnnotationValue"
        }
    }

    /// The contribution protocol name, derived from the function name.
    /// Convention matches what ContributionAnnotation provides on value types.
    var contributionProtocol: String? {
        switch name {
        case "Type": return "TypedTerm"
        case "SubClassOf": return "SubClassedTerm"
        case "SubPropertyOf": return "SubPropertyOfTerm"
        case "Domain": return "DomainTerm"
        case "Range": return "RangeTerm"
        case "Label": return "LabeledTerm"
        case "Comment": return "CommentedTerm"
        case "SeeAlso": return "SeeAlsoTerm"
        case "OWLDeprecated": return "DeprecatedTerm"
        case "isDeclaredBy": return "DeclaredByTerm"
        default: return nil
        }
    }

    var childrenInitializer: String? {
        guard let typeName = contributionTypeName else { return nil }
        if name == "OWLDeprecated" {
            return "\(typeName)()"
        }
        return "\(typeName)(\(argumentText))"
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

        guard let calledName else { continue }

        let kind: TermKindValue
        switch calledName {
        case "Class": kind = .class
        case "Property": kind = .property
        case "Datatype": kind = .datatype
        default: continue
        }

        guard let firstArg = calledExpr.arguments.first,
              let nameLiteral = firstArg.expression.as(StringLiteralExprSyntax.self),
              let nameSegment = nameLiteral.segments.first?.as(StringSegmentSyntax.self) else {
            continue
        }

        let name = nameSegment.content.text

        // Parse annotations from the trailing closure
        let annotations = extractAnnotations(from: calledExpr)

        terms.append(ParsedTerm(name: name, kind: kind, annotations: annotations))
    }

    return terms
}

private func extractAnnotations(from call: FunctionCallExprSyntax) -> [ParsedAnnotation] {
    guard let trailingClosure = call.trailingClosure else {
        return []
    }

    let codeBlock = trailingClosure.statements

    var annotations: [ParsedAnnotation] = []

    for statement in codeBlock {
        guard let expr = statement.item.as(ExprSyntax.self) else {
            continue
        }

        let (baseExpr, _) = unwrapChainedCalls(expr)

        guard let baseExpr, let innerCall = baseExpr.as(FunctionCallExprSyntax.self) else {
            continue
        }

        let funcName = innerCall.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text
        guard let funcName else { continue }

        let knownAnnotations: Set<String> = [
            "Type", "SubClassOf", "SubPropertyOf", "Domain", "Range",
            "Label", "Comment", "SeeAlso", "OWLDeprecated", "isDeclaredBy"
        ]

        guard knownAnnotations.contains(funcName) else { continue }

        let argumentText: String
        if funcName == "OWLDeprecated" || funcName == "isDeclaredBy" {
            argumentText = innerCall.arguments.description.trimmingCharacters(in: .whitespaces)
        } else if let firstArg = innerCall.arguments.first {
            argumentText = firstArg.expression.description.trimmingCharacters(in: .whitespaces)
        } else {
            argumentText = ""
        }

        annotations.append(ParsedAnnotation(name: funcName, argumentText: argumentText))
    }

    return annotations
}

/// Unwraps chained method calls like `.isDeclaredBy(namespace: X)` or `.deprecated()`.
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

// MARK: - Identifier Sanitization

private let swiftKeywords: Set<String> = [
    "nil", "self", "true", "false", "class", "struct", "enum",
    "protocol", "func", "let", "var", "if", "else", "switch",
    "case", "default", "for", "while", "repeat", "return",
    "break", "continue", "import", "public", "private",
    "internal", "fileprivate", "static", "final", "lazy",
    "weak", "unowned", "required", "convenience", "override",
    "mutating", "nonmutating", "throws", "rethrows", "try",
    "catch", "guard", "defer", "where", "associatedtype",
    "typealias", "extension", "subscript", "operator",
    "Type", "Protocol", "Self", "Any", "Void"
]

/// Sanitizes a term name for use as a Swift property identifier.
/// Replaces hyphens with underscores. Capitalizes leading lowercase
/// letters that would clash with Swift keywords.
func sanitizePropertyName(_ name: String) -> String {
    var result = name.replacingOccurrences(of: "-", with: "_")
    result = result.replacingOccurrences(of: ".", with: "_")
    if swiftKeywords.contains(result) {
        result = result.prefix(1).uppercased() + result.dropFirst()
    }
    return result
}

/// Sanitizes a term name for use as a Swift type identifier (struct name).
/// Replaces hyphens and dots with underscores. Capitalizes leading lowercase
/// letters that would clash with Swift keywords.
func sanitizeTypeName(_ name: String) -> String {
    var result = name.replacingOccurrences(of: "-", with: "_")
    result = result.replacingOccurrences(of: ".", with: "_")
    if swiftKeywords.contains(result.lowercased()) {
        result = result.prefix(1).uppercased() + result.dropFirst()
    }
    return result
}

// MARK: - Errors

struct VocabularyError: Error, CustomStringConvertible {
    let message: String

    var description: String { message }

    init(_ message: String) {
        self.message = message
    }
}
