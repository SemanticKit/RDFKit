import Foundation

public extension OWL {
    /// owl:equivalentClass.
    static var equivalentClass: EquivalentClass { EquivalentClass() }

    /// owl:equivalentClass.
    struct EquivalentClass: RDFKit.RDFProperty, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:equivalentClass.
        public static let domains: [IRI] = [RDFS.Class.iri]

        /// The rdfs:range values declared for owl:equivalentClass.
        public static let ranges: [IRI] = [RDFS.Class.iri]

        /// Creates an owl:equivalentClass term value.
        public init() {}
    }
}
