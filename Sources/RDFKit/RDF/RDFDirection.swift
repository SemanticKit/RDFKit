import Foundation

public extension RDF {
    /// rdf:direction.
    static var direction: Direction { Direction() }

    /// rdf:direction.
    struct Direction: RDFKit.RDFProperty, RDFLowerCamelTerm {
        /// Creates an rdf:direction term value.
        public init() {}
    }
}
