import IRIKit
import RDFCore

/// Encodes a graph as an RDF 1.2 Turtle document.
///
/// The document uses the abbreviations of RDF 1.2 Turtle §2: `PREFIX`
/// directives and prefixed names (§2.4, §6.3), `a` for `rdf:type` (§2.4),
/// one subject's predicates separated by `;` and one predicate's objects by
/// `,` (§2.3), `[ … ]` for a blank node that is the object of one triple
/// (§2.6), `( … )` for an `rdf:first`/`rdf:rest` collection (§2.8), and
/// the short forms of integers, decimals, doubles and booleans (§2.5.2).
/// Subjects, predicates and objects are written in the graph's order.
///
/// The prefixes are the ones given, then one, `ns1`, `ns2` and so on, for
/// each other namespace whose IRIs can be written as prefixed names.
///
///     let document = TurtleEncoder(prefixes: [Prefix("foaf", "http://xmlns.com/foaf/0.1/")]).encode(graph)
public struct TurtleEncoder: Sendable {
    /// The prefixes the document declares first.
    public let prefixes: [Prefix]

    /// Creates a Turtle encoder.
    public init(prefixes: [Prefix] = []) {
        self.prefixes = prefixes
    }

    /// Encodes a graph as a Turtle document.
    public func encode(_ graph: Graph) -> String {
        var document = TurtleDocument(graph, prefixes: prefixes)
        return document.write()
    }

    /// Encodes descriptions as a Turtle document: the triples each one
    /// states through its `Encodable` conformance (see ``GraphEncoder``).
    ///
    ///     let document = try TurtleEncoder().encode([alice, bob])
    ///
    /// - Throws: `EncodingError` when a description writes something other
    ///   than resources, classes and literals keyed by property IRIs.
    public func encode(_ descriptions: [any Description]) throws -> String {
        encode(try GraphEncoder().encode(descriptions))
    }

    /// Encodes one description as a Turtle document.
    public func encode(_ description: some Description) throws -> String {
        encode(try GraphEncoder().encode(description))
    }
}

/// One Turtle document being written: which blank nodes are written inline,
/// as `[ … ]` or `( … )`, and the prefixes and labels it uses.
private struct TurtleDocument {
    let graph: Graph
    var labels: BlankNodeLabelling

    /// The prefix name of each namespace.
    private var prefixNames: [String: String] = [:]
    private var directives: [String] = []

    /// The triples of each subject, in graph order.
    private var triplesBySubject: [SubjectTerm: [Graph.Element]] = [:]
    private var subjects: [SubjectTerm] = []

    /// Blank nodes written as `[ … ]` where they are the object.
    private var inlineNodes: Set<BlankNode> = []

    /// List heads written as `( … )` where they are the object, with their
    /// members.
    private var collections: [BlankNode: [ObjectTerm]] = [:]

    /// The blank nodes of the list cells after the head of a collection,
    /// which are not written as subjects, and their heads.
    private var collectionCells: [BlankNode: BlankNode] = [:]

    init(_ graph: Graph, prefixes: [Prefix]) {
        self.graph = graph
        labels = BlankNodeLabelling(graph)
        // A given prefix is declared when its label is a `PN_PREFIX` (or
        // empty, `PNAME_NS ::= PN_PREFIX? ':'`) not declared for another
        // namespace: a second `PREFIX` for one label redefines it (§6.3), so
        // the names written with the first would read back as other IRIs.
        for prefix in prefixes where prefix.isTurtleLabel
            && prefixNames[prefix.namespace.rawValue] == nil
            && !prefixNames.values.contains(prefix.prefix) {
            prefixNames[prefix.namespace.rawValue] = prefix.prefix
            directives.append("PREFIX \(prefix.prefix): \(prefix.namespace.iriReference)")
        }
        for triple in graph {
            if triplesBySubject[triple.subject] == nil { subjects.append(triple.subject) }
            triplesBySubject[triple.subject, default: []].append(triple)
        }
        planInlineNodes()
        planPrefixes()
    }

    // MARK: - Planning

