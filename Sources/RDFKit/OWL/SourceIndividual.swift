import Foundation

public extension OWL {
    /// owl:sourceIndividual.
    static var sourceIndividual: SourceIndividual { SourceIndividual() }

    /// owl:sourceIndividual.
    struct SourceIndividual: RDFKit.Property, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:sourceIndividual.
        public static let domains: [IRI] = [OWL.NegativePropertyAssertion.iri]

        /// The rdfs:range values declared for owl:sourceIndividual.
        public static let ranges: [IRI] = [OWL.Thing.iri]

        /// Creates an owl:sourceIndividual term value.
        public init() {}
    }
}
