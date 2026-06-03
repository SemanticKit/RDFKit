import Foundation

public extension OWL {
    /// owl:unionOf.
    static var unionOf: UnionOf { UnionOf() }

    /// owl:unionOf.
    struct UnionOf: RDFKit.RDFProperty, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:unionOf.
        public static let domains: [IRI] = [RDFS.Class.iri]

        /// The rdfs:range values declared for owl:unionOf.
        public static let ranges: [IRI] = [RDF.List.iri]

        /// Creates an owl:unionOf term value.
        public init() {}
    }
}
