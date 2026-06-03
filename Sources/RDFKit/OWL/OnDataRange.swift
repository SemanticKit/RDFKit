import Foundation

public extension OWL {
    /// owl:onDataRange.
    static var onDataRange: OnDataRange { OnDataRange() }

    /// owl:onDataRange.
    struct OnDataRange: RDFKit.Property, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:onDataRange.
        public static let domains: [IRI] = [OWL.Restriction.iri]

        /// The rdfs:range values declared for owl:onDataRange.
        public static let ranges: [IRI] = [RDFS.Datatype.iri]

        /// Creates an owl:onDataRange term value.
        public init() {}
    }
}
