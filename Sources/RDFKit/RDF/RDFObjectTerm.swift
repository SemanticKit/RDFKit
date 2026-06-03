import Foundation

public extension RDF {
    /// rdf:object.
    static var object: Object { Object() }

    /// rdf:object.
    struct Object: RDFKit.Property, RDFLowerCamelTerm {
        /// Creates an rdf:object term value.
        public init() {}
    }
}
