import Foundation

public extension OWL {
    /// owl:someValuesFrom.
    static var someValuesFrom: SomeValuesFrom { SomeValuesFrom() }

    /// owl:someValuesFrom.
    struct SomeValuesFrom: RDFKit.Property, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:someValuesFrom.
        public static let domains: [IRI] = [OWL.Restriction.iri]

        /// The rdfs:range values declared for owl:someValuesFrom.
        public static let ranges: [IRI] = [RDFS.Class.iri]

        /// Creates an owl:someValuesFrom term value.
        public init() {}
    }
}
