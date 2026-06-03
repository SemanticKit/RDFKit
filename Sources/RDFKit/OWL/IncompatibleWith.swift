import Foundation

public extension OWL {
    /// owl:incompatibleWith.
    static var incompatibleWith: IncompatibleWith { IncompatibleWith() }

    /// owl:incompatibleWith.
    struct IncompatibleWith: RDFKit.RDFProperty, OWLLowerCamelTerm, RDFKit.AnnotationProperty, RDFKit.OntologyProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:incompatibleWith.
        public static let domains: [IRI] = [OWL.Ontology.iri]

        /// The rdfs:range values declared for owl:incompatibleWith.
        public static let ranges: [IRI] = [OWL.Ontology.iri]

        /// Creates an owl:incompatibleWith term value.
        public init() {}
    }
}
