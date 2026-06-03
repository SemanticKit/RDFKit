import Foundation

public extension RDFS {
    /// rdfs:member.
    static var member: Member { Member() }

    /// rdfs:member.
    struct Member: RDFKit.Property, RDFSLowerCamelTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        /// The rdfs:domain values declared for rdfs:member.
        public static let domains: [IRI] = [RDFS.Resource.iri]

        /// The rdfs:range values declared for rdfs:member.
        public static let ranges: [IRI] = [RDFS.Resource.iri]

        /// Creates an rdfs:member term value.
        public init() {}
    }
}
