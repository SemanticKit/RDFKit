import Foundation

public extension RDFS {
    /// rdfs:subClassOf.
    static var subClassOf: SubClassOf { SubClassOf() }

    /// rdfs:subClassOf.
    struct SubClassOf: RDFKit.Property, RDFSLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for rdfs:subClassOf.
        public static let domains: [IRI] = [RDFS.Class.iri]

        /// The rdfs:range values declared for rdfs:subClassOf.
        public static let ranges: [IRI] = [RDFS.Class.iri]

        /// Creates an rdfs:subClassOf term value.
        public init() {}
    }
}
