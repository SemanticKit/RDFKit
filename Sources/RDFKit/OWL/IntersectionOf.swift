import Foundation

public extension OWL {
    /// owl:intersectionOf.
    static var intersectionOf: IntersectionOf { IntersectionOf() }

    /// owl:intersectionOf.
    struct IntersectionOf: RDFKit.Property, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:intersectionOf.
        public static let domains: [IRI] = [RDFS.Class.iri]

        /// The rdfs:range values declared for owl:intersectionOf.
        public static let ranges: [IRI] = [RDF.List.iri]

        /// Creates an owl:intersectionOf term value.
        public init() {}
    }
}
