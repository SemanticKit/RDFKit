import Foundation

public extension OWL {
    /// owl:sameAs.
    static var sameAs: SameAs { SameAs() }

    /// owl:sameAs.
    struct SameAs: RDFKit.Property, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:sameAs.
        public static let domains: [IRI] = [OWL.Thing.iri]

        /// The rdfs:range values declared for owl:sameAs.
        public static let ranges: [IRI] = [OWL.Thing.iri]

        /// Creates an owl:sameAs term value.
        public init() {}
    }
}
