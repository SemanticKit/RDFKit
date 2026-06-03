import Foundation

public extension OWL {
    /// owl:bottomDataProperty.
    static var bottomDataProperty: BottomDataProperty { BottomDataProperty() }

    /// owl:bottomDataProperty.
    struct BottomDataProperty: RDFKit.RDFProperty, OWLLowerCamelTerm, RDFKit.DatatypeProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:bottomDataProperty.
        public static let domains: [IRI] = [OWL.Thing.iri]

        /// The rdfs:range values declared for owl:bottomDataProperty.
        public static let ranges: [IRI] = [RDFS.Literal.iri]

        /// Creates an owl:bottomDataProperty term value.
        public init() {}
    }
}
