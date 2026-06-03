import Foundation

public extension OWL {
    /// owl:targetIndividual.
    static var targetIndividual: TargetIndividual { TargetIndividual() }

    /// owl:targetIndividual.
    struct TargetIndividual: RDFKit.Property, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:targetIndividual.
        public static let domains: [IRI] = [OWL.NegativePropertyAssertion.iri]

        /// The rdfs:range values declared for owl:targetIndividual.
        public static let ranges: [IRI] = [OWL.Thing.iri]

        /// Creates an owl:targetIndividual term value.
        public init() {}
    }
}
