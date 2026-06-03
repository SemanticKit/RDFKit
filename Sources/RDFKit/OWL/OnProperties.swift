import Foundation

public extension OWL {
    /// owl:onProperties.
    static var onProperties: OnProperties { OnProperties() }

    /// owl:onProperties.
    struct OnProperties: RDFKit.RDFProperty, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:onProperties.
        public static let domains: [IRI] = [OWL.Restriction.iri]

        /// The rdfs:range values declared for owl:onProperties.
        public static let ranges: [IRI] = [RDF.List.iri]

        /// Creates an owl:onProperties term value.
        public init() {}
    }
}
