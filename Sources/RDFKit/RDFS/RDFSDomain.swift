import Foundation

public extension RDFS {
    /// rdfs:domain.
    static var domain: Domain { Domain() }

    /// rdfs:domain.
    struct Domain: RDFKit.RDFProperty, RDFSLowerCamelTerm, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for rdfs:domain.
        public static let domains: [IRI] = [RDF.Property.iri]

        /// The rdfs:range values declared for rdfs:domain.
        public static let ranges: [IRI] = [RDFS.Class.iri]

        /// Creates an rdfs:domain term value.
        public init() {}
    }
}
