import Foundation

public extension OWL {
    /// owl:annotatedTarget.
    static var annotatedTarget: AnnotatedTarget { AnnotatedTarget() }

    /// owl:annotatedTarget.
    struct AnnotatedTarget: RDFKit.RDFProperty, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:annotatedTarget.
        public static let domains: [IRI] = [RDFS.Resource.iri]

        /// The rdfs:range values declared for owl:annotatedTarget.
        public static let ranges: [IRI] = [RDFS.Resource.iri]

        /// Creates an owl:annotatedTarget term value.
        public init() {}
    }
}
