import Foundation

public extension OWL {
    /// owl:propertyDisjointWith.
    static var propertyDisjointWith: PropertyDisjointWith { PropertyDisjointWith() }

    /// owl:propertyDisjointWith.
    struct PropertyDisjointWith: RDFKit.RDFProperty, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:propertyDisjointWith.
        public static let domains: [IRI] = [RDF.Property.iri]

        /// The rdfs:range values declared for owl:propertyDisjointWith.
        public static let ranges: [IRI] = [RDF.Property.iri]

        /// Creates an owl:propertyDisjointWith term value.
        public init() {}
    }
}
