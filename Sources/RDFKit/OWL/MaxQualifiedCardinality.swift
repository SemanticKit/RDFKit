import Foundation

public extension OWL {
    /// owl:maxQualifiedCardinality.
    static var maxQualifiedCardinality: MaxQualifiedCardinality { MaxQualifiedCardinality() }

    /// owl:maxQualifiedCardinality.
    struct MaxQualifiedCardinality: RDFKit.RDFProperty, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty {
        /// The rdfs:domain values declared for owl:maxQualifiedCardinality.
        public static let domains: [IRI] = [OWL.Restriction.iri]

        /// Creates an owl:maxQualifiedCardinality term value.
        public init() {}
    }
}
