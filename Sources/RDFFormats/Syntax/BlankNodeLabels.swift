import RDFCore

/// The blank nodes of one document.
///
/// A label written in the document keeps its spelling unless a node the
/// parser created already uses it; then the label gets a fresh node, so two
/// different blank nodes never share a label.
struct BlankNodeLabels {
    private var written: [String: BlankNode] = [:]
    private var used: Set<String> = []
    private var counter = 0

    /// The node a `BLANK_NODE_LABEL` names, the same node every time.
    mutating func node(labelled label: String) -> BlankNode {
        if let node = written[label] { return node }
        let node = used.contains(label) ? fresh() : claim(label)
        written[label] = node
        return node
    }

    /// A blank node no label in the document names.
    mutating func fresh() -> BlankNode {
        while true {
            counter += 1
            let label = "b" + String(counter)
            if !used.contains(label) { return claim(label) }
        }
    }

    private mutating func claim(_ label: String) -> BlankNode {
        used.insert(label)
        return BlankNode(rawValue: label)
    }
}
