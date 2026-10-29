import RDFCore
import RDFKit

/// OpenID Connect terms.
///
/// Namespace `http://openid.net/specs/connect/1.0/`. Only the terms the Solid vocabularies
/// name are declared here: `issuer`.
/// It is declared with the type RDFS entails from how the Solid vocabularies
/// use it: a superclass, domain or range is an `rdfs:Class`, and a
/// superproperty is an `rdf:Property`. The rest of the vocabulary is not
/// declared.
@Ontology
public struct OpenIDConnect: Ontology {
    public init() {}

    public func content() -> Content {
        Namespace("http://openid.net/specs/connect/1.0/")

        Property("issuer") {
            Type(RDF.Property)
        }
    }
}
