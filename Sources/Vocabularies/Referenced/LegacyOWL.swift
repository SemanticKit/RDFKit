import RDFCore
import RDFKit

/// The terms in the OWL namespace that published vocabularies use but OWL 2
/// does not define.
///
/// Namespace `http://www.w3.org/2002/07/owl#`. RDFKit's `OWL` ontology
/// declares exactly what OWL 2 defines, so these terms are kept apart from it:
/// `owl:Individual`, which the LDP vocabulary gives its named individuals as
/// their `rdf:type`. Every `rdf:type` object is an `rdfs:Class`, so it is
/// declared as a class and nothing more. Each IRI still has one Swift type.
@Ontology
public struct LegacyOWL: Ontology {
    public init() {}

    public func content() -> Content {
        Namespace("http://www.w3.org/2002/07/owl#")

        Class("Individual") {
            Type(RDFS.Class)
        }
    }
}
