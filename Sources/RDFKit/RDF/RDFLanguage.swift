import Foundation

public extension RDF {
    /// rdf:language.
    static var language: Language { Language() }

    /// rdf:language.
    struct Language: RDFKit.Property, RDFLowerCamelTerm {
        /// Creates an rdf:language term value.
        public init() {}
    }
}
