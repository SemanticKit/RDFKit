import RDFCore
import RDFKit

/// The W3C TAG's generic resources ontology.
///
/// Namespace `http://www.w3.org/2006/gen/ont#`. Only the terms the Solid vocabularies
/// name are declared here: `InformationResource`.
/// It is declared with the type RDFS entails from how the Solid vocabularies
/// use it: a superclass, domain or range is an `rdfs:Class`, and a
/// superproperty is an `rdf:Property`. The rest of the vocabulary is not
/// declared.
@Ontology
public struct Gen: Ontology {
    public init() {}

    public func content() -> Content {
        Namespace("http://www.w3.org/2006/gen/ont#")

        Class("InformationResource") {
            Type(RDFS.Class)
        }
    }
}
