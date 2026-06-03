import Foundation

public extension OWL {
    /// owl:cardinality.
    static var cardinality: Cardinality { Cardinality() }

    /// owl:cardinality.
    struct Cardinality: RDFKit.RDFProperty, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty {
        /// The rdfs:domain values declared for owl:cardinality.
        public static let domains: [IRI] = [OWL.Restriction.iri]

        /// Creates an owl:cardinality term value.
        public init() {}
    }
}
