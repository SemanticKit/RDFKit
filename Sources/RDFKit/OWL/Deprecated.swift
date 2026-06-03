import Foundation

public extension OWL {
    /// owl:deprecated.
    static var deprecated: Deprecated { Deprecated() }

    /// owl:deprecated.
    struct Deprecated: RDFKit.Property, OWLLowerCamelTerm, RDFKit.AnnotationProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:deprecated.
        public static let domains: [IRI] = [RDFS.Resource.iri]

        /// The rdfs:range values declared for owl:deprecated.
        public static let ranges: [IRI] = [RDFS.Resource.iri]

        /// Creates an owl:deprecated term value.
        public init() {}
    }
}
