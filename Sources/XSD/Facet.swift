import RDFCore

/// A constraining facet of a datatype definition (XML Schema 1.1 Part 2
/// §4.3), as a schema document gives it: `<xs:minInclusive value="0"/>` in
/// the definition of `xsd:nonNegativeInteger` is `.minInclusive("0")`.
///
/// The translated definitions list the facets of each datatype and of the
/// datatypes it is derived from, and ``SimpleType`` applies them all: a
/// literal is in the lexical space of `xsd:byte` when it is in that of
/// `xsd:decimal` and satisfies the facets `xsd:integer`, `xsd:long`,
/// `xsd:int`, `xsd:short` and `xsd:byte` add.
public enum Facet: Sendable, Hashable {
    /// §4.3.6: the literal is in the lexical space only when the
    /// normalization changes nothing.
    case whiteSpace(WhiteSpace)
    /// §4.3.4: the patterns of one derivation step, of which the literal
    /// matches one. The patterns of different steps all apply.
    case pattern([Pattern])
    /// §4.3.5: the value is one of these, given as lexical representations.
    case enumeration([String])
    /// §4.3.1 to §4.3.3: the length of the value, in characters or octets.
    case length(Int)
    case minLength(Int)
    case maxLength(Int)
    /// §4.3.7 to §4.3.10: bounds, given as lexical representations.
    case maxInclusive(String)
    case maxExclusive(String)
    case minInclusive(String)
    case minExclusive(String)
    /// §4.3.11 and §4.3.12: digits of a decimal number.
    case totalDigits(Int)
    case fractionDigits(Int)
    /// §4.3.14: whether a date/time value has a timezone offset.
    case explicitTimezone(ExplicitTimezone)
}

/// The values of the `whiteSpace` facet (§4.3.6).
public enum WhiteSpace: Sendable, Hashable {
    /// No normalization.
    case preserve
    /// Each tab, line feed and carriage return becomes a space.
    case replace
    /// After `replace`, runs of spaces become one and leading and trailing
    /// spaces are removed.
    case collapse

    /// The literal normalized.
    func normalize(_ text: String) -> String {
        guard self != .preserve else { return text }
        var scalars = String.UnicodeScalarView()
        for scalar in text.unicodeScalars {
            scalars.append(scalar == "\t" || scalar == "\n" || scalar == "\r" ? " " : scalar)
        }
        guard self == .collapse else { return String(scalars) }
        return String(scalars).split(separator: " ", omittingEmptySubsequences: true).joined(separator: " ")
    }
}

/// The values of the `explicitTimezone` facet (§4.3.14).
public enum ExplicitTimezone: Sendable, Hashable {
    case required
    case prohibited
    case optional
}
