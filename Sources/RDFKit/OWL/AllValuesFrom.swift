import Foundation

public extension OWL {
    /// owl:allValuesFrom.
    static var allValuesFrom: AllValuesFrom { AllValuesFrom() }

    /// owl:allValuesFrom.
    struct AllValuesFrom: RDFKit.RDFProperty, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:allValuesFrom.
        public static let domains: [IRI] = [OWL.Restriction.iri]

        /// The rdfs:range values declared for owl:allValuesFrom.
        public static let ranges: [IRI] = [RDFS.Class.iri]

        /// Creates an owl:allValuesFrom term value.
        public init() {}
    }
}
