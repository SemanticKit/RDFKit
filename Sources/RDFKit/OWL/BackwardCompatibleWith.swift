import Foundation

public extension OWL {
    /// owl:backwardCompatibleWith.
    static var backwardCompatibleWith: BackwardCompatibleWith { BackwardCompatibleWith() }

    /// owl:backwardCompatibleWith.
    struct BackwardCompatibleWith: RDFKit.RDFProperty, OWLLowerCamelTerm, RDFKit.AnnotationProperty, RDFKit.OntologyProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:backwardCompatibleWith.
        public static let domains: [IRI] = [OWL.Ontology.iri]

        /// The rdfs:range values declared for owl:backwardCompatibleWith.
        public static let ranges: [IRI] = [OWL.Ontology.iri]

        /// Creates an owl:backwardCompatibleWith term value.
        public init() {}
    }
}
