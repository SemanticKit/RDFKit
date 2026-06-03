import Foundation

public extension OWL {
    /// owl:annotatedProperty.
    static var annotatedProperty: AnnotatedProperty { AnnotatedProperty() }

    /// owl:annotatedProperty.
    struct AnnotatedProperty: RDFKit.Property, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:annotatedProperty.
        public static let domains: [IRI] = [RDFS.Resource.iri]

        /// The rdfs:range values declared for owl:annotatedProperty.
        public static let ranges: [IRI] = [RDFS.Resource.iri]

        /// Creates an owl:annotatedProperty term value.
        public init() {}
    }
}
