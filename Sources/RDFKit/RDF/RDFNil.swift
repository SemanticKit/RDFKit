import Foundation

public extension RDF {
    /// rdf:nil.
    static var nilValue: Nil { Nil() }

    /// rdf:nil.
    struct Nil: RDFKit.Individual, RDFLowerCamelTerm {
        /// Creates an rdf:nil term value.
        public init() {}
    }
}
