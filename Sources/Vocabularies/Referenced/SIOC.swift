import RDFCore
import RDFKit

/// The SIOC core ontology.
///
/// Namespace `http://rdfs.org/sioc/ns#`. Only the terms the Solid vocabularies
/// name are declared here: `Post`.
/// It is declared with its published type, label and comment; its other
/// statements, and the rest of the vocabulary, are not.
@Ontology
public struct SIOC: Ontology {
    public init() {}

    public func content() -> Content {
        Namespace("http://rdfs.org/sioc/ns#")

        Class("Post") {
            Type(OWL.Class)
            Label("Post")
            Comment("An article or message that can be posted to a Forum.")
        }
    }
}
