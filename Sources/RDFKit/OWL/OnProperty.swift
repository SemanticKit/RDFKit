import Foundation

public extension OWL {
    /// owl:onProperty.
    static var onProperty: OnProperty { OnProperty() }

    /// owl:onProperty.
    struct OnProperty: RDFKit.RDFProperty, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:onProperty.
        public static let domains: [IRI] = [OWL.Restriction.iri]

        /// The rdfs:range values declared for owl:onProperty.
        public static let ranges: [IRI] = [RDF.Property.iri]

        /// Creates an owl:onProperty term value.
        public init() {}
    }
}
