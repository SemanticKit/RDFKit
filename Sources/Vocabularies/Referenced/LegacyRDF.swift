import RDFCore
import RDFKit

/// The terms in the RDF namespace that published vocabularies use but RDF 1.2
/// does not define.
///
/// Namespace `http://www.w3.org/1999/02/22-rdf-syntax-ns#`. RDFKit's `RDF`
/// ontology declares exactly what RDF 1.2 defines, so these terms are kept
/// apart from it: `rdf:Resource`, which the LDP vocabulary names as the range
/// of `ldp:pageSortOrder`. Every range is an `rdfs:Class`, so it is declared
/// as a class and nothing more. Each IRI still has one Swift type.
@Ontology
public struct LegacyRDF: Ontology {
    public init() {}

    public func content() -> Content {
        Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#")

        Class("Resource") {
            Type(RDFS.Class)
        }
    }
}
