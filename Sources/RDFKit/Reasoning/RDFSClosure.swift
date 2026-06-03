import Foundation

private enum RDFSAxioms {
    static func graph() throws -> Graph {
        var graph = Graph()
        for (subject, predicate, object) in classAxioms + propertyAxioms + schemaAxioms {
            let triple = Graph.TripleType(
                subject: AnyRDFSubject(subject.iri),
                predicate: predicate,
                object: AnyRDFObject(object.iri)
            )
            try graph.insert(triple)
        }
        return graph
    }

    private static var classAxioms: [(any RDFSubject & IRIRepresentable, any IRIRepresentable, any RDFObject & IRIRepresentable)] {
        [
            (RDFS.Resource(), RDF.type, RDFS.Class()),
            (RDFS.Class(), RDF.type, RDFS.Class()),
            (RDFS.Literal(), RDF.type, RDFS.Class()),
            (RDFS.Datatype(), RDF.type, RDFS.Class()),
            (RDF.Property(), RDF.type, RDFS.Class()),
            (RDF.Statement(), RDF.type, RDFS.Class()),
            (RDFS.Container(), RDF.type, RDFS.Class()),
            (RDFS.ContainerMembershipProperty(), RDF.type, RDFS.Class()),
            (RDF.List(), RDF.type, RDFS.Class()),
            (RDF.nilValue, RDF.type, RDF.List()),
            (RDF.Alt(), RDF.type, RDFS.Class()),
            (RDF.Bag(), RDF.type, RDFS.Class()),
            (RDF.Seq(), RDF.type, RDFS.Class()),
            (RDF.XMLLiteral(), RDF.type, RDFS.Class()),
            (RDF.HTML(), RDF.type, RDFS.Class()),
            (RDF.JSON(), RDF.type, RDFS.Class())
        ]
    }

    private static var propertyAxioms: [(any RDFSubject & IRIRepresentable, any IRIRepresentable, any RDFObject & IRIRepresentable)] {
        [
            (RDF.type, RDF.type, RDF.Property()),
            (RDF.subject, RDF.type, RDF.Property()),
            (RDF.predicate, RDF.type, RDF.Property()),
            (RDF.object, RDF.type, RDF.Property()),
            (RDF.reifies, RDF.type, RDF.Property()),
            (RDF.first, RDF.type, RDF.Property()),
            (RDF.rest, RDF.type, RDF.Property()),
            (RDF.value, RDF.type, RDF.Property()),
            (RDFS.subClassOf, RDF.type, RDF.Property()),
            (RDFS.subPropertyOf, RDF.type, RDF.Property()),
            (RDFS.domain, RDF.type, RDF.Property()),
            (RDFS.range, RDF.type, RDF.Property()),
            (RDFS.label, RDF.type, RDF.Property()),
            (RDFS.comment, RDF.type, RDF.Property()),
            (RDFS.seeAlso, RDF.type, RDF.Property()),
            (RDFS.isDefinedBy, RDF.type, RDF.Property()),
            (RDFS.member, RDF.type, RDF.Property())
        ]
    }

    private static var schemaAxioms: [(any RDFSubject & IRIRepresentable, any IRIRepresentable, any RDFObject & IRIRepresentable)] {
        [
            (RDF.type, RDFS.domain, RDFS.Resource()),
            (RDF.type, RDFS.range, RDFS.Class()),
            (RDF.reifies, RDFS.domain, RDFS.Resource()),
            (RDFS.subClassOf, RDFS.domain, RDFS.Class()),
            (RDFS.subClassOf, RDFS.range, RDFS.Class()),
            (RDFS.subPropertyOf, RDFS.domain, RDF.Property()),
            (RDFS.subPropertyOf, RDFS.range, RDF.Property()),
            (RDFS.domain, RDFS.domain, RDF.Property()),
            (RDFS.domain, RDFS.range, RDFS.Class()),
            (RDFS.range, RDFS.domain, RDF.Property()),
            (RDFS.range, RDFS.range, RDFS.Class()),
            (RDF.subject, RDFS.domain, RDF.Statement()),
            (RDF.predicate, RDFS.domain, RDF.Statement()),
            (RDF.object, RDFS.domain, RDF.Statement()),
            (RDFS.member, RDFS.domain, RDFS.Resource()),
            (RDF.first, RDFS.domain, RDF.List()),
            (RDF.rest, RDFS.domain, RDF.List()),
            (RDFS.label, RDFS.domain, RDFS.Resource()),
            (RDFS.label, RDFS.range, RDFS.Literal()),
            (RDFS.comment, RDFS.domain, RDFS.Resource()),
            (RDFS.comment, RDFS.range, RDFS.Literal()),
            (RDFS.seeAlso, RDFS.domain, RDFS.Resource()),
            (RDFS.seeAlso, RDFS.range, RDFS.Resource()),
            (RDFS.isDefinedBy, RDFS.domain, RDFS.Resource()),
            (RDFS.isDefinedBy, RDFS.range, RDFS.Resource()),
            (RDF.value, RDFS.domain, RDFS.Resource()),
            (RDFS.ContainerMembershipProperty(), RDFS.subClassOf, RDF.Property()),
            (RDFS.Datatype(), RDFS.subClassOf, RDFS.Class()),
            (RDF.Alt(), RDFS.subClassOf, RDFS.Container()),
            (RDF.Bag(), RDFS.subClassOf, RDFS.Container()),
            (RDF.Seq(), RDFS.subClassOf, RDFS.Container()),
            (RDFS.isDefinedBy, RDFS.subPropertyOf, RDFS.seeAlso),
            (RDF.subject, RDFS.range, RDFS.Resource()),
            (RDF.predicate, RDFS.range, RDFS.Resource()),
            (RDF.object, RDFS.range, RDFS.Resource()),
            (RDFS.member, RDFS.range, RDFS.Resource()),
            (RDF.first, RDFS.range, RDFS.Resource()),
            (RDF.rest, RDFS.range, RDF.List()),
            (RDF.value, RDFS.range, RDFS.Resource())
        ]
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
        return reasoner.computeClosure().merged(with: graph)
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
        self.graph = includeAxioms ? graph.merged(with: try RDFSAxioms.graph()) : graph
        self.includeAxioms = includeAxioms
    }

