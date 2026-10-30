/// A terminal of the RDF 1.2 Turtle grammar (§7.3).
enum TurtleToken: Equatable {
    /// `IRIREF`, unescaped and not yet resolved.
    case iriReference(String)

    /// `PNAME_NS` (with an empty local name) or `PNAME_LN`, with `PLX`
    /// escapes in the local name removed.
    case prefixedName(prefix: String, local: String)

    /// `BLANK_NODE_LABEL`, without `_:`.
    case blankNodeLabel(String)

    /// A string, unescaped, and the form it was written in.
    case string(String, StringForm)

    /// `@` followed by a word: a `LANG_DIR` after a string, or one of the
    /// `@prefix`, `@base` and `@version` directive keywords.
    case atWord(String)

    /// `INTEGER`, `DECIMAL` or `DOUBLE`, with the lexical form as written.
    case integer(String)
    case decimal(String)
    case double(String)

    /// A bare word: `a`, `true`, `false`, or a `PREFIX`, `BASE` or `VERSION`
    /// directive keyword in any case.
    case word(String)

    /// Punctuation: `.` `;` `,` `[` `]` `(` `)` `^^` `<<` `>>` `<<(` `)>>`
    /// `{|` `|}` `~`.
    case punctuation(String)

    /// The end of the document.
    case end
}
