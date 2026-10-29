import Foundation

/// DocC comments and metadata literals generated from `Label` and `Comment`.
enum Documentation {
    /// `/// ...` lines for a declaration's `Comment`, indented to `indent`.
    static func docComment(for declaration: ParsedEntity, indent: String = "") -> String {
        guard let comment = declaration.text("Comment") else { return "" }
        let text = comment
            .replacingOccurrences(of: "\\\"", with: "\"")
            .replacingOccurrences(of: "\\\\", with: "\\")
        return text
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { "\(indent)/// \($0)\n" }
            .joined()
    }

    /// The `RDFMetadata(...)` expression for a local term.
    static func metadata(for declaration: ParsedEntity, in ontology: ParsedOntology) -> String {
        var arguments = [
            "id: \"\(ontology.iri(of: declaration.name))\"",
            "name: \"\(declaration.name)\"",
        ]
        if let label = declaration.text("Label") { arguments.append("label: \"\(label)\"") }
        if let comment = declaration.text("Comment") { arguments.append("comment: \"\(comment)\"") }
        return "RDFCore.RDFMetadata(\(arguments.joined(separator: ", ")))"
    }
}