    mutating func computeClosure() -> Graph {
        var changed = true
        while changed {
            changed = false
            if includeAxioms {
                changed = addContainerMembershipAxioms() || changed
            }

            let snapshot = Array(graph.triples)
            let subproperties = indexIRIObjects(predicate: RDFS.subPropertyOf)
            let subclasses = indexIRIObjects(predicate: RDFS.subClassOf)
            let domains = indexIRIObjects(predicate: RDFS.domain)
            let ranges = indexIRIObjects(predicate: RDFS.range)
            let types = indexIRIObjects(predicate: RDF.type)

            for (property, supers) in subproperties {
                for superproperty in supers {
                    changed = insert(subject: property, predicate: RDFS.subPropertyOf, object: superproperty) || changed
                    for transitive in subproperties[superproperty] ?? [] {
                        changed = insert(subject: property, predicate: RDFS.subPropertyOf, object: transitive) || changed
                    }
                }
            }

            for (subclass, supers) in subclasses {
                for superclass in supers {
                    for transitive in subclasses[superclass] ?? [] {
                        changed = insert(subject: subclass, predicate: RDFS.subClassOf, object: transitive) || changed
                    }
                }
            }

            for triple in snapshot {
                for superproperty in subproperties[triple.predicate] ?? [] {
                    changed = insert(subject: triple.subject, predicate: superproperty, object: triple.object) || changed
                }

                for domain in domains[triple.predicate] ?? [] {
                    changed = insert(subject: triple.subject, predicate: RDF.type, object: domain) || changed
                }

                if let objectSubject = subject(from: triple.object) {
                    for range in ranges[triple.predicate] ?? [] {
                        changed = insert(subject: objectSubject, predicate: RDF.type, object: range) || changed
                    }
                }

                if triple.predicate.rawValue == RDF.type.iri.rawValue, let classIRI = triple.object.node as? IRI {
                    for superclass in subclasses[classIRI] ?? [] {
                        changed = insert(subject: triple.subject, predicate: RDF.type, object: superclass) || changed
                    }
                }
            }

            for (resource, directTypes) in types {
                if directTypes.contains(where: { $0.rawValue == RDFS.ContainerMembershipProperty.iri.rawValue }) {
                    changed = insert(subject: resource, predicate: RDFS.subPropertyOf, object: RDFS.member.iri) || changed
                }
                if directTypes.contains(where: { $0.rawValue == RDFS.Datatype.iri.rawValue }) {
                    changed = insert(subject: resource, predicate: RDFS.subClassOf, object: RDFS.Literal.iri) || changed
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

    private mutating func addContainerMembershipAxioms() -> Bool {
        var changed = false
        for triple in graph.triples {
            let predicate = triple.predicate.rawValue
            guard predicate.hasPrefix(RDF.namespace.rawValue + "_") else { continue }
            changed = insert(subject: triple.predicate, predicate: RDF.type, object: RDF.Property.iri) || changed
            changed = insert(subject: triple.predicate, predicate: RDF.type, object: RDFS.ContainerMembershipProperty.iri) || changed
            changed = insert(subject: triple.predicate, predicate: RDFS.subPropertyOf, object: RDFS.member.iri) || changed
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

    private mutating func insert<Subject: RDFSubject, Predicate: IRIRepresentable, Object: RDFObject>(subject: Subject, predicate: Predicate, object: Object) -> Bool {
        let erasedSubject = erase(subject)
        let erasedObject = erase(object)
        let triple = Graph.TripleType(subject: erasedSubject, predicate: predicate, object: erasedObject)
        if graph.contains(triple) {
            return false
        }
        try! graph.insert(triple)
        return true
    }

    private func erase<Subject: RDFSubject>(_ subject: Subject) -> AnyRDFSubject {
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
        return try! AnyRDFSubject(subject)
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
