import Foundation

public extension RDF {
    /// rdf:reifies.
    static var reifies: Reifies { Reifies() }

    /// rdf:reifies.
    struct Reifies: RDFKit.Property, RDFLowerCamelTerm, RelationshipProperty {
        /// Creates an rdf:reifies term value.
        public init() {}
    }
}
