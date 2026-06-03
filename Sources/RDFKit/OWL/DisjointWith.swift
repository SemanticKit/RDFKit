import Foundation

public extension OWL {
    /// owl:disjointWith.
    static var disjointWith: DisjointWith { DisjointWith() }

    /// owl:disjointWith.
    struct DisjointWith: RDFKit.RDFProperty, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:disjointWith.
        public static let domains: [IRI] = [OWL.Class.iri]

        /// The rdfs:range values declared for owl:disjointWith.
        public static let ranges: [IRI] = [OWL.Class.iri]

        /// Creates an owl:disjointWith term value.
        public init() {}
    }
}
