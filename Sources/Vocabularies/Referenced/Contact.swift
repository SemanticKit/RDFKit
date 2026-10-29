import RDFCore
import RDFKit

/// The SWAP personal information (contact) vocabulary.
///
/// Namespace `http://www.w3.org/2000/10/swap/pim/contact#`. Only the terms the Solid vocabularies
/// name are declared here: `Person`.
/// It is declared with the type RDFS entails from how the Solid vocabularies
/// use it: a superclass, domain or range is an `rdfs:Class`, and a
/// superproperty is an `rdf:Property`. The rest of the vocabulary is not
/// declared.
@Ontology
public struct Contact: Ontology {
    public init() {}

    public func content() -> Content {
        Namespace("http://www.w3.org/2000/10/swap/pim/contact#")

        Class("Person") {
            Type(RDFS.Class)
        }
    }
}
