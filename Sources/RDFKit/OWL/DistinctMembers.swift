import Foundation

public extension OWL {
    /// owl:distinctMembers.
    static var distinctMembers: DistinctMembers { DistinctMembers() }

    /// owl:distinctMembers.
    struct DistinctMembers: RDFKit.Property, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:distinctMembers.
        public static let domains: [IRI] = [OWL.AllDifferent.iri]

        /// The rdfs:range values declared for owl:distinctMembers.
        public static let ranges: [IRI] = [RDF.List.iri]

        /// Creates an owl:distinctMembers term value.
        public init() {}
    }
}
