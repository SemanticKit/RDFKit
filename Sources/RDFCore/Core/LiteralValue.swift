/// A literal of a datatype: a value, with no identity of its own.
///
/// The `@Ontology` macro generates a struct conforming to `LiteralValue` for
/// every `Datatype(...)`, for `rdfs:Literal` and for its subclasses. The
/// struct is the datatype: `XSD.nonNegativeInteger("14")` is a literal whose
/// datatype is `xsd:nonNegativeInteger`, and a property with that range
/// stores it. The value is the literal's lexical form, with the language tag
/// and base direction RDF allows on strings.
///
/// Two literals are equal when their lexical forms, language tags and
/// directions are equal.
public protocol LiteralValue: Entity, Hashable, ExpressibleByStringLiteral {
    /// The lexical form, such as `14` or `Panthera leo`.
    var lexicalForm: String { get }

    /// The language tag of a language-tagged string, such as `de`.
    var languageTag: String? { get }

    /// The base direction of a directional language-tagged string.
    var direction: TextDirection? { get }
}

extension LiteralValue {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.lexicalForm == rhs.lexicalForm
            && lhs.languageTag == rhs.languageTag
            && lhs.direction == rhs.direction
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(lexicalForm)
        hasher.combine(languageTag)
        hasher.combine(direction)
    }
}
