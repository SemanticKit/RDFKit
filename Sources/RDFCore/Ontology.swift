import Foundation

/// A declaratively authored ontology.
public protocol Ontology: Sendable {
    /// The authored ontology content type.
    associatedtype Content: Sendable

    /// The authored ontology content.
    @ContentBuilder var content: Content { get }
}
