import Foundation

public extension RDF {
    /// rdf:predicate.
    static var predicate: Predicate { Predicate() }

    /// rdf:predicate.
    struct Predicate: RDFKit.Property, RDFLowerCamelTerm {
        /// Creates an rdf:predicate term value.
        public init() {}
    }
}
