import Foundation

public extension OWL {
    /// owl:qualifiedCardinality.
    static var qualifiedCardinality: QualifiedCardinality { QualifiedCardinality() }

    /// owl:qualifiedCardinality.
    struct QualifiedCardinality: RDFKit.Property, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty {
        /// The rdfs:domain values declared for owl:qualifiedCardinality.
        public static let domains: [IRI] = [OWL.Restriction.iri]

        /// Creates an owl:qualifiedCardinality term value.
        public init() {}
    }
}
