import Foundation

public extension OWL {
    /// owl:differentFrom.
    static var differentFrom: DifferentFrom { DifferentFrom() }

    /// owl:differentFrom.
    struct DifferentFrom: RDFKit.Property, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:differentFrom.
        public static let domains: [IRI] = [OWL.Thing.iri]

        /// The rdfs:range values declared for owl:differentFrom.
        public static let ranges: [IRI] = [OWL.Thing.iri]

        /// Creates an owl:differentFrom term value.
        public init() {}
    }
}
