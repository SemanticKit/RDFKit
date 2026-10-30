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
    /// One IRI for each individual, and one individual for each IRI.
    private struct Correspondences {
        /// The IRI of each individual, keyed by the individual's identity.
        var iris: [ObjectIdentifier: IRI] = [:]
        /// The individual of each IRI.
        var individuals: [IRI: any Resource] = [:]
    }

    private let correspondences = Mutex(Correspondences())

    /// A context with no correspondences.
    public init() {}

    /// The IRI of the node `individual` was decoded for, or `nil` for an
    /// individual this context's document does not name.
    public func iri(of individual: any Resource) -> IRI? {
        correspondences.withLock { $0.iris[ObjectIdentifier(individual)] }
    }

    /// The individual decoded for the node `iri` names, if any.
    public func individual(for iri: IRI) -> (any Resource)? {
        correspondences.withLock { $0.individuals[iri] }
    }

    /// The individual recorded for `iri`, else `make()`, recorded for it.
    ///
    /// The context keeps one individual for each IRI and one IRI for each
    /// individual: `make` runs only when `iri` has none yet, and an
    /// individual it returns that already has another IRI is not recorded
    /// again.
    func individual(for iri: IRI, orRecord make: () -> any Resource) -> any Resource {
        correspondences.withLock { correspondences in
            if let individual = correspondences.individuals[iri] { return individual }
            let individual = make()
            let identity = ObjectIdentifier(individual)
            if correspondences.iris[identity] == nil {
                correspondences.iris[identity] = iri
                correspondences.individuals[iri] = individual
            }
            return individual
        }
    }
}
