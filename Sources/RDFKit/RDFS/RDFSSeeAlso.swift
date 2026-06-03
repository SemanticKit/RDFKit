import Foundation

public extension RDFS {
    /// rdfs:seeAlso.
    static var seeAlso: SeeAlso { SeeAlso() }

    /// rdfs:seeAlso.
    struct SeeAlso: RDFKit.Property, RDFSLowerCamelTerm, RDFKit.AnnotationProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for rdfs:seeAlso.
        public static let domains: [IRI] = [RDFS.Resource.iri]

        /// The rdfs:range values declared for rdfs:seeAlso.
        public static let ranges: [IRI] = [RDFS.Resource.iri]

        /// Creates an rdfs:seeAlso term value.
        public init() {}
    }
}
