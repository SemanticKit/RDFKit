import Foundation

public extension OWL {
    /// owl:versionIRI.
    static var versionIRI: VersionIRI { VersionIRI() }

    /// owl:versionIRI.
    struct VersionIRI: RDFKit.RDFProperty, OWLLowerCamelTerm, RDFKit.OntologyProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:versionIRI.
        public static let domains: [IRI] = [OWL.Ontology.iri]

        /// The rdfs:range values declared for owl:versionIRI.
        public static let ranges: [IRI] = [OWL.Ontology.iri]

        /// Creates an owl:versionIRI term value.
        public init() {}
    }
}
