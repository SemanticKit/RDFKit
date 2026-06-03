import Foundation

public extension OWL {
    /// owl:bottomObjectProperty.
    static var bottomObjectProperty: BottomObjectProperty { BottomObjectProperty() }

    /// owl:bottomObjectProperty.
    struct BottomObjectProperty: RDFKit.Property, OWLLowerCamelTerm, RDFKit.ObjectProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:bottomObjectProperty.
        public static let domains: [IRI] = [OWL.Thing.iri]

        /// The rdfs:range values declared for owl:bottomObjectProperty.
        public static let ranges: [IRI] = [OWL.Thing.iri]

        /// Creates an owl:bottomObjectProperty term value.
        public init() {}
    }
}
