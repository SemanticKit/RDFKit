import Foundation

public extension OWL {
    /// owl:datatypeComplementOf.
    static var datatypeComplementOf: DatatypeComplementOf { DatatypeComplementOf() }

    /// owl:datatypeComplementOf.
    struct DatatypeComplementOf: RDFKit.RDFProperty, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:datatypeComplementOf.
        public static let domains: [IRI] = [RDFS.Datatype.iri]

        /// The rdfs:range values declared for owl:datatypeComplementOf.
        public static let ranges: [IRI] = [RDFS.Datatype.iri]

        /// Creates an owl:datatypeComplementOf term value.
        public init() {}
    }
}
