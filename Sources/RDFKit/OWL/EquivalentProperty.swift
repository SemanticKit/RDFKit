import Foundation

public extension OWL {
    /// owl:equivalentProperty.
    static var equivalentProperty: EquivalentProperty { EquivalentProperty() }

    /// owl:equivalentProperty.
    struct EquivalentProperty: RDFKit.RDFProperty, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:equivalentProperty.
        public static let domains: [IRI] = [RDF.Property.iri]

        /// The rdfs:range values declared for owl:equivalentProperty.
        public static let ranges: [IRI] = [RDF.Property.iri]

        /// Creates an owl:equivalentProperty term value.
        public init() {}
    }
}
