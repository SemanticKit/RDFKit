import Foundation

public extension RDFS {
    /// rdfs:isDefinedBy.
    static var isDefinedBy: IsDefinedBy { IsDefinedBy() }

    /// rdfs:isDefinedBy.
    struct IsDefinedBy: RDFKit.Property, RDFSLowerCamelTerm, RDFKit.AnnotationProperty, DomainConstrainedProperty, RangeConstrainedProperty, SubpropertyAwareProperty {
        /// The rdfs:domain values declared for rdfs:isDefinedBy.
        public static let domains: [IRI] = [RDFS.Resource.iri]

        /// The rdfs:range values declared for rdfs:isDefinedBy.
        public static let ranges: [IRI] = [RDFS.Resource.iri]

        /// The rdfs:subPropertyOf values declared for rdfs:isDefinedBy.
        public static let superproperties: [IRI] = [RDFS.SeeAlso.iri]

        /// Creates an rdfs:isDefinedBy term value.
        public init() {}
    }
}
