import Foundation

public extension OWL {
    /// owl:minCardinality.
    static var minCardinality: MinCardinality { MinCardinality() }

    /// owl:minCardinality.
    struct MinCardinality: RDFKit.RDFProperty, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty {
        /// The rdfs:domain values declared for owl:minCardinality.
        public static let domains: [IRI] = [OWL.Restriction.iri]

        /// Creates an owl:minCardinality term value.
        public init() {}
    }
}
