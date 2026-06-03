import Foundation

public extension OWL {
    /// owl:hasValue.
    static var hasValue: HasValue { HasValue() }

    /// owl:hasValue.
    struct HasValue: RDFKit.RDFProperty, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:hasValue.
        public static let domains: [IRI] = [OWL.Restriction.iri]

        /// The rdfs:range values declared for owl:hasValue.
        public static let ranges: [IRI] = [RDFS.Resource.iri]

        /// Creates an owl:hasValue term value.
        public init() {}
    }
}
