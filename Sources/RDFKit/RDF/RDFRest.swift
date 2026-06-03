import Foundation

public extension RDF {
    /// rdf:rest.
    static var rest: Rest { Rest() }

    /// rdf:rest.
    struct Rest: RDFKit.Property, RDFLowerCamelTerm, RelationshipProperty {
        /// Creates an rdf:rest term value.
        public init() {}
    }
}
