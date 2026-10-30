/// The declared key of a term: the name it was declared with and the
/// vocabulary that declares it.
///
/// An IRI is to a SemanticKit type what a `CodingKey` is to a `Codable`
/// property: present when encoding and decoding, and invisible to code that
/// uses the value. Each generated class, property and named individual
/// carries its key as type-level coding information; an encoder derives the
/// IRI from it when the term leaves the runtime (``PropertyKey``, and the
/// format encoders in RDFFormats). The key holds no IRI.
public struct TermKey: Sendable {
    /// The name the term was declared with.
    public let name: String

    /// The vocabulary that declares the term.
    public let vocabulary: any Vocabulary.Type

    /// The key of the term declared as `name` in `vocabulary`.
    public init(_ name: String, in vocabulary: any Vocabulary.Type) {
        self.name = name
        self.vocabulary = vocabulary
    }

    /// The text of the IRI that denotes the term, which a coder asks for at
    /// the boundary: the vocabulary's namespace followed by the declared name.
    public var stringValue: String {
        vocabulary.namespace + name
    }
}

extension TermKey: Equatable {
    /// Two keys are equal when they name the same declaration.
    public static func == (lhs: TermKey, rhs: TermKey) -> Bool {
        lhs.name == rhs.name && ObjectIdentifier(lhs.vocabulary) == ObjectIdentifier(rhs.vocabulary)
    }
}
