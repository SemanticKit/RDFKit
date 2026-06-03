import Foundation

/// Encodes RDF graphs into Turtle source.
struct TurtleEncoder {
    private let prefixes: [String: IRI]
    private let baseIRI: IRI?

    /// Creates a Turtle graph encoder.
    init(prefixes: [String: IRI], baseIRI: IRI?) {
        self.prefixes = prefixes
        self.baseIRI = baseIRI
    }

    /// Encodes a graph as Turtle source.
    func encode(graph: Graph) -> String {
        var lines: [String] = []
        if let base = baseIRI {
            lines.append("@base <\(base.string)> .")
        }
        for (prefix, iri) in prefixes.sorted(by: { $0.key < $1.key }) {
            lines.append("@prefix \(prefix): <\(iri.string)> .")
        }

        let sortedTriples = graph.triples.sorted { lhs, rhs in
            let ls = lhs.subject.description
            let rs = rhs.subject.description
            if ls != rs { return ls < rs }
            let lp = lhs.predicate.string
            let rp = rhs.predicate.string
            if lp != rp { return lp < rp }
            return lhs.object.description < rhs.object.description
        }

        for triple in sortedTriples {
            let subject = formatSubject(triple.subject)
            let predicate = formatPredicate(triple.predicate)
            let object = formatObject(triple.object)
            lines.append("\(subject) \(predicate) \(object) .")
        }

        return lines.joined(separator: "\n")
    }

    private func formatSubject(_ subject: AnyRDFSubject) -> String {
        if let iri = subject.node as? IRI {
            return formatIri(iri)
        }
        if let blank = subject.node as? BlankNode {
            return "_:\(blank.identifier)"
        }
        return subject.description
    }

    private func formatPredicate(_ predicate: IRI) -> String {
        if predicate == RDF.type {
            return "a"
        }
        return formatIri(predicate)
    }

    private func formatObject(_ object: AnyRDFObject) -> String {
        if let iri = object.node as? IRI {
            return formatIri(iri)
        }
        if let blank = object.node as? BlankNode {
            return "_:\(blank.identifier)"
        }
        if let literal = object.node as? Literal {
            return formatLiteral(literal)
        }
        if let tripleTerm = object.node as? TripleTerm {
            let s = formatSubject(tripleTerm.subject)
            let p = formatPredicate(tripleTerm.predicate)
            let o = formatObject(tripleTerm.object)
            return "<< \(s) \(p) \(o) >>"
        }
        return object.description
    }

    private func formatIri(_ iri: IRI) -> String {
        for (prefix, base) in prefixes {
            if iri.string.hasPrefix(base.string) {
                let local = String(iri.string.dropFirst(base.string.count))
                if isValidPrefixedLocal(local) {
                    return "\(prefix):\(local)"
                }
            }
        }
        return "<\(iri.string)>"
    }

    private func formatLiteral(_ literal: Literal) -> String {
        var value = "\"\(escapeString(literal.lexicalForm))\""
        if let lang = literal.languageTag {
            value += "@\(lang)"
            if let direction = literal.textDirection {
                value += "--\(direction.rawValue)"
            }
        } else if let datatype = literal.datatype {
            value += "^^\(formatIri(datatype))"
        }
        return value
    }

    private func escapeString(_ string: String) -> String {
        var result = ""
        for scalar in string.unicodeScalars {
            switch scalar {
            case "\\": result.append("\\\\")
            case "\"": result.append("\\\"")
            case "\n": result.append("\\n")
            case "\r": result.append("\\r")
            case "\t": result.append("\\t")
            default:
                result.append(String(scalar))
            }
        }
        return result
    }

    private func isValidPrefixedLocal(_ local: String) -> Bool {
        guard !local.isEmpty else { return true }
        let invalidChars = CharacterSet.whitespacesAndNewlines
            .union(CharacterSet(charactersIn: ";,.[]()"))
        return local.rangeOfCharacter(from: invalidChars) == nil
    }
}