    /// A blank node is written inline when it is the object of exactly one
    /// triple and is not in a triple term. Of blank nodes that only reach
    /// each other, one is written as a subject, so that every node is
    /// written once.
    private mutating func planInlineNodes() {
        var references: [BlankNode: Int] = [:]
        var inTripleTerms: Set<BlankNode> = []
        for triple in graph {
            switch triple.object {
            case .blankNode(let node): references[node, default: 0] += 1
            case .tripleTerm(let term): inTripleTerms.formUnion(term.blankNodes)
            case .iri, .literal: break
            }
        }
        let candidates = Set(references.filter { $0.value == 1 }.keys).subtracting(inTripleTerms)

        // Collections: a chain of cells with exactly `rdf:first` and
        // `rdf:rest`, each referenced once, ending at `rdf:nil`.
        var lists: [BlankNode: (values: [ObjectTerm], cells: [BlankNode])] = [:]
        for head in candidates {
            lists[head] = members(ofList: head, candidates: candidates)
        }
        // A cell after the head of a list heads the rest of it, which is
        // part of the longer collection.
        let inner = Set(lists.values.flatMap { $0.cells.dropFirst() })
        for (head, list) in lists where !inner.contains(head) {
            collections[head] = list.values
            for cell in list.cells.dropFirst() { collectionCells[cell] = head }
        }
        inlineNodes = candidates.subtracting(collectionCells.keys).subtracting(collections.keys)

        // Every inline node and collection must be reached from a subject
        // that is written at the top level.
        while true {
            var reached: Set<BlankNode> = []
            var pending = subjects.filter { !isInline($0) }
            while let subject = pending.popLast() {
                for case .blankNode(let node) in objects(of: subject) where isInline(node) && reached.insert(node).inserted {
                    pending.append(.blankNode(node))
                }
            }
            let unreached = subjects.compactMap { subject -> BlankNode? in
                guard case .blankNode(let node) = subject, isInline(node), !reached.contains(node) else { return nil }
                return node
            }
            guard let first = unreached.first else { break }
            let head = collectionCells[first] ?? first
            inlineNodes.remove(head)
            if collections.removeValue(forKey: head) != nil {
                collectionCells = collectionCells.filter { $0.value != head }
            }
        }
    }

    private func isInline(_ subject: SubjectTerm) -> Bool {
        if case .blankNode(let node) = subject { return isInline(node) }
        return false
    }

    private func isInline(_ node: BlankNode) -> Bool {
        inlineNodes.contains(node) || collections[node] != nil || collectionCells[node] != nil
    }

    /// The objects of the triples of `subject`, and the members of a
    /// collection it heads.
    private func objects(of subject: SubjectTerm) -> [ObjectTerm] {
        (triplesBySubject[subject] ?? []).map(\.object)
    }

    /// The members and cells of the list headed by `head`, when every cell
    /// has exactly one `rdf:first` and one `rdf:rest`, each cell after the
    /// head is referenced only by the cell before it, and the list ends at
    /// `rdf:nil`.
    private func members(ofList head: BlankNode, candidates: Set<BlankNode>) -> (values: [ObjectTerm], cells: [BlankNode])? {
        var values: [ObjectTerm] = []
        var cells: [BlankNode] = []
        var node = head
        while true {
            guard !cells.contains(node), let triples = triplesBySubject[.blankNode(node)], triples.count == 2,
                  let first = triples.first(where: { $0.predicate == .rdfFirst }),
                  let rest = triples.first(where: { $0.predicate == .rdfRest }) else { return nil }
            values.append(first.object)
            cells.append(node)
            switch rest.object {
            case .iri(let iri) where iri == .rdfNil:
                return (values, cells)
            case .blankNode(let next) where candidates.contains(next):
                node = next
            default:
                return nil
            }
        }
    }

    /// A prefix for each namespace of the IRIs the document writes that has
    /// none yet, in the order the namespaces first occur.
    private mutating func planPrefixes() {
        var number = 1
        func add(_ iri: IRI) {
            guard iri != .rdfType, let parts = iri.prefixableParts, prefixNames[parts.namespace.rawValue] == nil else { return }
            var name: String
            repeat {
                name = "ns\(number)"
                number += 1
            } while prefixNames.values.contains(name)
            prefixNames[parts.namespace.rawValue] = name
            directives.append("PREFIX \(name): \(parts.namespace.iriReference)")
        }
        func add(_ triple: Graph.Element) {
            if case .iri(let iri) = triple.subject { add(iri) }
            add(triple.predicate)
            switch triple.object {
            case .iri(let iri): add(iri)
            case .literal(let literal): if let datatype = literal.datatype, literal.turtleShortForm == nil { add(datatype) }
            case .tripleTerm(let term): add(term)
            case .blankNode: break
            }
        }
        graph.forEach(add)
    }

