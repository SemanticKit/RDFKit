import Foundation

public extension OWL {
    /// owl:maxCardinality.
    static var maxCardinality: MaxCardinality { MaxCardinality() }

    /// owl:maxCardinality.
    struct MaxCardinality: RDFKit.Property, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty {
        /// The rdfs:domain values declared for owl:maxCardinality.
        public static let domains: [IRI] = [OWL.Restriction.iri]

        /// Creates an owl:maxCardinality term value.
        public init() {}
    }
}
