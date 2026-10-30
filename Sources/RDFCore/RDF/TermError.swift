/// A value that RDF 1.2 Concepts does not allow as an RDF term.
public enum TermError: Error, Hashable, Sendable {
    /// A blank node identifier is empty.
    case emptyBlankNodeIdentifier

    /// A language tag is empty.
    ///
    /// RDF 1.2 Concepts §3.4 Literals: "a non-empty language tag".
    case emptyLanguageTag

    /// A language tag is not well-formed BCP 47.
    ///
    /// RDF 1.2 Concepts §3.4 Literals: "Lexical representations of language
    /// tags MUST be well-formed according to section 2.2.9 of [BCP47]".
    case malformedLanguageTag

    /// A typed literal names `rdf:langString` or `rdf:dirLangString`, whose
    /// literals carry their datatype through a language tag.
    ///
    /// RDF 1.2 Concepts §3.4 Literals: "if and only if the datatype IRI is
    /// `rdf:langString` or `rdf:dirLangString`, a non-empty language tag".
    case datatypeRequiresLanguageTag
}
