import Foundation

public extension RDF {
    /// rdf:langString.
    static var langString: LangString { LangString() }

    /// rdf:langString.
    struct LangString: RDFKit.RDFDatatype, RDFLowerCamelTerm {
        /// Creates an rdf:langString term value.
        public init() {}
    }
}
