import IRIKit

extension Graph {
    /// Whether this graph and `other` are isomorphic.
    ///
    /// RDF 1.2 Concepts §3.7 Graph Comparison: "Two RDF graphs G and G' are
    /// isomorphic (that is, they have an identical form) if there is a
    /// bijection M between the sets of nodes of the two graphs" that maps
    /// blank nodes to blank nodes, is the identity on IRIs and literals, and
    /// maps the triples of G onto those of G'. Two documents that decode to
    /// isomorphic graphs say the same thing.
    public func isIsomorphic(to other: Graph) -> Bool {
        GraphIsomorphism(left: self, right: other).holds()
    }
}

/// The search for a blank node bijection between two graphs, by colour
/// refinement and individualization.
///
/// Every blank node starts with the same colour. A round gives each node a
/// new colour from its old one and the shapes of the triples it occurs in,
/// with the other blank nodes in them replaced by their colours; rounds run
/// until the partition into colours stops changing. A bijection maps each
/// node onto a node of the same colour, so the two graphs must have as many
/// nodes of each colour. When every colour is one node's, that is the only
/// bijection left, and it holds when it maps the triples onto each other.
/// Otherwise one node of the smallest colour shared by several nodes is
/// given a colour of its own, together with each node of that colour in the
/// other graph in turn, and the colours are refined again. The search keeps
/// its branches on a stack, so a graph of any size needs no deeper call
/// stack.
struct GraphIsomorphism {
    let left: Graph
    let right: Graph

    func holds() -> Bool {
        guard left.count == right.count else { return false }
        let leftStructure = BlankStructure(left)
        let rightStructure = BlankStructure(right)
        guard leftStructure.ground == rightStructure.ground,
              leftStructure.nodes.count == rightStructure.nodes.count,
              leftStructure.triples.count == rightStructure.triples.count
        else { return false }
        guard !leftStructure.nodes.isEmpty else { return true }

        var branches: [Branch] = []
        var next: Colouring? = Colouring(
            left: Array(repeating: 0, count: leftStructure.nodes.count),
            right: Array(repeating: 0, count: rightStructure.nodes.count)
        )
        while true {
            if let colouring = next, let refined = colouring.refined(leftStructure, rightStructure) {
                if let branch = refined.branch() {
                    branches.append(branch)
                } else if refined.maps(leftStructure, onto: rightStructure, in: right) {
                    return true
                }
            }
            next = nil
            guard var branch = branches.popLast() else { return false }
            guard let candidate = branch.candidates.popLast() else { continue }
            branches.append(branch)
            next = branch.colouring.individualizing(branch.node, candidate)
        }
    }

    /// A node of the left graph to individualize, and the nodes of the right
    /// graph not yet tried for it.
    struct Branch {
        let colouring: Colouring
        let node: Int
        var candidates: [Int]
    }
}

/// The blank nodes of a graph, numbered, and its triples that hold them.
struct BlankStructure {
    /// The triples without blank nodes, which must be equal as they are.
    let ground: Set<Graph.Element>
    /// The blank nodes, numbered by their place here.
    let nodes: [BlankNode]
    /// The triples with blank nodes.
    let triples: [Graph.Element]
    /// For each triple, its shape: the triple with every blank node replaced
    /// by the same placeholder.
    let shapes: [Int]
    /// For each triple, the numbers of its blank nodes in the order they
    /// occur, so with ``shapes`` it says where each node stands.
    let slots: [[Int]]
    /// For each node, the triples it occurs in.
    let incidence: [[Int]]

