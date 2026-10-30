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
        var arguments: [AvailabilityArgumentSyntax] = [
            AvailabilityArgumentSyntax(argument: .token(.binaryOperator("*")), trailingComma: .commaToken()),
            AvailabilityArgumentSyntax(argument: .token(.keyword(.deprecated))),
        ]
        if let message = deprecated.text {
            arguments[1] = arguments[1].with(\.trailingComma, .commaToken())
            arguments.append(AvailabilityArgumentSyntax(argument: .availabilityLabeledArgument(AvailabilityLabeledArgumentSyntax(
                label: .keyword(.message),
                value: .string(SimpleStringLiteralExprSyntax(
                    openingQuote: .stringQuoteToken(),
                    segments: SimpleStringLiteralSegmentListSyntax([StringSegmentSyntax(content: .stringSegment(escaped(message)))]),
                    closingQuote: .stringQuoteToken()
                ))
            ))))
        }
        return [.attribute(AttributeSyntax(
            attributeName: IdentifierTypeSyntax(name: .identifier("available")),
            leftParen: .leftParenToken(),
            arguments: .availability(AvailabilityArgumentListSyntax(arguments)),
            rightParen: .rightParenToken(),
            trailingTrivia: .newline
        ))]
    }

    /// The text of a string literal segment whose value is `value`: an
    /// availability message is a plain literal, never a raw one.
    private static func escaped(_ value: String) -> String {
        var result = ""
        for scalar in value.unicodeScalars {
            switch scalar {
            case "\\": result += "\\\\"
            case "\"": result += "\\\""
            case "\n": result += "\\n"
            case "\r": result += "\\r"
            case "\t": result += "\\t"
            case "\0": result += "\\0"
            default:
                if scalar.value < 0x20 || scalar.value == 0x7F {
                    result += "\\u{" + String(scalar.value, radix: 16) + "}"
                } else {
                    result.unicodeScalars.append(scalar)
                }
            }
        }
        return result
    }
}
