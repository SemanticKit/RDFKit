import RDFCore
import RDFKit

/// The Simple Knowledge Organization System (SKOS) vocabulary.
///
/// Namespace `http://www.w3.org/2004/02/skos/core#`. Only the terms the Solid vocabularies
/// name are declared here: `Concept`.
/// It is declared with its published type, label and comment; its other
/// statements, and the rest of the vocabulary, are not.
@Ontology
public struct SKOS: Ontology {
    public init() {}

    public func content() -> Content {
        Namespace("http://www.w3.org/2004/02/skos/core#")

        Class("Concept") {
            Type(OWL.Class)
            Label("Concept")
        }
    }
}
