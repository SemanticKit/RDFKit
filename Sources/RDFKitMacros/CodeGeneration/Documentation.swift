import SwiftSpelling
import SwiftSyntax
import SwiftSyntaxBuilder

/// DocC comments and `@available` attributes generated from `Label`,
/// `Comment` and `Deprecated`.
enum Documentation {
    /// `///` lines for a declaration's `Label` and `Comment`, one paragraph
    /// each, as `RDFTranslatorPlugin` documents `rdfs:label` and
    /// `rdfs:comment`.
    static func trivia(for declaration: ParsedEntity) -> Trivia {
        let paragraphs = (declaration.annotations("Label") + declaration.annotations("Comment")).compactMap(\.text).map { text in
            text.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        }
        return .documentation(Array(paragraphs.joined(separator: [""])))
    }

    /// `@available(*, deprecated)`, with the reason as its message, when the
    /// declaration is `Deprecated`.
    static func attributes(for declaration: ParsedEntity) -> AttributeListSyntax {
        guard let deprecated = declaration.annotations("Deprecated").first else { return [] }
        var arguments: [AvailabilityArgumentSyntax.Argument] = [.token(.binaryOperator("*")), .token(.keyword(.deprecated))]
        if let message = deprecated.text {
            arguments.append(.availabilityLabeledArgument(AvailabilityLabeledArgumentSyntax(
                label: .keyword(.message),
                value: .string(SimpleStringLiteralExprSyntax(value: message))
            )))
        }
        return [.attribute(AttributeSyntax(
            attributeName: IdentifierTypeSyntax(name: .identifier("available")),
            leftParen: .leftParenToken(),
            arguments: .availability(AvailabilityArgumentListSyntax(arguments.enumerated().map { index, argument in
                AvailabilityArgumentSyntax(argument: argument, trailingComma: index < arguments.count - 1 ? .commaToken() : nil)
            })),
            rightParen: .rightParenToken(),
            trailingTrivia: .newline
        ))]
    }
}
