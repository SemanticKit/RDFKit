import Foundation

public extension RDF {
    /// rdf:subject.
    static var subject: Subject { Subject() }

    /// rdf:subject.
    struct Subject: RDFKit.RDFProperty, RDFLowerCamelTerm {
        /// Creates an rdf:subject term value.
        public init() {}
    }
}
