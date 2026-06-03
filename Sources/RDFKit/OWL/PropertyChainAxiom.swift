import Foundation

public extension OWL {
    /// owl:propertyChainAxiom.
    static var propertyChainAxiom: PropertyChainAxiom { PropertyChainAxiom() }

    /// owl:propertyChainAxiom.
    struct PropertyChainAxiom: RDFKit.RDFProperty, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:propertyChainAxiom.
        public static let domains: [IRI] = [OWL.ObjectProperty.iri]

        /// The rdfs:range values declared for owl:propertyChainAxiom.
        public static let ranges: [IRI] = [RDF.List.iri]

        /// Creates an owl:propertyChainAxiom term value.
        public init() {}
    }
}
