import Foundation

public extension OWL {
    /// owl:disjointUnionOf.
    static var disjointUnionOf: DisjointUnionOf { DisjointUnionOf() }

    /// owl:disjointUnionOf.
    struct DisjointUnionOf: RDFKit.Property, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:disjointUnionOf.
        public static let domains: [IRI] = [OWL.Class.iri]

        /// The rdfs:range values declared for owl:disjointUnionOf.
        public static let ranges: [IRI] = [RDF.List.iri]

        /// Creates an owl:disjointUnionOf term value.
        public init() {}
    }
}
