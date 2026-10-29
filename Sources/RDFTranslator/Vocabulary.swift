import RDFCore

/// The IRIs whose meaning the translation follows.
enum Term {
    static let rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    static let rdfs = "http://www.w3.org/2000/01/rdf-schema#"
    static let owl = "http://www.w3.org/2002/07/owl#"
    static let xsd = "http://www.w3.org/2001/XMLSchema#"

    static let type = rdf + "type"
    static let property = rdf + "Property"
    static let subClassOf = rdfs + "subClassOf"
    static let domain = rdfs + "domain"
    static let range = rdfs + "range"
    static let label = rdfs + "label"
    static let comment = rdfs + "comment"
    static let resource = rdfs + "Resource"
    static let `class` = rdfs + "Class"
    static let literal = rdfs + "Literal"
    static let datatype = rdfs + "Datatype"
    static let thing = owl + "Thing"
    static let deprecated = owl + "deprecated"
    static let boolean = xsd + "boolean"
}

/// What the merged graph of a module and the layers below it states and
/// RDFS-entails about its nodes.
///
/// Class membership follows RDF 1.2 Semantics, RDFS entailment: rdfs2
/// (`aaa rdfs:domain xxx . yyy aaa zzz .` entails `yyy rdf:type xxx .`),
/// rdfs3 (range, for the object) and rdfs9 (`rdfs:subClassOf`), applied to
/// the stated triples and to the `rdf:type` triples they entail, until
/// nothing new follows. The vocabularies themselves say which nodes are
/// classes: `rdf:type rdfs:range rdfs:Class` in rdf.ttl makes every object of
/// `rdf:type` a class.
struct Vocabulary {
    let statements: [Statement]
    private(set) var types: [NodeID: Set<NodeID>] = [:]
    private var superclasses: [NodeID: Set<NodeID>] = [:]
    private var domains: [String: [NodeID]] = [:]
    private var ranges: [String: [NodeID]] = [:]

    init(_ layers: some Sequence<Layer>) {
        statements = layers.flatMap(\.statements)
        for statement in statements {
            guard let object = statement.object.node else { continue }
            switch statement.predicate {
            case Term.subClassOf: superclasses[statement.subject, default: []].insert(object)
            case Term.domain: if let p = statement.subject.iri { domains[p, default: []].append(object) }
            case Term.range: if let p = statement.subject.iri { ranges[p, default: []].append(object) }
            default: break
            }
        }
        entail()
    }

    /// The classes of `node`, stated and entailed.
    func classes(of node: NodeID) -> Set<NodeID> {
        types[node] ?? []
    }

    /// Whether `node` is a class: an instance of `rdfs:Class`.
    func isClass(_ node: NodeID) -> Bool {
        classes(of: node).contains(.iri(Term.class))
    }

    /// Whether `node` is a property: an instance of `rdf:Property`.
    func isProperty(_ node: NodeID) -> Bool {
        classes(of: node).contains(.iri(Term.property))
    }

    /// `node` and every class it is a subclass of (rdfs11).
    func superclassClosure(of node: NodeID) -> Set<NodeID> {
        var closure: Set<NodeID> = [node]
        var pending = [node]
        while let next = pending.popLast() {
            for superclass in superclasses[next] ?? [] where closure.insert(superclass).inserted {
                pending.append(superclass)
            }
        }
        return closure
    }

    func domains(of property: NodeID) -> [NodeID] {
        property.iri.flatMap { domains[$0] } ?? []
    }

    func ranges(of property: NodeID) -> [NodeID] {
        property.iri.flatMap { ranges[$0] } ?? []
    }

    /// Whether the members of `node` are literals: `rdfs:Literal`, a
    /// subclass of it, a datatype (rdfs13) or an XML Schema datatype.
    func isLiteralClass(_ node: NodeID) -> Bool {
        if superclassClosure(of: node).contains(.iri(Term.literal)) { return true }
        if classes(of: node).contains(.iri(Term.datatype)) { return true }
        return node.iri?.hasPrefix(Term.xsd) ?? false
    }

    /// The literal values of `predicate` on `node`.
    func literals(_ predicate: String, of node: NodeID) -> [Literal] {
        statements.compactMap { statement in
            guard statement.subject == node, statement.predicate == predicate,
                  case .literal(let literal) = statement.object else { return nil }
            return literal
        }
    }

    /// Whether `node` is `owl:deprecated true`.
    func isDeprecated(_ node: NodeID) -> Bool {
        literals(Term.deprecated, of: node).contains { literal in
            literal.datatype?.rawValue == Term.boolean && (literal.lexicalForm == "true" || literal.lexicalForm == "1")
        }
    }

    private mutating func entail() {
        for statement in statements where statement.predicate == Term.type {
            if let object = statement.object.node { types[statement.subject, default: []].insert(object) }
        }
        let typeDomains = domains[Term.type] ?? []
        let typeRanges = ranges[Term.type] ?? []
        var changed = true
        while changed {
            changed = false
            func add(_ node: NodeID, _ classes: some Sequence<NodeID>) {
                for type in classes where types[node, default: []].insert(type).inserted {
                    changed = true
                }
            }
            for statement in statements {
                add(statement.subject, domains[statement.predicate] ?? [])
                if let object = statement.object.node {
                    add(object, ranges[statement.predicate] ?? [])
                }
            }
            for (node, classes) in types {
                // The entailed `node rdf:type class` triples, through rdfs2,
                // rdfs3 and rdfs9.
                add(node, typeDomains)
                for type in classes {
                    add(type, typeRanges)
                    add(node, superclassClosure(of: type))
                }
            }
        }
    }
}
