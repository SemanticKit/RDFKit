import Foundation

/// The type returned by an ontology's `content()` function.
///
/// Content is an ordered list of content elements — declarations (classes, properties,
/// individuals, datatypes), their annotations, prefixes, and namespaces — that
/// together define an ontology's vocabulary.
public typealias Content = [any ContentElement]

public typealias AnyEntity = any Entity

public typealias Entities = Content

/// A declaratively authored ontology.
///
/// Conform a type to ``Ontology`` to define an RDF vocabulary — a collection of
/// classes, properties, individuals, datatypes, prefixes, and annotations —
/// using the ``ContentBuilder`` result builder. The `@Ontology` macro reads the
/// content and generates one Swift type per declared term, nested inside the
/// conforming type.
///
/// Conformance requires a ``content()`` function that returns ``Content`` — an
/// ordered list of ``ContentElement`` values. The default ``entities`` property
/// provides a stable, non-rebuilding view of the same declarations.
///
/// Annotations that relate a term to another term take the related type as
/// their argument, `Domain(People.Person)`:
///
/// ```swift
/// @Ontology
/// struct People: Ontology {
///     func content() -> Content {
///         Namespace("https://people.example.org/ontology#")
///         Class("Person")
///         Property("fullName") {
///             Domain(People.Person)
///             Range(RDFS.Literal)
///             Label("Full Name")
///         }
///     }
/// }
/// ```
///
/// - Note: ``Ontology`` conformance is `Sendable`; conforming types should
///   ensure all stored properties are also `Sendable`.
///
/// - SeeAlso: ``ContentBuilder``, ``ContentElement``, ``Declaration``
public protocol Ontology: Sendable {
    /// The authored ontology content.
    ///
    /// Use the `@ContentBuilder` result builder to declaratively compose the
    /// ontology's declarations — classes, properties, individuals, datatypes,
    /// and annotations — in a flat, ordered list.
    ///
    /// Content is a function so that `@Ontology` can own its body: the
    /// authored statements are read as syntax, and the function returns the
    /// same declarations built from the generated types.
    ///
    /// ```swift
    /// @Ontology
    /// struct MyOntology: Ontology {
    ///     func content() -> Content {
    ///         Namespace("https://example.org/ontology#")
    ///         Class("Animal")
    ///         Property("age")
    ///         Individual("tweety")
    ///     }
    /// }
    /// ```
    @ContentBuilder func content() -> Content

    /// The flattened collection of all entities declared within this ontology.
    ///
    /// Unlike ``content()``, which is evaluated by the `@ContentBuilder` result builder
    /// each time it is accessed, `entities` provides a plain array that conforming
    /// types may cache or store directly. Use `entities` when you need a stable,
    /// non-rebuilding view of the ontology's declarations.
    ///
    /// - Note: Conforming types may provide a stored property backing this requirement.
    ///   The default implementation in the extension simply returns the value of ``content()``.
    var entities: Entities { get }
}

extension Ontology {
    /// The flattened collection of all entities declared within this ontology.
    ///
    /// This property exposes the same values as ``content()`` but as a stored array
    /// rather than a re-evaluated builder closure. Use `entities` when you need
    /// to inspect, filter, or iterate over the ontology's declarations without
    /// triggering the `@ContentBuilder` each time.
    ///
    /// - Note: For ontologies whose `content` is derived from a builder body,
    ///   `entities` captures the result once at access time. Prefer `content()`
    ///   for lazy or conditional composition patterns.
    public var entities: Entities {
        return content()
    }
}

