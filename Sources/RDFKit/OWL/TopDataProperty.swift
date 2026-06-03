import Foundation

public extension OWL {
    /// owl:topDataProperty.
    static var topDataProperty: TopDataProperty { TopDataProperty() }

    /// owl:topDataProperty.
    struct TopDataProperty: RDFKit.RDFProperty, OWLLowerCamelTerm, RDFKit.DatatypeProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:topDataProperty.
        public static let domains: [IRI] = [OWL.Thing.iri]

        /// The rdfs:range values declared for owl:topDataProperty.
        public static let ranges: [IRI] = [RDFS.Literal.iri]

        /// Creates an owl:topDataProperty term value.
        public init() {}
    }
}
