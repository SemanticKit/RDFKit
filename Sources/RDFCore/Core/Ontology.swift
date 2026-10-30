import Foundation

public typealias AnyEntity = any Entity

public typealias Entities = [AnyEntity]

/// What an ontology's `body` returns: an ordered list of entities —
/// declarations (classes, properties, individuals, datatypes), their
/// annotations, prefixes and namespaces — that together define an
/// ontology's vocabulary.
///
/// An ontology's `body` is declared `some Content`, as a SwiftUI view's
/// `body` is `some View`. ``ContentBuilder`` builds it as ``Entities``, which
/// conforms.
public protocol Content {
    /// The entities of this content, in the order they were written.
    var entities: Entities { get }
}

/// A declaratively authored ontology.
///
/// Conform a type to ``Ontology`` to define an RDF vocabulary — a collection of
/// classes, properties, individuals, datatypes, prefixes, and annotations —
/// using the ``ContentBuilder`` result builder. The `@Ontology` macro reads the
/// content and generates one Swift type per declared term, nested inside the
/// conforming type.
///
/// Conformance requires a ``body`` property of some ``Content``, as a SwiftUI
/// view's `body` is `some View`. The default ``entities`` property provides
/// a stable, non-rebuilding view of the same declarations.
///
/// Annotations that relate a term to another term take the related type as
/// their argument, `Domain(People.Person)`:
///
/// ```swift
/// @Ontology
/// struct People: Ontology {
///     var body: some Content {
///         Namespace("https://people.example.org/ontology#")
///         Class("Person")
///         Property("fullName") {
///             Domain(People.Person)
///             Range(RDF.Literal)
///             Label("Full Name")
///         }
///     }
/// }
/// ```
///
/// - Note: ``Ontology`` conformance is `Sendable`; conforming types should
///   ensure all stored properties are also `Sendable`.
///
/// - SeeAlso: ``ContentBuilder``, ``Entity``, ``Declaration``
public protocol Ontology: Sendable {
    /// The type of the ontology's content, inferred from ``body``.
    associatedtype Body: Content

    /// The authored ontology content.
    ///
    /// Use the `@ContentBuilder` result builder to declaratively compose the
    /// ontology's declarations — classes, properties, individuals, datatypes,
    /// and annotations — in a flat, ordered list. A conforming `body` takes
    /// the result builder from this requirement, as a SwiftUI view's `body`
    /// takes `@ViewBuilder`.
    ///
    /// `@Ontology` owns the body of `body`: the authored statements are read
    /// as syntax, and the property returns the same declarations built from
    /// the generated types.
    ///
    /// ```swift
    /// @Ontology
    /// struct MyOntology: Ontology {
    ///     var body: some Content {
    ///         Namespace("https://example.org/ontology#")
    ///         Class("Animal")
    ///         Property("age")
    ///         Individual("tweety")
    ///     }
    /// }
    /// ```
    @ContentBuilder var body: Body { get }

    /// The flattened collection of all entities declared within this ontology.
    ///
    /// Unlike ``body``, which is evaluated by the `@ContentBuilder` result builder
    /// each time it is accessed, `entities` provides a plain array that conforming
    /// types may cache or store directly. Use `entities` when you need a stable,
    /// non-rebuilding view of the ontology's declarations.
    ///
    /// - Note: Conforming types may provide a stored property backing this requirement.
    ///   The default implementation in the extension returns the entities of ``body``.
    var entities: Entities { get }
}

extension Ontology {
    /// The flattened collection of all entities declared within this ontology.
    ///
    /// This property exposes the same values as ``body`` but as a stored array
    /// rather than a re-evaluated builder body. Use `entities` when you need
    /// to inspect, filter, or iterate over the ontology's declarations without
    /// triggering the `@ContentBuilder` each time.
    ///
    /// - Note: For ontologies whose content is derived from a builder body,
    ///   `entities` captures the result once at access time. Prefer `body`
    ///   for lazy or conditional composition patterns.
    public var entities: Entities {
        body.entities
    }
}

extension Array: Content where Element == any Entity {
    /// The array itself: ``ContentBuilder`` builds an ontology's `body` as
    /// ``Entities``.
    public var entities: Entities { self }
}
