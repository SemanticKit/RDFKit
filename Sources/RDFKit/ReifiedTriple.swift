import Foundation

/// Represents RDF reification content for a triple with optional assertion and annotations.
public struct ReifiedTriple: Hashable, Sendable, GraphContent {
    /// The resource that reifies the triple.
    public let reifier: AnyRDFSubject

    /// The RDF triple being reified.
    public let triple: Graph.TripleType

    /// Whether the reified triple is also asserted in the graph.
    public let asserted: Bool

    /// Additional predicate/object content attached to the reifier.
    public let annotations: [PredicateObjectPair]

    /// Creates RDF reification content from a stored graph triple.
    public init(
        reifier: AnyRDFSubject,
        triple: Graph.TripleType,
        asserted: Bool = false,
        annotations: [PredicateObjectPair] = []
    ) {
        self.reifier = reifier
        self.triple = triple
        self.asserted = asserted
        self.annotations = annotations
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
                    subject: triple.subject,
                    predicate: triple.predicate,
                    object: triple.object
                )
            )
        }

        result.append(
            Graph.TripleType(
                subject: reifier,
                predicate: RDF.reifies,
                object: AnyRDFObject(triple)
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
