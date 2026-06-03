import Foundation

public extension RDFS {
    /// rdfs:subPropertyOf.
    static var subPropertyOf: SubPropertyOf { SubPropertyOf() }

    /// rdfs:subPropertyOf.
    struct SubPropertyOf: RDFKit.Property, RDFSLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for rdfs:subPropertyOf.
        public static let domains: [IRI] = [RDF.Property.iri]

        /// The rdfs:range values declared for rdfs:subPropertyOf.
        public static let ranges: [IRI] = [RDF.Property.iri]

        /// Creates an rdfs:subPropertyOf term value.
        public init() {}
    }
}
