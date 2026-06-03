import Foundation

public extension OWL {
    /// owl:minQualifiedCardinality.
    static var minQualifiedCardinality: MinQualifiedCardinality { MinQualifiedCardinality() }

    /// owl:minQualifiedCardinality.
    struct MinQualifiedCardinality: RDFKit.Property, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty {
        /// The rdfs:domain values declared for owl:minQualifiedCardinality.
        public static let domains: [IRI] = [OWL.Restriction.iri]

        /// Creates an owl:minQualifiedCardinality term value.
        public init() {}
    }
}
