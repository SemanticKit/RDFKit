import IRIKit
import RDFCore
import Synchronization

/// The correspondence between the IRIs of a document and the individuals
/// decoded from it.
///
/// In RDF the IRI is a resource's identity; in Swift the instance is
/// (DESIGN-CONTRACT rule 17). They meet only here, at the boundary: a
/// ``GraphDecoder`` records the IRI of each individual it makes for a node of
/// the document, and a ``GraphEncoder`` given the same context writes each
/// of those individuals back with its IRI. The individual holds no IRI; the
/// context does, as `Decoder.codingPath` belongs to a `Decoder` and not to
/// the value being decoded.
///
///     let context = DocumentContext()
///     let people = try GraphDecoder(classes: [FOAF.PersonIndividual.self])
///         .decode((any FOAF.Person).self, from: graph, context: context)
///     let same = try GraphEncoder(context: context).encode(people)
public final class DocumentContext: Sendable {
    /// One individual and the IRI of the node it was decoded for.
    private struct Correspondence {
        let individual: any Resource
        let iri: IRI
    }

    /// The correspondences, keyed by the individual's identity.
    private let correspondences = Mutex<[ObjectIdentifier: Correspondence]>([:])

    /// A context with no correspondences.
    public init() {}

    /// The IRI of the node `individual` was decoded for, or `nil` for an
    /// individual this context's document does not name.
    public func iri(of individual: any Resource) -> IRI? {
        correspondences.withLock { $0[ObjectIdentifier(individual)]?.iri }
    }

    /// The individual decoded for the node `iri` names, if any.
    public func individual(for iri: IRI) -> (any Resource)? {
        correspondences.withLock { correspondences in
            correspondences.values.first { $0.iri == iri }?.individual
        }
    }

    /// Records that `individual` was decoded for the node `iri` names.
    func record(_ individual: any Resource, for iri: IRI) {
        correspondences.withLock { $0[ObjectIdentifier(individual)] = Correspondence(individual: individual, iri: iri) }
    }
}
