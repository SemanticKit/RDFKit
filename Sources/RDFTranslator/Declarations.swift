/// The Swift names one module declares for the resources its documents
/// describe.
///
/// A class an IRI subject of the module's documents describes becomes a
/// protocol named by its local name; any other IRI subject becomes a value
/// named by its local name. A resource a lower layer already declares keeps
/// that declaration. Two resources with one local name keep the name for the
/// first one, in document order; the other is reachable only through the
/// module's `ontology`.
struct Declarations {
    let module: String
    private(set) var protocols: [NodeID: String] = [:]
    private(set) var values: [NodeID: String] = [:]
    private(set) var order: [NodeID] = []

    /// The protocols each declared protocol refines.
    private(set) var refinements: [NodeID: [NodeID]] = [:]

    /// Names that generated code declares in every module.
    static let reserved: Set<String> = ["ontology"]

    init(_ layer: Layer, _ vocabulary: Vocabulary, below: [Declarations]) {
        module = layer.module
        var taken = Self.reserved
        for statement in layer.statements {
            let subject = statement.subject
            guard let iri = subject.iri, protocols[subject] == nil, values[subject] == nil,
                  !below.contains(where: { $0.declares(subject) }) else { continue }
            let name = SwiftName.localName(of: iri)
            guard SwiftName.isUsable(name), taken.insert(name).inserted else { continue }
            if vocabulary.isClass(subject) {
                protocols[subject] = name
            } else {
                values[subject] = name
            }
            order.append(subject)
        }
        refine(vocabulary, below: below)
    }

    /// A class's protocol refines the protocols of the classes it is a
    /// subclass of (rdfs9), or ``Resource`` when there are none. Swift
    /// protocols cannot refine each other in a cycle, so of classes that are
    /// subclasses of each other the later one refines the earlier.
    private mutating func refine(_ vocabulary: Vocabulary, below: [Declarations]) {
        let position = Dictionary(uniqueKeysWithValues: order.enumerated().map { ($1, $0) })
        for (index, node) in order.enumerated() where protocols[node] != nil {
            let superclasses = vocabulary.superclassClosure(of: node).filter { superclass in
                guard superclass != node else { return false }
                if below.contains(where: { $0.protocols[superclass] != nil }) { return true }
                guard protocols[superclass] != nil, let other = position[superclass] else { return false }
                let mutual = vocabulary.superclassClosure(of: superclass).contains(node)
                return !mutual || other < index
            }
            // A protocol another one already refines is left out.
            refinements[node] = superclasses.filter { superclass in
                !superclasses.contains { other in
                    guard other != superclass else { return false }
                    if let layer = below.first(where: { $0.protocols[other] != nil }) {
                        return layer.refinementClosure(of: other, below: below).contains(superclass)
                    }
                    return vocabulary.superclassClosure(of: other).contains(superclass)
                        && !vocabulary.superclassClosure(of: superclass).contains(other)
                }
            }.sorted { ($0.iri ?? "") < ($1.iri ?? "") }
        }
    }

    /// Every protocol the protocol of `node` refines, through this layer's
    /// refinements and those of the layers below.
    func refinementClosure(of node: NodeID, below: [Declarations]) -> Set<NodeID> {
        var closure: Set<NodeID> = []
        var pending = [node]
        while let next = pending.popLast() {
            for layer in below + [self] {
                for refined in layer.refinements[next] ?? [] where closure.insert(refined).inserted {
                    pending.append(refined)
                }
            }
        }
        return closure
    }

    func declares(_ node: NodeID) -> Bool {
        protocols[node] != nil || values[node] != nil
    }
}

/// Spelling Swift identifiers for RDF names.
enum SwiftName {
    /// The local name of an IRI: what follows its last `#`, or else its
    /// last `/`.
    static func localName(of iri: String) -> String {
        if let hash = iri.lastIndex(of: "#") { return String(iri[iri.index(after: hash)...]) }
        if let slash = iri.lastIndex(of: "/") { return String(iri[iri.index(after: slash)...]) }
        return ""
    }

    /// Whether a local name can be a raw identifier: it is not empty and
    /// not only operator characters (SE-0451, Permitted characters).
    static func isUsable(_ name: String) -> Bool {
        !name.isEmpty && !name.allSatisfy { "/=-+!*%<>&|^~?.".contains($0) }
    }

    /// The identifier, always in backticks, so keywords and names Swift's
    /// identifier grammar does not allow are raw identifiers (SE-0451).
    static func identifier(_ name: String) -> String {
        "`" + name + "`"
    }

    /// A Swift string literal of `text`.
    static func stringLiteral(_ text: String) -> String {
        var literal = "\""
        for scalar in text.unicodeScalars {
            switch scalar {
            case "\"": literal += "\\\""
            case "\\": literal += "\\\\"
            case "\n": literal += "\\n"
            case "\r": literal += "\\r"
            case "\t": literal += "\\t"
            case "\u{00}"..."\u{1F}", "\u{7F}": literal += "\\u{\(String(scalar.value, radix: 16))}"
            default: literal.unicodeScalars.append(scalar)
            }
        }
        return literal + "\""
    }
}
