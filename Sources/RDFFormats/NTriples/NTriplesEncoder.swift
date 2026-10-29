import IRIKit
import RDFCore

/// Encodes a graph as canonical RDF 1.2 N-Triples (§4).
///
/// Each triple is written on its own line, with single
/// spaces between terms, no comments and a line feed after the final `.`.
/// Literals escape `"`, `\`, the control characters and U+FFFE and U+FFFF;
/// `xsd:string` is never written; language tags are lower case. IRIs are the
/// boundary values the triples carry, written as they are. Triples are
/// written in the graph's order, the order they were first inserted.
public struct NTriplesEncoder: Sendable {
    /// Creates an N-Triples encoder.
    public init() {}

    /// Encodes a graph as a canonical N-Triples document.
    public func encode(_ graph: Graph) -> String {
        graph.map { triple in
            var line = ""
            write(triple.subject, to: &line)
            line += " "
            write(triple.predicate, to: &line)
            line += " "
            write(triple.object, to: &line)
            line += " .\n"
            return line
        }
        .joined()
    }

    private func write(_ iri: IRI, to output: inout String) {
        output += "<"
        output += iri.rawValue
        output += ">"
    }

    private func write(_ subject: SubjectTerm, to output: inout String) {
        switch subject {
        case .iri(let iri): write(iri, to: &output)
        case .blankNode(let node): output += node.description
        }
    }

    private func write(_ object: ObjectTerm, to output: inout String) {
        switch object {
        case .iri(let iri): write(iri, to: &output)
        case .blankNode(let node): output += node.description
        case .literal(let literal): write(literal, to: &output)
        case .tripleTerm(let term):
            output += "<<( "
            write(term.subject, to: &output)
            output += " "
            write(term.predicate, to: &output)
            output += " "
            write(term.object, to: &output)
            output += " )>>"
        }
    }

    private func write(_ literal: Literal, to output: inout String) {
        var text = String.UnicodeScalarView()
        text.append("\"")
        for scalar in literal.lexicalForm.unicodeScalars {
            switch scalar {
            case "\"": text.append(contentsOf: #"\""#.unicodeScalars)
            case "\\": text.append(contentsOf: #"\\"#.unicodeScalars)
            case "\n": text.append(contentsOf: #"\n"#.unicodeScalars)
            case "\r": text.append(contentsOf: #"\r"#.unicodeScalars)
            case "\t": text.append(contentsOf: #"\t"#.unicodeScalars)
            case "\u{08}": text.append(contentsOf: #"\b"#.unicodeScalars)
            case "\u{0C}": text.append(contentsOf: #"\f"#.unicodeScalars)
            case "\u{00}"..."\u{1F}", "\u{7F}", "\u{FFFE}", "\u{FFFF}":
                let hex = String(scalar.value, radix: 16, uppercase: true)
                text.append(contentsOf: ("\\u" + String(repeating: "0", count: 4 - hex.count) + hex).unicodeScalars)
            default:
                text.append(scalar)
            }
        }
        text.append("\"")
        output += String(text)
        if let language = literal.languageTag {
            output += "@" + language.lowercased()
            if let direction = literal.baseDirection {
                output += "--" + direction.rawValue
            }
        } else if let datatype = literal.datatype {
            output += "^^"
            write(datatype, to: &output)
        }
    }
}
