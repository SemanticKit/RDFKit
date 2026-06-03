import Foundation

public extension OWL {
    /// owl:oneOf.
    static var oneOf: OneOf { OneOf() }

    /// owl:oneOf.
    struct OneOf: RDFKit.Property, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:oneOf.
        public static let domains: [IRI] = [RDFS.Class.iri]

        /// The rdfs:range values declared for owl:oneOf.
        public static let ranges: [IRI] = [RDF.List.iri]

        /// Creates an owl:oneOf term value.
        public init() {}
    }
}
