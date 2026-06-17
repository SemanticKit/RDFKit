import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

/// A macro that reads the ontology content tree and generates real Swift types.
///
/// Class-level concerns (static): name, iri, kind
/// Instance-level concerns: id, children, domain properties
public struct VocabularyMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo types: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.is(StructDeclSyntax.self) else {
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
        let ontologyName = declaration.as(StructDeclSyntax.self)?.name.text ?? ""

        // Meta-ontologies define vocabulary, not domain types — skip consumer structs
        let metaOntologies: Set<String> = ["RDF", "RDFS", "OWL"]
        let generateConsumerTypes = !metaOntologies.contains(ontologyName)

        guard let namespace = extractNamespace(from: body) else {
            throw VocabularyError("Content must include a Namespace(\"...\") declaration")
        }

        let terms = extractTerms(from: body)

        // Collect class names defined in THIS ontology
        let localClassNames: Set<String> = Set(
            terms.filter { $0.kind == .class }.map { sanitizeTypeName($0.name) }
        )

        // Build property mapping: className -> [(propName, rangeType)]
        var classProperties: [String: [(propertyName: String, rangeType: String)]] = [:]

        for term in terms where term.kind == .property {
            guard let domain = term.annotations.first(where: { $0.name == "Domain" })?.argumentText,
                  let range = term.annotations.first(where: { $0.name == "Range" })?.argumentText else {
                continue
            }

            let className = sanitizeTypeName(lastComponent(of: domain))
            guard localClassNames.contains(className) else { continue }

            let rangeTypeName = lastComponent(of: range.trimmingCharacters(in: .whitespaces))
            guard className != rangeTypeName else { continue }

            let propName = derivePropertyName(from: term.name)
            let swiftType = mapRangeToSwiftType(range, currentOntology: ontologyName)

            classProperties[className, default: []].append((propName, swiftType))
        }

        var results: [DeclSyntax] = []

