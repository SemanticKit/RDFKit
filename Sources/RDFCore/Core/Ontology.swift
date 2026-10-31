/// A declaration in an ontology's body: a class, a property or one of their
/// annotations.
///
/// Declarations carry no data at run time. The `@Ontology` macro reads them
/// from the body's syntax and generates the Swift types they declare.
public protocol Content {}

extension Array: Content where Element == any Content {}

/// A vocabulary declared in Swift.
///
/// Attach `@Ontology` to a conforming struct and declare the vocabulary's
/// terms in ``body``:
///
/// ```swift
/// @Ontology
/// public struct FOAF: Ontology {
///     public var body: some Content {
///         Namespace("http://xmlns.com/foaf/0.1/")
///         Class("Person") {
///             Type(RDFS.Class)
///             Label("Person")
///             Comment("A person.")
///         }
///     }
/// }
/// ```
public protocol Ontology: Sendable {
    /// The type of the vocabulary's declarations.
    associatedtype Body: Content

    /// The vocabulary's declarations.
    @ContentBuilder var body: Body { get }
}
