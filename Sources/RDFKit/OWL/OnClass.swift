import Foundation

public extension OWL {
    /// owl:onClass.
    static var onClass: OnClass { OnClass() }

    /// owl:onClass.
    struct OnClass: RDFKit.Property, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:onClass.
        public static let domains: [IRI] = [OWL.Restriction.iri]

        /// The rdfs:range values declared for owl:onClass.
        public static let ranges: [IRI] = [OWL.Class.iri]

        /// Creates an owl:onClass term value.
        public init() {}
    }
}