    init(_ graph: Graph) {
        var ground: Set<Graph.Element> = []
        var nodes: [BlankNode] = []
        var numbers: [BlankNode: Int] = [:]
        var triples: [Graph.Element] = []
        var shapes: [Int] = []
        var slots: [[Int]] = []
        var incidence: [[Int]] = []
        let placeholder = try! BlankNode("_")  // never empty
        for triple in graph {
            let blankNodes = triple.blankNodes
            guard !blankNodes.isEmpty else {
                ground.insert(triple)
                continue
            }
            let index = triples.count
            triples.append(triple)
            shapes.append(triple.replacingBlankNodes(Dictionary(blankNodes.map { ($0, placeholder) }) { first, _ in first }).hashValue)
            var numbered: [Int] = []
            for node in blankNodes {
                let number: Int
                if let known = numbers[node] {
                    number = known
                } else {
                    number = nodes.count
                    numbers[node] = number
                    nodes.append(node)
                    incidence.append([])
                }
                if incidence[number].last != index { incidence[number].append(index) }
                numbered.append(number)
            }
            slots.append(numbered)
        }
        self.ground = ground
        self.nodes = nodes
        self.triples = triples
        self.shapes = shapes
        self.slots = slots
        self.incidence = incidence
    }

    /// The colours one round of refinement gives the nodes.
    func round(_ colours: [Int]) -> [Int] {
        incidence.indices.map { node in
            var signatures = incidence[node].map { triple in
                var hasher = Hasher()
                hasher.combine(shapes[triple])
                for slot in slots[triple] {
                    if slot == node {
                        hasher.combine(true)
                    } else {
                        hasher.combine(false)
                        hasher.combine(colours[slot])
                    }
                }
                return hasher.finalize()
            }
            signatures.sort()
            var hasher = Hasher()
            hasher.combine(colours[node])
            hasher.combine(signatures)
            return hasher.finalize()
        }
    }
}

/// The colours of the blank nodes of both graphs.
struct Colouring {
    var left: [Int]
    var right: [Int]

    /// The colouring refined until its partition stops changing, or `nil`
    /// when the graphs have different numbers of nodes of some colour, so
    /// no bijection respects it.
    func refined(_ leftStructure: BlankStructure, _ rightStructure: BlankStructure) -> Colouring? {
        var colouring = self
        var classes = Set(colouring.left).count
        while true {
            guard colouring.left.sorted() == colouring.right.sorted() else { return nil }
            let next = Colouring(left: leftStructure.round(colouring.left), right: rightStructure.round(colouring.right))
            let nextClasses = Set(next.left).count
            // A round only splits colours, so a round that splits none is the
            // last.
            if nextClasses <= classes {
                return next.left.sorted() == next.right.sorted() ? colouring : nil
            }
            colouring = next
            classes = nextClasses
        }
    }

    /// The branch that individualizes the first node of the smallest colour
    /// several nodes share, or `nil` when every node has a colour of its own.
    func branch() -> GraphIsomorphism.Branch? {
        var members: [Int: [Int]] = [:]
        for (node, colour) in left.enumerated() { members[colour, default: []].append(node) }
        guard let (colour, nodes) = members.filter({ $0.value.count > 1 }).min(by: { lhs, rhs in
            lhs.value.count != rhs.value.count ? lhs.value.count < rhs.value.count : lhs.value[0] < rhs.value[0]
        }) else { return nil }
        let candidates = right.indices.filter { right[$0] == colour }
        return GraphIsomorphism.Branch(colouring: self, node: nodes[0], candidates: candidates.reversed())
    }

    /// The colouring with `node` of the left graph and `candidate` of the
    /// right graph given the same colour, which no other node has.
    func individualizing(_ node: Int, _ candidate: Int) -> Colouring {
        var hasher = Hasher()
        hasher.combine(left[node])
        hasher.combine("individualized")
        hasher.combine(node)
        let colour = hasher.finalize()
        var colouring = self
        colouring.left[node] = colour
        colouring.right[candidate] = colour
        return colouring
    }

    /// Whether the bijection this colouring gives, each left node onto the
    /// right node of its colour, maps the left graph's triples with blank
    /// nodes onto those of `graph`. Every colour is one node's.
    func maps(_ leftStructure: BlankStructure, onto rightStructure: BlankStructure, in graph: Graph) -> Bool {
        let rightNodes = Dictionary(uniqueKeysWithValues: right.enumerated().map { ($0.element, rightStructure.nodes[$0.offset]) })
        let mapping = Dictionary(uniqueKeysWithValues: left.enumerated().map { (leftStructure.nodes[$0.offset], rightNodes[$0.element]!) })
        return leftStructure.triples.allSatisfy { graph.contains($0.replacingBlankNodes(mapping)) }
    }
}
