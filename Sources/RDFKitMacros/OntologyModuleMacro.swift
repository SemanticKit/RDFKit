import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

/// Expands an ontology root into module-visible peer declarations.
public struct OntologyModuleMacro: PeerMacro {
    /// Expands the attached ontology root.
    public static func expansion(
        of _: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let contentBody = contentBody(in: declaration) else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(declaration),
                    message: OntologyModuleDiagnostic.malformedRoot
                )
            )
            return []
        }

        var parser = OntologyModuleBodyParser(context: context)
        let terms = parser.parseRoot(contentBody)

        guard !parser.diagnosedError else {
            return []
        }

        var declarations: [DeclSyntax] = []
        var diagnosedEmissionError = false
        let rolePrefix = roleNamePrefix(for: declaration)

        for (index, term) in terms.enumerated() {
            guard let identifier = swiftIdentifier(for: term.name) else {
                context.diagnose(
                    Diagnostic(
                        node: term.node,
                        message: OntologyModuleDiagnostic.invalidIdentifier(term.name)
                    )
                )
                diagnosedEmissionError = true
                continue
            }

            let roleName = "\(rolePrefix)\(index)"
            let documentedName = documentationText(for: term.name)

            declarations.append(
                DeclSyntax(
                    stringLiteral: """
                    /// Role metadata for the `\(documentedName)` ontology term.
                    enum \(roleName): DeclaredOntologyTerm {
                        /// The term name exactly as authored in the ontology declaration.
                        static let ontologyTermName = \(term.name.debugDescription)
                    }
                    """
                )
            )

            declarations.append(
                DeclSyntax(
                    stringLiteral: """
                    /// Direct content declaration bound to the `\(documentedName)` ontology term.
                    typealias \(identifier)<Body: Content> = NamedDeclaration<\(roleName), Body>
                    """
                )
            )
        }

        if diagnosedEmissionError {
            return []
        }

        return declarations
    }

    /// Returns the attached ontology root type name when one exists.
    private static func ontologyRootName(for declaration: some DeclSyntaxProtocol) -> String? {
        if let structDeclaration = declaration.as(StructDeclSyntax.self) {
            return structDeclaration.name.text
        }

        if let classDeclaration = declaration.as(ClassDeclSyntax.self) {
            return classDeclaration.name.text
        }

        if let actorDeclaration = declaration.as(ActorDeclSyntax.self) {
            return actorDeclaration.name.text
        }

        if let enumDeclaration = declaration.as(EnumDeclSyntax.self) {
            return enumDeclaration.name.text
        }

        return nil
    }

    /// Finds the computed `content: some Content` body on the attached root.
    private static func contentBody(in declaration: some DeclSyntaxProtocol) -> CodeBlockItemListSyntax? {
        guard let memberBlock = memberBlock(in: declaration) else {
            return nil
        }

        for member in memberBlock.members {
            guard let variable = member.decl.as(VariableDeclSyntax.self) else {
                continue
            }

            for binding in variable.bindings {
                guard
                    let pattern = binding.pattern.as(IdentifierPatternSyntax.self),
                    pattern.identifier.text == "content",
                    let type = binding.typeAnnotation?.type,
                    type.trimmedDescription == "some Content",
                    let accessorBlock = binding.accessorBlock
                else {
                    continue
                }

                switch accessorBlock.accessors {
                case .getter(let statements):
                    return statements
                case .accessors(let accessors):
                    for accessor in accessors {
                        guard accessor.accessorSpecifier.tokenKind == .keyword(.get) else {
                            continue
                        }
                        return accessor.body?.statements
                    }
                }
            }
        }

        return nil
    }

    /// Returns the generated role-name prefix for the attached declaration.
    private static func roleNamePrefix(for declaration: some DeclSyntaxProtocol) -> String {
        let declarationName = ontologyRootName(for: declaration) ?? "Root"

        return "__RDFKitOntologyTerm_\(declarationName)_"
    }

    /// Returns the member block for declarations that can contain members.
    private static func memberBlock(in declaration: some DeclSyntaxProtocol) -> MemberBlockSyntax? {
        if let structDeclaration = declaration.as(StructDeclSyntax.self) {
            return structDeclaration.memberBlock
        }

        if let classDeclaration = declaration.as(ClassDeclSyntax.self) {
            return classDeclaration.memberBlock
        }

        if let actorDeclaration = declaration.as(ActorDeclSyntax.self) {
            return actorDeclaration.memberBlock
        }

        if let enumDeclaration = declaration.as(EnumDeclSyntax.self) {
            return enumDeclaration.memberBlock
        }

        return nil
    }

    /// Returns a Swift identifier spelling for a term name when one exists.
    private static func swiftIdentifier(for name: String) -> String? {
        guard !name.isEmpty else {
            return nil
        }

        let scalars = Array(name.unicodeScalars)
        guard isIdentifierHead(scalars[0]) else {
            return nil
        }

        guard scalars.dropFirst().allSatisfy(isIdentifierBody(_:)) else {
            return nil
        }

        if escapedKeywords.contains(name) {
            return "`\(name)`"
        }

        return name
    }

    /// Returns whether a scalar may start a generated ASCII identifier.
    private static func isIdentifierHead(_ scalar: Unicode.Scalar) -> Bool {
        scalar == "_" || ("A"..."Z").contains(String(scalar)) || ("a"..."z").contains(String(scalar))
    }

    /// Returns whether a scalar may continue a generated ASCII identifier.
    private static func isIdentifierBody(_ scalar: Unicode.Scalar) -> Bool {
        isIdentifierHead(scalar) || ("0"..."9").contains(String(scalar))
    }

    /// Returns text that is safe to interpolate into a line documentation comment.
    private static func documentationText(for text: String) -> String {
        text.replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
    }

    /// Swift keywords that require backticks when generated as identifiers.
    private static let escapedKeywords: Set<String> = [
        "Any", "Protocol", "Self", "Type", "actor", "as", "associatedtype",
        "async", "await", "break", "case", "catch", "class", "continue",
        "default", "defer", "deinit", "do", "else", "enum", "extension",
        "fallthrough", "false", "fileprivate", "for", "func", "guard", "if",
        "import", "in", "init", "inout", "internal", "is", "let", "nil",
        "open", "operator", "private", "protocol", "public", "repeat",
        "rethrows", "return", "self", "some", "static", "struct", "subscript",
        "super", "switch", "throw", "throws", "true", "try", "typealias",
        "var", "where", "while"
    ]

}

