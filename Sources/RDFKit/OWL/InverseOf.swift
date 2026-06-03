import Foundation

public extension OWL {
    /// owl:inverseOf.
    static var inverseOf: InverseOf { InverseOf() }

    /// owl:inverseOf.
    struct InverseOf: RDFKit.RDFProperty, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:inverseOf.
        public static let domains: [IRI] = [OWL.ObjectProperty.iri]

        /// The rdfs:range values declared for owl:inverseOf.
        public static let ranges: [IRI] = [OWL.ObjectProperty.iri]

        /// Creates an owl:inverseOf term value.
        public init() {}
    }
}
