import Foundation

/// DocC comments, `@available` attributes and string literals generated
/// from `Label`, `Comment` and `Deprecated`.
enum Documentation {
    /// `/// ...` lines for a declaration's `Label` and `Comment`, one
    /// paragraph each, as `RDFTranslatorPlugin` documents `rdfs:label` and
    /// `rdfs:comment`, then `@available(*, deprecated)` when it is
    /// `Deprecated()`, indented to `indent`.
    static func docComment(for declaration: ParsedEntity, indent: String = "") -> String {
        let paragraphs = (declaration.annotations("Label") + declaration.annotations("Comment")).compactMap(\.text).map { text in
            text.split(separator: "\n", omittingEmptySubsequences: false)
                .map { $0.isEmpty ? "\(indent)///\n" : "\(indent)/// \($0)\n" }
                .joined()
        }
        var result = paragraphs.joined(separator: "\(indent)///\n")
        if let deprecated = declaration.annotations("Deprecated").first {
            if let message = deprecated.text {
                result += "\(indent)@available(*, deprecated, message: \(literal(message)))\n"
            } else {
                result += "\(indent)@available(*, deprecated)\n"
            }
        }
        return result
    }

    /// A single-line Swift string literal whose value is `value`.
    ///
    /// Annotation text arrives with its escapes resolved, whatever literal
    /// form the source used (`"..."`, `"""..."""`, `#"..."#`), so it is
    /// re-escaped here rather than pasted between quotes.
    static func literal(_ value: String) -> String {
        var result = "\""
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
                    result += "\\u{\(String(scalar.value, radix: 16))}"
                } else {
                    result.unicodeScalars.append(scalar)
                }
            }
        }
        return result + "\""
    }
}
