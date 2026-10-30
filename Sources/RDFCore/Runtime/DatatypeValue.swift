/// A value of a datatype, as a Swift value: what a literal of the datatype
/// denotes inside the runtime.
///
/// RDF 1.2 Concepts §5: "A datatype consists of a lexical space, a value
/// space and a lexical-to-value mapping", and the literal value of a
/// literal is the lexical-to-value mapping of its lexical form. The Swift
/// type of a datatype is built from a lexical form, or from a literal at the
/// boundary, so the ``Literal`` with its datatype IRI exists only there: a
/// format's encoder writes the value as a literal whose datatype IRI it
/// derives from the declared key of ``literalForm``, as it derives every IRI.
///
/// The XML Schema datatypes RDF uses (RDF 1.2 Concepts §5.1) are the Swift
/// types of the `XSD` module: a property whose range is `xsd:integer`
/// holds `[XSD.integer]`. A literal that denotes no value of the range, an
/// ill-typed literal (§3.4), one whose datatype has no Swift type, or one
/// whose value is outside the range's value space, stays a ``Literal``
/// (``PropertyLiterals``).
public protocol DatatypeValue: Sendable, Hashable, Encodable {
    /// The declared key of the datatype, from which an encoder derives the
    /// datatype IRI.
    static var datatype: TermKey { get }

    /// The value from a lexical form in the datatype's lexical space.
    ///
    /// - Throws: ``DatatypeError/illTyped`` for any other lexical form.
    init(lexicalForm: String) throws

    /// The value a literal denotes, when it is a value of this datatype,
    /// which keeps the literal's lexical form and datatype as its
    /// ``literalForm``. `nil` for a literal that denotes no value of the
    /// datatype, which stays a literal.
    init?(_ literal: Literal)

    /// The canonical lexical form of the value.
    var lexicalForm: String { get }

    /// The lexical form and datatype an encoder writes the value with: those
    /// of the literal it was decoded from, else its canonical form and its
    /// own datatype. Equality ignores it, as it ignores how a value was
    /// written.
    var literalForm: LiteralForm { get }
}

extension DatatypeValue {
    /// Writes the canonical lexical form. An encoder that writes RDF writes
    /// the literal itself, from ``literalForm``.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(lexicalForm)
    }
}
