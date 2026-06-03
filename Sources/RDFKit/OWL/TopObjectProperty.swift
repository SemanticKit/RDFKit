import Foundation

public extension OWL {
    /// owl:topObjectProperty.
    static var topObjectProperty: TopObjectProperty { TopObjectProperty() }

    /// owl:topObjectProperty.
    struct TopObjectProperty: RDFKit.RDFProperty, OWLLowerCamelTerm, RDFKit.ObjectProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:topObjectProperty.
        public static let domains: [IRI] = [OWL.Thing.iri]

        /// The rdfs:range values declared for owl:topObjectProperty.
        public static let ranges: [IRI] = [OWL.Thing.iri]

        /// Creates an owl:topObjectProperty term value.
        public init() {}
    }
}
