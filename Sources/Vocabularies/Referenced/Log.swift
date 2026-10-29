import RDFCore
import RDFKit

/// The SWAP log (N3 logic) vocabulary.
///
/// Namespace `http://www.w3.org/2000/10/swap/log#`. Only the terms the Solid vocabularies
/// name are declared here: `Formula`.
/// It is declared with its published type, label and comment; its other
/// statements, and the rest of the vocabulary, are not.
@Ontology
public struct Log: Ontology {
    public init() {}

    public func content() -> Content {
        Namespace("http://www.w3.org/2000/10/swap/log#")

        Class("Formula") {
            Type(RDFS.Class)
        }
    }
}
