import Foundation

public extension OWL {
    /// owl:imports.
    static var imports: Imports { Imports() }

    /// owl:imports.
    struct Imports: RDFKit.Property, OWLLowerCamelTerm, RDFKit.OntologyProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:imports.
        public static let domains: [IRI] = [OWL.Ontology.iri]

        /// The rdfs:range values declared for owl:imports.
        public static let ranges: [IRI] = [OWL.Ontology.iri]

        /// Creates an owl:imports term value.
        public init() {}
    }
}
