import Foundation

/// A declaratively authored ontology.
@dynamicMemberLookup
public protocol Ontology: Content {
    associatedtype Body: Content

    /// The authored ontology content.
    @ContentBuilder var content: Body { get }
}

public extension Ontology {
    /// Resolves an authored term name in this ontology.
    static subscript(dynamicMember term: String) -> String {
        term
    }

    /// Resolves an authored term name that is not a Swift member identifier.
    static subscript(_ term: String) -> String {
        term
    }

    /// Resolves an authored term name in this ontology instance.
    subscript(dynamicMember term: String) -> String {
        term
    }

    /// Resolves an authored term name that is not a Swift member identifier.
    subscript(_ term: String) -> String {
        term
    }
}
