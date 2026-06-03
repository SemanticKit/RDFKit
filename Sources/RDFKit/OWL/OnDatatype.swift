import Foundation

public extension OWL {
    /// owl:onDatatype.
    static var onDatatype: OnDatatype { OnDatatype() }

    /// owl:onDatatype.
    struct OnDatatype: RDFKit.Property, OWLLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for owl:onDatatype.
        public static let domains: [IRI] = [RDFS.Datatype.iri]

        /// The rdfs:range values declared for owl:onDatatype.
        public static let ranges: [IRI] = [RDFS.Datatype.iri]

        /// Creates an owl:onDatatype term value.
        public init() {}
    }
}
