import Foundation

/// Encodes RDF graphs into N-Triples source.
struct NTriplesEncoder {
    /// Encodes a graph as N-Triples source.
    func encode(graph: Graph) -> String {
        let sortedTriples = graph.triples.sorted { lhs, rhs in
            let ls = lhs.subject.description
            let rs = rhs.subject.description
            if ls != rs { return ls < rs }
            let lp = lhs.predicate.string
            let rp = rhs.predicate.string
            if lp != rp { return lp < rp }
            return lhs.object.description < rhs.object.description
        }

        var lines: [String] = []
        lines.reserveCapacity(sortedTriples.count)
        for triple in sortedTriples {
            lines.append(
                "\(formatSubject(triple.subject)) \(formatPredicate(triple.predicate)) \(formatObject(triple.object)) ."
            )
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
        formatIri(predicate)
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
            return "<<( \(s) \(p) \(o) )>>"
        }
        return object.description
    }

    private func formatIri(_ iri: IRI) -> String {
        "<\(iri.string)>"
    }

    private func formatLiteral(_ literal: Literal) -> String {
        var value = "\"\(escapeString(literal.lexicalForm))\""
        if let lang = literal.languageTag {
            value += "@\(lang)"
            if let direction = literal.textDirection {
                value += "--\(direction.rawValue)"
            }
        } else if let datatype = literal.datatype {
            value += "^^<\(datatype.string)>"
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
            case "\u{0008}": result.append("\\b")
            case "\u{000C}": result.append("\\f")
            default:
                result.append(String(scalar))
            }
        }
        return result
    }
}
