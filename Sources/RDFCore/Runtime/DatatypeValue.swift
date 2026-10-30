/// A value of a datatype, as a Swift value: what a literal of the datatype
/// denotes inside the runtime.
///
/// RDF 1.2 Concepts §5: "A datatype consists of a lexical space, a value
/// space and a lexical-to-value mapping", and the literal value of a
/// literal is the lexical-to-value mapping of its lexical form. The Swift
/// type of a datatype is built from a lexical form, and writes the
/// canonical lexical form of its value, so the ``Literal`` with its
/// datatype IRI exists only at the boundary: a format's encoder writes the
/// value as a literal whose datatype IRI it derives from ``datatype``, the
/// datatype's declared key, as it derives every IRI.
///
/// The XML Schema datatypes RDF uses (RDF 1.2 Concepts §5.1) are the Swift
/// types of the `XSD` module: a property whose range is `xsd:integer`
/// holds `[XSD.integer]`. A literal whose datatype has no Swift type, or
/// whose lexical form is not in its datatype's lexical space (an ill-typed
/// literal), stays a ``Literal``.
public protocol DatatypeValue: Sendable, Hashable, Encodable {
    /// The declared key of the datatype, from which an encoder derives the
    /// datatype IRI.
    static var datatype: TermKey { get }

    /// The value from a lexical form in the datatype's lexical space.
    ///
    /// - Throws: ``DatatypeError/illTyped`` for any other lexical form.
    init(lexicalForm: String) throws

    /// The canonical lexical form of the value.
    var lexicalForm: String { get }

    /// The value a literal denotes, when the value writes back as that
    /// literal: its datatype IRI is the datatype's, its lexical form is in
    /// the lexical space, and it is the canonical form. Any other literal is
    /// kept as it is (``PropertyLiterals``).
    init?(holding literal: Literal)
}

extension DatatypeValue {
    /// The value a literal of the datatype denotes, as a decoder reads it
    /// at the boundary.
    ///
    /// - Throws: ``DatatypeError/otherDatatype`` when the literal's datatype
    ///   IRI is not the one ``datatype`` gives, and
    ///   ``DatatypeError/illTyped`` when the literal is ill-typed.
    public init(_ literal: Literal) throws {
        guard literal.datatypeIRI.rawValue.unicodeScalars.elementsEqual(Self.datatype.stringValue.unicodeScalars) else {
            throw DatatypeError.otherDatatype
        }
        try self.init(lexicalForm: literal.lexicalForm)
    }

    public init?(holding literal: Literal) {
        guard let value = try? Self(literal),
              value.lexicalForm.unicodeScalars.elementsEqual(literal.lexicalForm.unicodeScalars) else { return nil }
        self = value
    }

    /// Writes the canonical lexical form. An encoder that writes RDF writes
    /// the literal itself, with the datatype IRI.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(lexicalForm)
    }
}
