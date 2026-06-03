import Foundation

public extension OWL {
    /// owl:targetValue.
    static var targetValue: TargetValue { TargetValue() }

    /// owl:targetValue.
    struct TargetValue: RDFKit.RDFProperty, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:targetValue.
        public static let domains: [IRI] = [OWL.NegativePropertyAssertion.iri]

        /// The rdfs:range values declared for owl:targetValue.
        public static let ranges: [IRI] = [RDFS.Literal.iri]

        /// Creates an owl:targetValue term value.
        public init() {}
    }
}
