import Foundation

/// The type returned by an ontology's `content` property.
///
/// Content is an ordered list of RDF nodes — declarations (classes, properties,
/// individuals, datatypes), prefixes, and namespaces — that together define an
/// ontology's vocabulary.
public typealias Content = [any Entity]

public typealias AnyEntity = any Entity

public typealias Entities = [AnyEntity]

/// A declaratively authored ontology.
///
/// Conform a type to ``Ontology`` to define an RDF vocabulary — a collection of
/// classes, properties, individuals, datatypes, prefixes, and annotations —
/// using the ``@OntologyBuilder`` result builder. The ``@Ontology`` macro can
/// then generate concrete declaration types (``Class``, ``Property``, etc.)
/// nested inside the conforming type, shadowing the default DSL closures.
///
/// Conformance requires a ``content`` property that returns ``Content`` — an
/// ordered list of ``Entity`` values. The default ``entities`` property
/// provides a stable, non-rebuilding view of the same declarations.
///
/// ```swift
/// struct MyVocabulary: Ontology {
///     var content: Content {
///         Class("Person")
///         Property("fullName") { Label("Full Name") }
///         Individual("alice")
///     }
/// }
/// ```
///
/// - Note: ``Ontology`` conformance is `Sendable`; conforming types should
///   ensure all stored properties are also `Sendable`.
///
/// - SeeAlso: ``OntologyBuilder``, ``@Ontology``, ``Entity``
public protocol Ontology: Sendable {
    /// The authored ontology content.
    ///
    /// Use the `@ContentBuilder` result builder to declaratively compose the
    /// ontology's declarations — classes, properties, individuals, datatypes,
    /// and annotations — in a flat, ordered list.
    ///
    /// ```swift
    /// struct MyOntology: Ontology {
    ///     var content: Content {
    ///         Class("Animal")
    ///         Property("age")
    ///         Individual("tweety")
    ///     }
    /// }
    /// ```
    @OntologyBuilder var content: Content { get }

    /// The flattened collection of all entities declared within this ontology.
    ///
    /// Unlike ``content``, which is evaluated by the `@ContentBuilder` result builder
    /// each time it is accessed, `entities` provides a plain array that conforming
    /// types may cache or store directly. Use `entities` when you need a stable,
    /// non-rebuilding view of the ontology's declarations.
    ///
    /// - Note: Conforming types may provide a stored property backing this requirement.
    ///   The default implementation in the extension simply returns the value of ``content``.
    var entities: Entities { get }
}

extension Ontology {
    /// The flattened collection of all entities declared within this ontology.
    ///
    /// This property exposes the same values as ``content`` but as a stored array
    /// rather than a re-evaluated builder closure. Use `entities` when you need
    /// to inspect, filter, or iterate over the ontology's declarations without
    /// triggering the `@ContentBuilder` each time.
    ///
    /// - Note: For ontologies whose `content` is derived from a builder body,
    ///   `entities` captures the result once at access time. Prefer `content`
    ///   for lazy or conditional composition patterns.
    public var entities: Entities {
        return content
    }
}

extension Ontology {
//    public var namespace: Namespace? {
//        entities.lazy
//            .compactMap { $0 as? Namespace }
//            .first
//    }
}
