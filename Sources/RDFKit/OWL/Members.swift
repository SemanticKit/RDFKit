import Foundation

public extension OWL {
    /// owl:members.
    static var members: Members { Members() }

    /// owl:members.
    struct Members: RDFKit.Property, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:members.
        public static let domains: [IRI] = [RDFS.Resource.iri]

        /// The rdfs:range values declared for owl:members.
        public static let ranges: [IRI] = [RDF.List.iri]

        /// Creates an owl:members term value.
        public init() {}
    }
}
