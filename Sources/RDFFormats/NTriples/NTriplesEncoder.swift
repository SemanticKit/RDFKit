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
///
/// A blank node is written with its identifier when that identifier is a
/// `BLANK_NODE_LABEL`. RDF 1.2 Concepts §3.5 leaves the set of blank nodes
/// arbitrary, so an identifier can be one the N-Triples grammar does not
/// allow, such as `nodeID://b1`; such a node is written under a fresh
/// label, `b0`, `b1` and so on, that no other node in the document uses, the
/// same label every time it occurs.
public struct NTriplesEncoder: Sendable {
    /// Creates an N-Triples encoder.
    public init() {}

    /// Encodes a graph as a canonical N-Triples document.
    public func encode(_ graph: Graph) -> String {
        var labels = BlankNodeLabelling(graph)
        return graph.map { triple in
            var line = ""
            write(triple, to: &line, labels: &labels)
            line += " .\n"
            return line
        }
        .joined()
    }

    private func write(_ triple: Graph.Element, to output: inout String, labels: inout BlankNodeLabelling) {
        write(triple.subject, to: &output, labels: &labels)
        output += " "
        write(triple.predicate, to: &output)
        output += " "
        write(triple.object, to: &output, labels: &labels)
    }

    private func write(_ iri: IRI, to output: inout String) {
        output += "<"
        output += iri.rawValue
        output += ">"
    }

    private func write(_ subject: SubjectTerm, to output: inout String, labels: inout BlankNodeLabelling) {
        switch subject {
        case .iri(let iri): write(iri, to: &output)
        case .blankNode(let node): output += "_:" + labels.label(for: node)
        }
    }

    private func write(_ object: ObjectTerm, to output: inout String, labels: inout BlankNodeLabelling) {
        switch object {
        case .iri(let iri): write(iri, to: &output)
        case .blankNode(let node): output += "_:" + labels.label(for: node)
        case .literal(let literal): write(literal, to: &output)
        case .tripleTerm(let term):
            output += "<<( "
            write(term, to: &output, labels: &labels)
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

/// The `BLANK_NODE_LABEL` each blank node of one document is written under.
private struct BlankNodeLabelling {
    /// The identifiers that are labels already, which fresh labels avoid.
    private let inUse: Set<String>
    private var fresh: [BlankNode: String] = [:]
    private var next = 0

    init(_ graph: Graph) {
        var inUse: Set<String> = []
        func collect(_ triple: Graph.Element) {
            if case .blankNode(let node) = triple.subject { inUse.insert(node.identifier) }
            switch triple.object {
            case .blankNode(let node): inUse.insert(node.identifier)
            case .tripleTerm(let term): collect(term)
            case .iri, .literal: break
            }
        }
        graph.forEach(collect)
        self.inUse = inUse.filter(Self.isLabel)
    }

    mutating func label(for node: BlankNode) -> String {
        if Self.isLabel(node.identifier) { return node.identifier }
        if let label = fresh[node] { return label }
        var label: String
        repeat {
            label = "b\(next)"
            next += 1
        } while inUse.contains(label)
        fresh[node] = label
        return label
    }

    /// `BLANK_NODE_LABEL ::= '_:' (PN_CHARS_U | [0-9]) ((PN_CHARS | '.')* PN_CHARS)?`,
    /// without the `_:`.
    private static func isLabel(_ identifier: String) -> Bool {
        let scalars = Array(identifier.unicodeScalars)
        guard let first = scalars.first, let last = scalars.last,
              Scanner.isPNCharsU(first) || Scanner.isASCIIDigit(first) else { return false }
        guard scalars.count > 1 else { return true }
        return Scanner.isPNChars(last)
            && scalars.dropFirst().dropLast().allSatisfy { Scanner.isPNChars($0) || $0 == "." }
    }
}
