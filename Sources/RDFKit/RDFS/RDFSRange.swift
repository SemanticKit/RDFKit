import Foundation

public extension RDFS {
    /// rdfs:range.
    static var range: Range { Range() }

    /// rdfs:range.
    struct Range: RDFKit.RDFProperty, RDFSLowerCamelTerm, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for rdfs:range.
        public static let domains: [IRI] = [RDF.Property.iri]

        /// The rdfs:range values declared for rdfs:range.
        public static let ranges: [IRI] = [RDFS.Class.iri]

        /// Creates an rdfs:range term value.
        public init() {}
    }
}
