import Foundation

public extension RDFS {
    /// rdfs:label.
    static var label: Label { Label() }

    /// rdfs:label.
    struct Label: RDFKit.Property, RDFSLowerCamelTerm, RDFKit.AnnotationProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for rdfs:label.
        public static let domains: [IRI] = [RDFS.Resource.iri]

        /// The rdfs:range values declared for rdfs:label.
        public static let ranges: [IRI] = [RDFS.Literal.iri]

        /// Creates an rdfs:label term value.
        public init() {}
    }
}
