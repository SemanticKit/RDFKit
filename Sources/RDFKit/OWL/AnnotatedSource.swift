import Foundation

public extension OWL {
    /// owl:annotatedSource.
    static var annotatedSource: AnnotatedSource { AnnotatedSource() }

    /// owl:annotatedSource.
    struct AnnotatedSource: RDFKit.Property, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:annotatedSource.
        public static let domains: [IRI] = [RDFS.Resource.iri]

        /// The rdfs:range values declared for owl:annotatedSource.
        public static let ranges: [IRI] = [RDFS.Resource.iri]

        /// Creates an owl:annotatedSource term value.
        public init() {}
    }
}
