import Foundation

public extension RDF {
    /// rdf:value.
    static var value: Value { Value() }

    /// rdf:value.
    struct Value: RDFKit.Property, RDFLowerCamelTerm {
        /// Creates an rdf:value term value.
        public init() {}
    }
}
