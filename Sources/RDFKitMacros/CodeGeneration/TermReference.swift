import Foundation

/// A term named in an annotation, resolved against the ontology being expanded.
enum TermReference: Equatable {
    /// A term this ontology declares, by local name.
    case local(String)
    /// A term of another ontology (or any other Swift type), as spelled.
    case external(String)
}

extension ParsedOntology {
    /// Resolves a term spelling: `Fauna.Habitat`, `Self.Habitat` and `Habitat`
    /// all name the local term `Habitat` inside `Fauna`.
    func resolve(_ spelling: String) -> TermReference {
        let trimmed = spelling.trimmingCharacters(in: .whitespaces)
        for prefix in ["\(typeName).", "Self."] where trimmed.hasPrefix(prefix) {
            let local = String(trimmed.dropFirst(prefix.count))
            if !local.contains(".") { return .local(local) }
        }
        if !trimmed.contains("."), declarations.contains(where: { $0.name == trimmed }) {
            return .local(trimmed)
        }
        return .external(trimmed)
    }

    /// The Swift spelling of a resolved term, qualified by its ontology.
    func spelling(of reference: TermReference) -> String {
        switch reference {
        case .local(let name): return "\(typeName).\(SwiftIdentifier.escaped(name))"
        case .external(let spelling): return spelling
        }
    }

    /// The qualified spelling of a term, `Fauna.Habitat` for the local term
    /// `Habitat` however it was written, so that RDF, RDFS and OWL terms are
    /// recognised the same way inside and outside their own ontology.
    func canonical(_ spelling: String) -> String {
        switch resolve(spelling) {
        case .local(let name): "\(typeName).\(name)"
        case .external(let spelling): spelling
        }
    }

    /// The boundary IRI of a local term: the namespace followed by the local
    /// name, computed once here at expansion time and emitted as a literal.
    func iri(of name: String) -> String {
        namespace + name
    }
}

enum SwiftIdentifier {
    private static let keywords: Set<String> = [
        "associatedtype", "class", "deinit", "enum", "extension", "fileprivate", "func",
        "import", "init", "inout", "internal", "let", "open", "operator", "private",
        "precedencegroup", "protocol", "public", "rethrows", "static", "struct",
        "subscript", "typealias", "var", "break", "case", "catch", "continue", "default",
        "defer", "do", "else", "fallthrough", "for", "guard", "if", "in", "repeat",
        "return", "throw", "switch", "where", "while", "Any", "as", "await", "false",
        "is", "nil", "self", "Self", "super", "throws", "true", "try", "Type", "Protocol",
    ]

    /// A local name made into a Swift identifier: `version-1.0` becomes `version_1_0`.
    static func sanitized(_ name: String) -> String {
        let mapped = name.map { $0.isLetter || $0.isNumber || $0 == "_" ? $0 : "_" }
        var result = String(mapped)
        if let first = result.first, first.isNumber { result = "_" + result }
        return result
    }

    /// A sanitized identifier, in backticks when it is a keyword.
    static func escaped(_ name: String) -> String {
        let identifier = sanitized(name)
        return keywords.contains(identifier) ? "`\(identifier)`" : identifier
    }
}

extension TermReference {
    var localName: String? {
        if case .local(let name) = self { return name }
        return nil
    }
}