/// Parses the fixed RDFKit ontology DSL grammar inside `content`.
private struct OntologyModuleBodyParser {
    /// The macro expansion context used to emit diagnostics.
    private let context: any MacroExpansionContext

    /// Whether parsing emitted at least one error diagnostic.
    private(set) var diagnosedError = false

    /// Creates a parser for one ontology macro expansion.
    init(context: some MacroExpansionContext) {
        self.context = context
    }

    /// Parses the root content body and returns declared terms in source order.
    mutating func parseRoot(_ statements: CodeBlockItemListSyntax) -> [OntologyModuleTerm] {
        var terms: [OntologyModuleTerm] = []

        for statement in statements {
            guard let expression = statement.item.as(ExprSyntax.self) else {
                diagnoseMalformedBody(at: Syntax(statement))
                continue
            }

            parseRootExpression(expression, into: &terms)
        }

        return terms
    }

    /// Parses one root-level expression.
    private mutating func parseRootExpression(_ expression: ExprSyntax, into terms: inout [OntologyModuleTerm]) {
        if isPrefixExpression(expression) {
            return
        }

        guard let call = expression.as(FunctionCallExprSyntax.self) else {
            diagnoseMalformedBody(at: Syntax(expression))
            return
        }

        parseDeclaration(call, into: &terms)
    }

