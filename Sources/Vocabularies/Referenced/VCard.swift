import RDFCore
import RDFKit

/// The W3C vCard ontology.
///
/// Namespace `http://www.w3.org/2006/vcard/ns#`. Only the terms the Solid vocabularies
/// name are declared here: `Group`.
/// It is declared with its published type, label and comment; its other
/// statements, and the rest of the vocabulary, are not.
@Ontology
public struct VCard: Ontology {
    public init() {}

    public func content() -> Content {
        Namespace("http://www.w3.org/2006/vcard/ns#")

        Class("Group") {
            Type(OWL.Class)
            Label("Group")
            Comment("Object representing a group of persons or entities. A group object will usually contain hasMember properties to specify the members of the group.")
        }
    }
}
