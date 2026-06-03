import Foundation

public extension OWL {
    /// owl:hasKey.
    static var hasKey: HasKey { HasKey() }

    /// owl:hasKey.
    struct HasKey: RDFKit.Property, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:hasKey.
        public static let domains: [IRI] = [OWL.Class.iri]

        /// The rdfs:range values declared for owl:hasKey.
        public static let ranges: [IRI] = [RDF.List.iri]

        /// Creates an owl:hasKey term value.
        public init() {}
    }
}