    /// Parses a root declaration call from the authored DSL shape.
    private mutating func parseDeclaration(
        _ call: FunctionCallExprSyntax,
        into terms: inout [OntologyModuleTerm]
    ) {
        guard
            call.arguments.count == 1,
            let firstArgument = call.arguments.first,
            firstArgument.label == nil,
            let nameLiteral = firstArgument.expression.as(StringLiteralExprSyntax.self),
            let name = stringValue(from: nameLiteral)
        else {
            diagnoseMalformedBody(at: Syntax(call))
            return
        }

        terms.append(OntologyModuleTerm(name: name, node: Syntax(nameLiteral)))
    }

    /// Returns whether an expression is ontology prefix metadata accepted by the grammar.
    private func isPrefixExpression(_ expression: ExprSyntax) -> Bool {
        if let memberAccess = expression.as(MemberAccessExprSyntax.self) {
            return memberAccess.base?.trimmedDescription == "Prefix"
        }

        guard let call = expression.as(FunctionCallExprSyntax.self), calleeName(for: call) == "Prefix" else {
            return false
        }

        guard call.arguments.count == 2 else {
            return false
        }

        for argument in call.arguments {
            guard
                argument.label == nil,
                let literal = argument.expression.as(StringLiteralExprSyntax.self),
                stringValue(from: literal) != nil
            else {
                return false
            }
        }

        return true
    }

    /// Returns the simple callee name for direct calls in the DSL.
    private func calleeName(for call: FunctionCallExprSyntax) -> String? {
        if let reference = call.calledExpression.as(DeclReferenceExprSyntax.self) {
            return reference.baseName.text
        }

        if let memberAccess = call.calledExpression.as(MemberAccessExprSyntax.self) {
            return memberAccess.declName.baseName.text
        }

        return nil
    }

    /// Extracts a static string literal value.
    private func stringValue(from literal: StringLiteralExprSyntax) -> String? {
        var value = ""

        for segment in literal.segments {
            switch segment {
            case .stringSegment(let stringSegment):
                value += stringSegment.content.text
            default:
                return nil
            }
        }

        return value
    }

    /// Emits a malformed-body diagnostic at the syntax node.
    private mutating func diagnoseMalformedBody(at node: Syntax) {
        diagnosedError = true
        context.diagnose(
            Diagnostic(
                node: node,
                message: OntologyModuleDiagnostic.malformedBody
            )
        )
    }

}

/// A term declaration found in an ontology body.
private struct OntologyModuleTerm {
    /// The declared ontology term name.
    let name: String

    /// The syntax node that authored the term name.
    let node: Syntax
}

/// Diagnostics emitted by `OntologyModuleMacro`.
private struct OntologyModuleDiagnostic: DiagnosticMessage {
    /// The diagnostic message text.
    let message: String

    /// The stable diagnostic identifier.
    let diagnosticID: MessageID

    /// The diagnostic severity.
    let severity: DiagnosticSeverity

    /// A malformed root diagnostic.
    static let malformedRoot = OntologyModuleDiagnostic(
        message: "@OntologyModule requires an ontology root with a computed `content: some Content` body.",
        diagnosticID: MessageID(domain: "RDFKitMacros", id: "malformedRoot"),
        severity: .error
    )

    /// A malformed body diagnostic.
    static let malformedBody = OntologyModuleDiagnostic(
        message: "@OntologyModule only supports the fixed RDFKit ontology DSL body grammar.",
        diagnosticID: MessageID(domain: "RDFKitMacros", id: "malformedBody"),
        severity: .error
    )

    /// Creates an invalid-identifier diagnostic.
    static func invalidIdentifier(_ name: String) -> OntologyModuleDiagnostic {
        OntologyModuleDiagnostic(
            message: "Ontology term name `\(name)` cannot be emitted as a Swift peer declaration identifier.",
            diagnosticID: MessageID(domain: "RDFKitMacros", id: "invalidIdentifier"),
            severity: .error
        )
    }

}
