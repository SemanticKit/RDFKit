/// What an ontology's `body` returns: an ordered list of entities —
/// declarations (classes, properties, datatypes), their
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

extension Array: Content where Element == any Entity {
    /// The array itself: ``ContentBuilder`` builds an ontology's `body` as
    /// ``Entities``.
    public var entities: Entities { self }
}
