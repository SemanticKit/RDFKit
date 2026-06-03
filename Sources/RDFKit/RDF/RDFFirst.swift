import Foundation

public extension RDF {
    /// rdf:first.
    static var first: First { First() }

    /// rdf:first.
    struct First: RDFKit.Property, RDFLowerCamelTerm, RelationshipProperty {
        /// Creates an rdf:first term value.
        public init() {}
    }
}
