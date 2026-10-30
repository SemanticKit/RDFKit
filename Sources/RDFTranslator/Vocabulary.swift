import IRIKit
import RDFCore
import XSD

extension IRI {
    // The terms whose meaning RDF 1.2 Semantics and OWL 2 fix, and that the
    // translation follows: membership (`rdf:type`, rdfD2), the RDFS
    // entailment rules (rdfs2, rdfs3, rdfs9, rdfs13), the classes every
    // resource is a member of (rdfs4; OWL 2 RDF-Based Semantics Table 5.2),
    // and the annotations that become documentation. These are the
    // translator's boundary: it reads a document's IRIs and writes Swift
    // types, and inside the Swift it writes no IRI names a term.
    static let rdfType: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
    static let rdfProperty: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#Property"
    static let rdfsSubClassOf: IRI = "http://www.w3.org/2000/01/rdf-schema#subClassOf"
    static let rdfsDomain: IRI = "http://www.w3.org/2000/01/rdf-schema#domain"
    static let rdfsRange: IRI = "http://www.w3.org/2000/01/rdf-schema#range"
    static let rdfsLabel: IRI = "http://www.w3.org/2000/01/rdf-schema#label"
    static let rdfsComment: IRI = "http://www.w3.org/2000/01/rdf-schema#comment"
    static let rdfsIsDefinedBy: IRI = "http://www.w3.org/2000/01/rdf-schema#isDefinedBy"
    static let rdfsResource: IRI = "http://www.w3.org/2000/01/rdf-schema#Resource"
    static let rdfsClass: IRI = "http://www.w3.org/2000/01/rdf-schema#Class"
    static let rdfsLiteral: IRI = "http://www.w3.org/2000/01/rdf-schema#Literal"
    static let rdfsDatatype: IRI = "http://www.w3.org/2000/01/rdf-schema#Datatype"
    static let owlThing: IRI = "http://www.w3.org/2002/07/owl#Thing"
    static let owlDeprecated: IRI = "http://www.w3.org/2002/07/owl#deprecated"
}

/// What the merged graph of a module and the layers below it states and
/// RDFS-entails about its nodes.
///
/// Class membership follows RDF 1.2 Semantics, RDF entailment: rdfD2
/// (`xxx aaa yyy .` entails `aaa rdf:type rdf:Property .`), and RDFS
/// entailment: rdfs2
/// (`aaa rdfs:domain xxx . yyy aaa zzz .` entails `yyy rdf:type xxx .`),
/// rdfs3 (range, for the object) and rdfs9 (`rdfs:subClassOf`), applied to
/// the stated triples and to the `rdf:type` triples they entail, until
/// nothing new follows. The vocabularies themselves say which nodes are
/// classes: `rdf:type rdfs:range rdfs:Class` in rdf.ttl makes every object of
/// `rdf:type` a class.
struct Vocabulary {
    let graph: Graph
    /// The XSD datatypes, the layer below every module.
    let datatypes: DatatypeLayer
    private(set) var types: [SubjectTerm: Set<SubjectTerm>] = [:]
    private var superclasses: [SubjectTerm: Set<SubjectTerm>] = [:]
    private var domains: [IRI: [SubjectTerm]] = [:]
    private var ranges: [IRI: [SubjectTerm]] = [:]

    init(_ layers: some Sequence<Layer>, datatypes: DatatypeLayer) {
        self.datatypes = datatypes
        var graph = Graph()
        for layer in layers { graph.formUnion(layer.graph) }
        self.graph = graph
        for triple in graph {
            guard let object = triple.object.node else { continue }
            switch triple.predicate {
            case .rdfsSubClassOf: superclasses[triple.subject, default: []].insert(object)
            case .rdfsDomain: if let p = triple.subject.iri { domains[p, default: []].append(object) }
            case .rdfsRange: if let p = triple.subject.iri { ranges[p, default: []].append(object) }
            default: break
            }
        }
        entail()
    }

    /// The classes of `node`, stated and entailed.
    func classes(of node: SubjectTerm) -> Set<SubjectTerm> {
        types[node] ?? []
    }

    /// Whether `node` is a class: an instance of `rdfs:Class`.
    func isClass(_ node: SubjectTerm) -> Bool {
        classes(of: node).contains(.iri(.rdfsClass))
    }

    /// Whether `node` is a property: an instance of `rdf:Property`.
    func isProperty(_ node: SubjectTerm) -> Bool {
        classes(of: node).contains(.iri(.rdfProperty))
    }

    /// `node` and every class it is a subclass of (rdfs11).
    func superclassClosure(of node: SubjectTerm) -> Set<SubjectTerm> {
        var closure: Set<SubjectTerm> = [node]
        var pending = [node]
        while let next = pending.popLast() {
            for superclass in superclasses[next] ?? [] where closure.insert(superclass).inserted {
                pending.append(superclass)
            }
        }
        return closure
    }

    func domains(of property: SubjectTerm) -> [SubjectTerm] {
        property.iri.flatMap { domains[$0] } ?? []
    }

    func ranges(of property: SubjectTerm) -> [SubjectTerm] {
        property.iri.flatMap { ranges[$0] } ?? []
    }

    /// Whether the members of `node` are literals: `rdfs:Literal`, a
    /// subclass of it, a datatype (rdfs13) or one of the XSD datatypes.
    func isLiteralClass(_ node: SubjectTerm) -> Bool {
        if superclassClosure(of: node).contains(.iri(.rdfsLiteral)) { return true }
        if classes(of: node).contains(.iri(.rdfsDatatype)) { return true }
        return datatypes.isDatatype(node)
    }

    /// Whether the members of `node` are classes: `rdfs:Class` or a subclass
    /// of it, such as `owl:Class` or `rdfs:Datatype`.
    func isMetaclass(_ node: SubjectTerm) -> Bool {
        superclassClosure(of: node).contains(.iri(.rdfsClass))
    }

    /// Whether the members of `node` are properties: `rdf:Property` or a
    /// subclass of it, such as `owl:ObjectProperty`.
    func isPropertyClass(_ node: SubjectTerm) -> Bool {
        superclassClosure(of: node).contains(.iri(.rdfProperty))
    }

    /// The literal values of `predicate` on `node`.
    func literals(_ predicate: IRI, of node: SubjectTerm) -> [Literal] {
        graph.compactMap { triple in
            guard triple.subject == node, triple.predicate == predicate,
                  case .literal(let literal) = triple.object else { return nil }
            return literal
        }
    }

    /// Whether `node` is `owl:deprecated true`: a value of `owl:deprecated`
    /// is the `xsd:boolean` true, `"true"` or `"1"`.
    func isDeprecated(_ node: SubjectTerm) -> Bool {
        literals(.owlDeprecated, of: node).contains { literal in
            XSD.boolean(literal)?.value == true
        }
    }

    private mutating func entail() {
        for triple in graph {
            types[.iri(triple.predicate), default: []].insert(.iri(.rdfProperty))
            if triple.predicate == .rdfType, let object = triple.object.node {
                types[triple.subject, default: []].insert(object)
            }
        }
        let typeDomains = domains[.rdfType] ?? []
        let typeRanges = ranges[.rdfType] ?? []
        var changed = true
        while changed {
            changed = false
            func add(_ node: SubjectTerm, _ classes: some Sequence<SubjectTerm>) {
                for type in classes where types[node, default: []].insert(type).inserted {
                    changed = true
                }
            }
            for triple in graph {
                add(triple.subject, domains[triple.predicate] ?? [])
                if let object = triple.object.node {
                    add(object, ranges[triple.predicate] ?? [])
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
