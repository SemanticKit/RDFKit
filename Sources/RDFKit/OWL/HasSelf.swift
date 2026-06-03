import Foundation

public extension OWL {
    /// owl:hasSelf.
    static var hasSelf: HasSelf { HasSelf() }

    /// owl:hasSelf.
    struct HasSelf: RDFKit.Property, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:hasSelf.
        public static let domains: [IRI] = [OWL.Restriction.iri]

        /// The rdfs:range values declared for owl:hasSelf.
        public static let ranges: [IRI] = [RDFS.Resource.iri]

        /// Creates an owl:hasSelf term value.
        public init() {}
    }
}
