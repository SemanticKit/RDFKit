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

    /// The Swift name of a resolved term, qualified by its ontology:
    /// `Fauna.Habitat`.
    func name(of reference: TermReference) -> QualifiedName {
        switch reference {
        case .local(let name): QualifiedName(typeName, name)
        case .external(let spelling): QualifiedName(spelling: spelling)
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
}

enum SwiftIdentifier {
    /// A local name made into a Swift identifier: `version-1.0` becomes `version_1_0`.
    static func sanitized(_ name: String) -> String {
        let mapped = name.map { $0.isLetter || $0.isNumber || $0 == "_" ? $0 : "_" }
        var result = String(mapped)
        if let first = result.first, first.isNumber { result = "_" + result }
        return result
    }
}

extension TermReference {
    var localName: String? {
        if case .local(let name) = self { return name }
        return nil
    }
}
