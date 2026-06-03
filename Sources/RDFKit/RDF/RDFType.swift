import Foundation

public extension RDF {
    /// rdf:type.
    static var type: TypeTerm { TypeTerm() }

    /// rdf:type.
    struct TypeTerm: RDFKit.RDFProperty, RDFTerm, RelationshipProperty {
        /// The RDF local name.
        public static let localName = LocalName("type")

        /// Creates an rdf:type term value.
        public init() {}
    }
}
