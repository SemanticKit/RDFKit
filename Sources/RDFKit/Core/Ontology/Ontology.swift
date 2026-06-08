import Foundation

/// An authored ontology definition.
public protocol Ontology: Content {
    associatedtype Body: Content

    /// The ontology content.
    @ContentBuilder var content: Body { get }
}
