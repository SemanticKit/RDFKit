import Foundation

private enum RDFSClosureAxioms {
    static func graph() throws -> Graph {
        var graph = Graph()
        try RDF.content.write(to: &graph)
        try RDFS.content.write(to: &graph)
        return graph
    }
}

/// Computes RDFS-entailable graph and dataset content.
public struct RDFSClosure: Sendable {
    /// Whether standard RDF/RDFS axioms are included in the closure.
    public let includeAxioms: Bool

    /// Creates an RDFS closure service.
    public init(includeAxioms: Bool = true) {
        self.includeAxioms = includeAxioms
    }

    /// Returns a graph with RDFS-entailable triples added.
    public func applied(to graph: Graph) throws -> Graph {
        var reasoner = try RDFSReasoner(graph: graph, includeAxioms: includeAxioms)
        return try reasoner.computeClosure().merged(with: graph)
    }

    /// Returns only triples inferred by RDFS closure.
    public func inferredTriples(from graph: Graph) throws -> Set<Graph.TripleType> {
        try applied(to: graph).triples.subtracting(graph.triples)
    }

    /// Returns a dataset with RDFS-entailable triples added to each graph.
    public func applied(to dataset: Dataset) throws -> Dataset {
        var named: [IRI: Graph] = [:]
        for (name, graph) in dataset.namedGraphs {
            named[name] = try applied(to: graph)
        }
        return Dataset(defaultGraph: try applied(to: dataset.defaultGraph), namedGraphs: named)
    }
}

private struct RDFSReasoner {
    private var graph: Graph
    private let includeAxioms: Bool

    init(graph: Graph, includeAxioms: Bool) throws {
        self.graph = includeAxioms ? graph.merged(with: try RDFSClosureAxioms.graph()) : graph
        self.includeAxioms = includeAxioms
    }

    mutating func computeClosure() throws -> Graph {
        var changed = true
        while changed {
            changed = false
            if includeAxioms {
                changed = try addContainerMembershipAxioms() || changed
            }

            let snapshot = Array(graph.triples)
            let subproperties = indexIRIObjects(predicate: RDFS.subPropertyOf)
            let subclasses = indexIRIObjects(predicate: RDFS.subClassOf)
            let domains = indexIRIObjects(predicate: RDFS.domain)
            let ranges = indexIRIObjects(predicate: RDFS.range)
            let types = indexIRIObjects(predicate: RDF.type)

            for (property, supers) in subproperties {
                for superproperty in supers {
                    changed = try insert(subject: property, predicate: RDFS.subPropertyOf, object: superproperty) || changed
                    for transitive in subproperties[superproperty] ?? [] {
                        changed = try insert(subject: property, predicate: RDFS.subPropertyOf, object: transitive) || changed
                    }
                }
            }

            for (subclass, supers) in subclasses {
                for superclass in supers {
                    for transitive in subclasses[superclass] ?? [] {
                        changed = try insert(subject: subclass, predicate: RDFS.subClassOf, object: transitive) || changed
                    }
                }
            }

            for triple in snapshot {
                for superproperty in subproperties[triple.predicate] ?? [] {
                    changed = try insert(subject: triple.subject, predicate: superproperty, object: triple.object) || changed
                }

                for domain in domains[triple.predicate] ?? [] {
                    changed = try insert(subject: triple.subject, predicate: RDF.type, object: domain) || changed
                }

                if let objectSubject = subject(from: triple.object) {
                    for range in ranges[triple.predicate] ?? [] {
                        changed = try insert(subject: objectSubject, predicate: RDF.type, object: range) || changed
                    }
                }

                if triple.predicate.rawValue == RDF.type.iri.rawValue, let classIRI = triple.object.node as? IRI {
                    for superclass in subclasses[classIRI] ?? [] {
                        changed = try insert(subject: triple.subject, predicate: RDF.type, object: superclass) || changed
                    }
                }
            }

            for (resource, directTypes) in types {
                if directTypes.contains(where: { $0.rawValue == RDFS.ContainerMembershipProperty.iri.rawValue }) {
                    changed = try insert(subject: resource, predicate: RDFS.subPropertyOf, object: RDFS.member.iri) || changed
                }
                if directTypes.contains(where: { $0.rawValue == RDFS.Datatype.iri.rawValue }) {
                    changed = try insert(subject: resource, predicate: RDFS.subClassOf, object: RDFS.Literal.iri) || changed
                }
            }
        }
        return graph
    }

    private func indexIRIObjects<Predicate: IRIRepresentable>(predicate: Predicate) -> [IRI: Set<IRI>] {
        var index: [IRI: Set<IRI>] = [:]
        for triple in graph.triples where triple.predicate.rawValue == predicate.iri.rawValue {
            guard let subject = triple.subject.node as? IRI else { continue }
            guard let object = triple.object.node as? IRI else { continue }
            index[subject, default: []].insert(object)
        }
        return index
    }

    private mutating func addContainerMembershipAxioms() throws -> Bool {
        var changed = false
        for triple in graph.triples {
            let predicate = triple.predicate.rawValue
            guard predicate.hasPrefix(RDF.namespace.rawValue + "_") else { continue }
            changed = try insert(subject: triple.predicate, predicate: RDF.type, object: RDF.Property.iri) || changed
            changed = try insert(subject: triple.predicate, predicate: RDF.type, object: RDFS.ContainerMembershipProperty.iri) || changed
            changed = try insert(subject: triple.predicate, predicate: RDFS.subPropertyOf, object: RDFS.member.iri) || changed
        }
        return changed
    }

    private func subject(from object: AnyRDFObject) -> AnyRDFSubject? {
        if let iri = object.node as? IRI {
            return AnyRDFSubject(iri)
        }
        if let blank = object.node as? BlankNode {
            return AnyRDFSubject(blank)
        }
        return nil
    }

    private mutating func insert<Subject: RDFSubject, Predicate: IRIRepresentable, Object: RDFObject>(subject: Subject, predicate: Predicate, object: Object) throws -> Bool {
        let erasedSubject = try erase(subject)
        let erasedObject = erase(object)
        let triple = Graph.TripleType(subject: erasedSubject, predicate: predicate, object: erasedObject)
        if graph.contains(triple) {
            return false
        }
        try graph.insert(triple)
        return true
    }

    private func erase<Subject: RDFSubject>(_ subject: Subject) throws -> AnyRDFSubject {
        if let subject = subject as? AnyRDFSubject {
            return subject
        }
        if let iri = subject as? IRI {
            return AnyRDFSubject(iri)
        }
        if let blank = subject as? BlankNode {
            return AnyRDFSubject(blank)
        }
        if let iriRepresentable = subject as? any IRIRepresentable {
            return AnyRDFSubject(iriRepresentable.iri)
        }
        return try AnyRDFSubject(subject)
    }

    private func erase<Object: RDFObject>(_ object: Object) -> AnyRDFObject {
        if let object = object as? AnyRDFObject {
            return object
        }
        if let iri = object as? IRI {
            return AnyRDFObject(iri)
        }
        if let blank = object as? BlankNode {
            return AnyRDFObject(blank)
        }
        if let iriRepresentable = object as? any IRIRepresentable {
            return AnyRDFObject(iriRepresentable.iri)
        }
        return AnyRDFObject(object)
    }
}
