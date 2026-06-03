import Foundation

public extension OWL {
    /// owl:versionInfo.
    static var versionInfo: VersionInfo { VersionInfo() }

    /// owl:versionInfo.
    struct VersionInfo: RDFKit.Property, OWLLowerCamelTerm, RDFKit.AnnotationProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:versionInfo.
        public static let domains: [IRI] = [RDFS.Resource.iri]

        /// The rdfs:range values declared for owl:versionInfo.
        public static let ranges: [IRI] = [RDFS.Resource.iri]

        /// Creates an owl:versionInfo term value.
        public init() {}
    }
}