        for term in terms {
            let iriString = "\(namespace)\(term.name)"
            let swiftName = sanitizeTypeName(term.name)
            let termStructName = "\(swiftName)Term"
            let staticName = sanitizePropertyName(term.name)

            // Build contribution protocol conformances
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

            // Build children from annotations
            var childrenElements: [String] = []
            for annotation in term.annotations {
                if let initializer = annotation.childrenInitializer {
                    childrenElements.append("                    \(initializer)")
                }
            }
            let childrenBody = childrenElements.joined(separator: ",\n")

            let props = classProperties[swiftName] ?? []

            if generateConsumerTypes && term.kind == .class {
                // --- Consumer type: the real type users interact with ---
                var storedProps: [String] = []
                var initParams: [String] = []

                for prop in props {
                    storedProps.append("        public let \(prop.propertyName): \(prop.rangeType)")
                    initParams.append("\(prop.propertyName): \(prop.rangeType) = \(prop.rangeType)()")
                }

                let storedBlock = storedProps.isEmpty ? "" : "\n\(storedProps.joined(separator: "\n"))\n"
                let initBlock = initParams.isEmpty ? "" : "\n                    \(initParams.joined(separator: ",\n                    "))\n"

                results.append("""
                public struct \(raw: swiftName) {\(raw: storedBlock)
                    public init() {\(raw: initBlock)    }

                    public func callAsFunction() -> \(raw: swiftName) { self }
                }
                """)

                // Static property for DSL references: Fauna.Animal
                results.append("""
                public static let \(raw: staticName) = \(raw: swiftName)()
                """)
            } else {
                // --- Backing type: internal DSL plumbing for properties/individuals ---
                results.append("""
                public struct \(raw: termStructName): \(raw: conformanceList) {
                    public static let name: String = \(raw: "\"\(term.name)\"")
                    public static let iri: IRIKit.IRI = \(raw: "\"\(iriString)\"")
                    public static let kind: RDFCore.TermKind = \(raw: term.kindEnum)

                    public let id: IRIKit.IRI

                    public init(id: IRIKit.IRI = \(raw: "\"\(iriString)\"")) {
                        self.id = id
                    }

                    public var children: [any RDFCore.Node] {
                        [
                        \(raw: childrenBody)
                        ]
                    }
                }
                """)
            }
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
    let argumentText: String

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

    var contributionTypeName: String? {
        switch name {
        case "isDeclaredBy": return "IsDeclaredByAnnotation"
        case "OWLDeprecated": return "OWLDeprecatedAnnotationValue"
        default: return "\(name)AnnotationValue"
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

// MARK: - Parsing Helpers

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

private func extractTerms(from body: CodeBlockSyntax) -> [ParsedTerm] {
    var terms: [ParsedTerm] = []
    for statement in body.statements {
        guard let expr = statement.item.as(ExprSyntax.self) else { continue }
        let (termCall, _) = unwrapChainedCalls(expr)
        guard let termCall, let calledExpr = termCall.as(FunctionCallExprSyntax.self) else { continue }
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
              let nameSegment = nameLiteral.segments.first?.as(StringSegmentSyntax.self) else { continue }
        let name = nameSegment.content.text
        let annotations = extractAnnotations(from: calledExpr)
        terms.append(ParsedTerm(name: name, kind: kind, annotations: annotations))
    }
    return terms
}

private func extractAnnotations(from call: FunctionCallExprSyntax) -> [ParsedAnnotation] {
    guard let trailingClosure = call.trailingClosure else { return [] }
    var annotations: [ParsedAnnotation] = []
    for statement in trailingClosure.statements {
        guard let expr = statement.item.as(ExprSyntax.self) else { continue }
        let (baseExpr, _) = unwrapChainedCalls(expr)
        guard let baseExpr, let innerCall = baseExpr.as(FunctionCallExprSyntax.self) else { continue }
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

// MARK: - Name Helpers

private func lastComponent(of dottedName: String) -> String {
    dottedName.components(separatedBy: ".").last ?? dottedName
}

private func derivePropertyName(from rdfName: String) -> String {
    var result: String
    if rdfName.hasPrefix("has") && rdfName.count > 3 {
        let stripped = rdfName.dropFirst(3)
        result = stripped.prefix(1).lowercased() + stripped.dropFirst()
    } else {
        result = rdfName.prefix(1).lowercased() + rdfName.dropFirst()
    }
    // Sanitize Swift keywords
    if swiftKeywords.contains(result) {
        result = result + "Value"
    }
    return result
}

private let swiftKeywords: Set<String> = [
    "self", "super", "class", "return", "if", "else", "switch",
    "case", "default", "for", "while", "repeat", "break",
    "continue", "import", "let", "var", "func", "type",
    "protocol", "extension", "operator", "nil", "true", "false",
    "Any", "Self", "Void", "Type", "associatedtype", "where"
]

private func mapRangeToSwiftType(_ range: String, currentOntology: String) -> String {
    let trimmed = range.trimmingCharacters(in: .whitespaces)

    // IRI literals are string values
    if trimmed.hasPrefix("IRI(") {
        return "String"
    }

    // Literal maps to String
    if trimmed.contains("Literal") || trimmed.contains("string") {
        return "String"
    }

    let parts = trimmed.components(separatedBy: ".")
    if parts.count == 2 {
        let prefix = parts[0]
        let name = sanitizeTypeName(parts[1])
        if prefix == currentOntology {
            // Local reference — use consumer type name (no Term suffix)
            return name
        } else {
            // Cross-ontology — use term struct (backing layer)
            return "\(prefix).\(name)Term"
        }
    }
    return "\(sanitizeTypeName(trimmed))Term"
}

// MARK: - Identifier Sanitization

func sanitizePropertyName(_ name: String) -> String {
    var result = name.replacingOccurrences(of: "-", with: "_")
    result = result.replacingOccurrences(of: ".", with: "_")
    return result
}

func sanitizeTypeName(_ name: String) -> String {
    var result = name.replacingOccurrences(of: "-", with: "_")
    result = result.replacingOccurrences(of: ".", with: "_")
    return result.prefix(1).uppercased() + result.dropFirst()
}

// MARK: - Errors

struct VocabularyError: Error, CustomStringConvertible {
    let message: String
    var description: String { message }
    init(_ message: String) { self.message = message }
}
