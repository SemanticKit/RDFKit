import Foundation

/// A predicate and object pair used as attached RDF statement content.
public struct PredicateObjectPair: Hashable, Sendable {
    /// The predicate IRI.
    public let predicate: IRI

    /// The object node.
    public let object: AnyRDFObject

    /// Creates a predicate and object pair.
    public init(predicate: IRI, object: AnyRDFObject) {
        self.predicate = predicate
        self.object = object
    }
}

/// Represents a reified triple term with optional assertion and annotations.
public struct ReifiedTriple: Hashable, Sendable, GraphContent {
    /// The resource that reifies the triple term.
    public let reifier: AnyRDFSubject

    /// The reified triple term.
    public let tripleTerm: TripleTerm

    /// Whether the reified triple is also asserted in the graph.
    public let asserted: Bool

    /// Additional predicate/object content attached to the reifier.
    public let annotations: [PredicateObjectPair]

    /// Creates reified RDF statement content from a triple term.
    public init(
        reifier: AnyRDFSubject,
        tripleTerm: TripleTerm,
        asserted: Bool = false,
        annotations: [PredicateObjectPair] = []
    ) {
        self.reifier = reifier
        self.tripleTerm = tripleTerm
        self.asserted = asserted
        self.annotations = annotations
    }

    /// Creates reified RDF statement content from a graph triple.
    public init(
        reifier: AnyRDFSubject,
        triple: Graph.TripleType,
        asserted: Bool = false,
        annotations: [PredicateObjectPair] = []
    ) {
        self.init(
            reifier: reifier,
            tripleTerm: TripleTerm(subject: triple.subject, predicate: triple.predicate, object: triple.object),
            asserted: asserted,
            annotations: annotations
        )
    }

    /// Writes this reified statement content into a graph.
    public func write(to graph: inout Graph) throws {
        for triple in materializedTriples() {
            try graph.insert(triple)
        }
    }

    private func materializedTriples() -> [Graph.TripleType] {
        var result: [Graph.TripleType] = []

        if asserted {
            result.append(
                Graph.TripleType(
                    subject: tripleTerm.subject,
                    predicate: tripleTerm.predicate,
                    object: tripleTerm.object
                )
            )
        }

        result.append(
            Graph.TripleType(
                subject: reifier,
                predicate: RDF.reifies,
                object: AnyRDFObject(tripleTerm)
            )
        )

        for annotation in annotations {
            result.append(
                Graph.TripleType(
                    subject: reifier,
                    predicate: annotation.predicate,
                    object: annotation.object
                )
            )
        }

        return result
    }
}
