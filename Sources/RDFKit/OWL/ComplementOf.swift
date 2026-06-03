import Foundation

public extension OWL {
    /// owl:complementOf.
    static var complementOf: ComplementOf { ComplementOf() }

    /// owl:complementOf.
    struct ComplementOf: RDFKit.RDFProperty, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:complementOf.
        public static let domains: [IRI] = [OWL.Class.iri]

        /// The rdfs:range values declared for owl:complementOf.
        public static let ranges: [IRI] = [OWL.Class.iri]

        /// Creates an owl:complementOf term value.
        public init() {}
    }
}
