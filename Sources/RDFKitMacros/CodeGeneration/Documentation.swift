import Foundation

/// DocC comments, `@available` attributes and metadata literals generated
/// from `Label`, `Comment` and `Deprecated`.
enum Documentation {
    /// `/// ...` lines for a declaration's `Comment`, then
    /// `@available(*, deprecated)` when it is `Deprecated()`, indented to
    /// `indent`.
    static func docComment(for declaration: ParsedEntity, indent: String = "") -> String {
        var result = ""
        if let comment = declaration.text("Comment") {
            result = comment
                .split(separator: "\n", omittingEmptySubsequences: false)
                .map { "\(indent)/// \($0)\n" }
                .joined()
        }
        if let deprecated = declaration.annotations("Deprecated").first {
            if let message = deprecated.text {
                result += "\(indent)@available(*, deprecated, message: \(literal(message)))\n"
            } else {
                result += "\(indent)@available(*, deprecated)\n"
            }
        }
        return result
    }

    /// The `RDFMetadata(...)` expression for a local term.
    static func metadata(for declaration: ParsedEntity, in ontology: ParsedOntology) -> String {
        var arguments = [
            "id: \(literal(ontology.iri(of: declaration.name)))",
            "name: \(literal(declaration.name))",
        ]
        if let label = declaration.text("Label") { arguments.append("label: \(literal(label))") }
        if let comment = declaration.text("Comment") { arguments.append("comment: \(literal(comment))") }
        return "RDFCore.RDFMetadata(\(arguments.joined(separator: ", ")))"
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
