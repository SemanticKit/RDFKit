import Foundation

public extension OWL {
    /// owl:withRestrictions.
    static var withRestrictions: WithRestrictions { WithRestrictions() }

    /// owl:withRestrictions.
    struct WithRestrictions: RDFKit.RDFProperty, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:withRestrictions.
        public static let domains: [IRI] = [RDFS.Datatype.iri]

        /// The rdfs:range values declared for owl:withRestrictions.
        public static let ranges: [IRI] = [RDF.List.iri]

        /// Creates an owl:withRestrictions term value.
        public init() {}
    }
}
