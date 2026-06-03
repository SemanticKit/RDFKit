import Foundation

public extension OWL {
    /// owl:assertionProperty.
    static var assertionProperty: AssertionProperty { AssertionProperty() }

    /// owl:assertionProperty.
    struct AssertionProperty: RDFKit.Property, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:assertionProperty.
        public static let domains: [IRI] = [OWL.NegativePropertyAssertion.iri]

        /// The rdfs:range values declared for owl:assertionProperty.
        public static let ranges: [IRI] = [RDF.Property.iri]

        /// Creates an owl:assertionProperty term value.
        public init() {}
    }
}
