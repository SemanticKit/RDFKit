import RDFCore

/// The blank nodes of one document.
///
/// A label written in the document keeps its spelling unless a node the
/// parser created already uses it; then the label gets a fresh node, so two
/// different blank nodes never share a label. Labels are told apart as
/// blank nodes are, Unicode scalar by Unicode scalar.
struct BlankNodeLabels {
    private var written: [BlankNode: BlankNode] = [:]
    private var used: Set<BlankNode> = []
    private var counter = 0

    /// The node a `BLANK_NODE_LABEL` names, the same node every time.
    mutating func node(labelled label: String) throws(TermError) -> BlankNode {
        let labelled = try BlankNode(label)
        if let node = written[labelled] { return node }
        let node = try used.contains(labelled) ? fresh() : claim(labelled)
        written[labelled] = node
        return node
    }

    /// A blank node no label in the document names.
    mutating func fresh() throws(TermError) -> BlankNode {
        while true {
            counter += 1
            let node = try BlankNode("b" + String(counter))
            if !used.contains(node) { return claim(node) }
        }
    }

    private mutating func claim(_ node: BlankNode) -> BlankNode {
        used.insert(node)
        return node
    }
}
