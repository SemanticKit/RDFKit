import Foundation

public extension RDFS {
    /// rdfs:comment.
    static var comment: Comment { Comment() }

    /// rdfs:comment.
    struct Comment: RDFKit.RDFProperty, RDFSLowerCamelTerm, RDFKit.AnnotationProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for rdfs:comment.
        public static let domains: [IRI] = [RDFS.Resource.iri]

        /// The rdfs:range values declared for rdfs:comment.
        public static let ranges: [IRI] = [RDFS.Literal.iri]

        /// Creates an rdfs:comment term value.
        public init() {}
    }
}
