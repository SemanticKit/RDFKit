import Foundation

public extension OWL {
    /// owl:priorVersion.
    static var priorVersion: PriorVersion { PriorVersion() }

    /// owl:priorVersion.
    struct PriorVersion: RDFKit.Property, OWLLowerCamelTerm, RDFKit.AnnotationProperty, RDFKit.OntologyProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:priorVersion.
        public static let domains: [IRI] = [OWL.Ontology.iri]

        /// The rdfs:range values declared for owl:priorVersion.
        public static let ranges: [IRI] = [OWL.Ontology.iri]

        /// Creates an owl:priorVersion term value.
        public init() {}
    }
}