    // MARK: - Writing

    mutating func write() -> String {
        var document = directives.map { $0 + "\n" }.joined()
        if !directives.isEmpty && !graph.isEmpty { document += "\n" }
        for subject in subjects where !isInline(subject) {
            document += statement(subject)
        }
        return document
    }

    /// `triples '.'` for one subject.
    private mutating func statement(_ subject: SubjectTerm) -> String {
        "\(term(subject)) \(predicateObjectList(of: subject, indent: "    ")) .\n"
    }

    /// `predicateObjectList ::= verb objectList (';' (verb objectList)?)*`
    private mutating func predicateObjectList(of subject: SubjectTerm, indent: String) -> String {
        var predicates: [IRI] = []
        var objects: [IRI: [ObjectTerm]] = [:]
        for triple in triplesBySubject[subject] ?? [] {
            if objects[triple.predicate] == nil { predicates.append(triple.predicate) }
            objects[triple.predicate, default: []].append(triple.object)
        }
        return predicates.map { predicate in
            let verb = predicate == .rdfType ? "a" : term(predicate)
            let list = objects[predicate, default: []].map { object(for: $0, indent: indent) }.joined(separator: ", ")
            return "\(verb) \(list)"
        }.joined(separator: " ;\n\(indent)")
    }

    private mutating func object(for object: ObjectTerm, indent: String) -> String {
        switch object {
        case .iri(let iri): return iri == .rdfNil ? "()" : term(iri)
        case .literal(let literal): return term(literal)
        case .tripleTerm(let triple): return tripleTerm(triple)
        case .blankNode(let node):
            if let members = collections[node] {
                return "( " + members.map { self.object(for: $0, indent: indent + "    ") }.joined(separator: " ") + " )"
            }
            if inlineNodes.contains(node) {
                guard triplesBySubject[.blankNode(node)] != nil else { return "[]" }
                return "[\n\(indent)    \(predicateObjectList(of: .blankNode(node), indent: indent + "    "))\n\(indent)]"
            }
            return "_:" + labels.label(for: node)
        }
    }

    /// `tripleTerm ::= '<<(' ttSubject verb ttObject ')>>'`, whose blank
    /// nodes are always labelled.
    private mutating func tripleTerm(_ triple: Graph.Element) -> String {
        let subject: String
        switch triple.subject {
        case .iri(let iri): subject = term(iri)
        case .blankNode(let node): subject = "_:" + labels.label(for: node)
        }
        let object: String
        switch triple.object {
        case .iri(let iri): object = term(iri)
        case .blankNode(let node): object = "_:" + labels.label(for: node)
        case .literal(let literal): object = term(literal)
        case .tripleTerm(let inner): object = tripleTerm(inner)
        }
        let verb = triple.predicate == .rdfType ? "a" : term(triple.predicate)
        return "<<( \(subject) \(verb) \(object) )>>"
    }

    private mutating func term(_ subject: SubjectTerm) -> String {
        switch subject {
        case .iri(let iri): term(iri)
        case .blankNode(let node): inlineNodes.contains(node) ? "[]" : "_:" + labels.label(for: node)
        }
    }

    /// A prefixed name where the IRI's namespace has a prefix, the
    /// `IRIREF` otherwise.
    private func term(_ iri: IRI) -> String {
        if let parts = iri.prefixableParts, let prefix = prefixNames[parts.namespace.rawValue] {
            return prefix + ":" + parts.local
        }
        return iri.iriReference
    }

    private func term(_ literal: Literal) -> String {
        if let short = literal.turtleShortForm { return short }
        if let languageDirection = literal.languageDirection { return literal.quotedLexicalForm + "@" + languageDirection }
        if let datatype = literal.datatype { return literal.quotedLexicalForm + "^^" + term(datatype) }
        return literal.quotedLexicalForm
    }
}

private extension Prefix {
    /// Whether the label can be written in a `PNAME_NS`: empty, or a
    /// `PN_PREFIX` (RDF 1.2 Turtle §6.5).
    var isTurtleLabel: Bool {
        prefix.isEmpty || TurtleGrammar.PN_PREFIX.matches(prefix)
    }
}
