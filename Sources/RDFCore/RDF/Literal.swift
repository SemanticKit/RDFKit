import Foundation
import IRIKit

/// An RDF literal.
///
/// RDF 1.2 Concepts §3.4 Literals: "A literal in an RDF graph consists of
/// two, three, or four elements: a lexical form, … a datatype IRI, … if and
/// only if the datatype IRI is `rdf:langString` or `rdf:dirLangString`, a
/// non-empty language tag, … if and only if the datatype IRI is
/// `rdf:dirLangString`, a base direction."
///
/// The datatype IRI of a simple literal (`xsd:string`) and of a
/// language-tagged string (`rdf:langString`, `rdf:dirLangString`) follows
/// from its form, so ``datatype`` holds only the datatype IRI of any other
/// typed literal. A typed literal is made with RDFKit's
/// `Literal(_:datatype:)`, which knows those vocabularies: `xsd:string` gives
/// the same literal as ``init(_:)``, so equal literals are equal values.
///
/// Two literals are the same term when their lexical forms, datatype IRIs,
/// language tags (compared case-insensitively) and base directions are
/// equal. The language tag is stored in lower case, so `Equatable` gives
/// that comparison.
public struct Literal: Object, Hashable, Sendable, Comparable, CustomStringConvertible {
    /// The lexical form, a Unicode string.
    public let lexicalForm: String

    /// The language tag of a language-tagged string, in lower case.
    public let languageTag: String?

    /// The base direction of a directional language-tagged string.
    public let baseDirection: BaseDirection?

    /// The datatype IRI of a typed literal whose datatype is not
    /// `xsd:string`; `nil` for simple literals and language-tagged strings.
    public let datatype: IRI?

    /// Creates a simple literal, whose datatype is `xsd:string`.
    public init(_ lexicalForm: String) {
        self.lexicalForm = lexicalForm
        self.languageTag = nil
        self.baseDirection = nil
        self.datatype = nil
    }

    /// Creates a language-tagged string, with a base direction when it is a
    /// directional language-tagged string.
    ///
    /// RDF 1.2 Concepts §3.4 Literals: "Lexical representations of
    /// language tags MUST be well-formed according to section 2.2.9 of
    /// [BCP47]", which is a tag matching the `Language-Tag` ABNF of BCP 47
    /// §2.1.
    ///
    /// - Throws: ``TermError/emptyLanguageTag`` when the tag is empty, and
    ///   ``TermError/malformedLanguageTag`` when it is not a well-formed
    ///   BCP 47 tag.
    public init(_ lexicalForm: String, languageTag: String, baseDirection: BaseDirection? = nil) throws(TermError) {
        guard !languageTag.isEmpty else { throw .emptyLanguageTag }
        guard Self.isWellFormed(languageTag: languageTag) else { throw .malformedLanguageTag }
        self.lexicalForm = lexicalForm
        self.languageTag = languageTag.lowercased()
        self.baseDirection = baseDirection
        self.datatype = nil
    }

    /// Creates a typed literal from a datatype IRI that is not
    /// `xsd:string`, `rdf:langString` or `rdf:dirLangString`. RDFKit's
    /// `Literal(_:datatype:)` checks that before it calls this.
    package init(lexicalForm: String, datatype: IRI) {
        self.lexicalForm = lexicalForm
        self.languageTag = nil
        self.baseDirection = nil
        self.datatype = datatype
    }

    /// The literal as N-Triples writes it, without escaping.
    public var description: String {
        var value = "\"\(lexicalForm)\""
        if let languageTag {
            value += "@\(languageTag)"
            if let baseDirection {
                value += "--\(baseDirection)"
            }
        } else if let datatype {
            value += "^^<\(datatype)>"
        }
        return value
    }

    public static func < (lhs: Literal, rhs: Literal) -> Bool {
        (lhs.lexicalForm, lhs.languageTag ?? "", lhs.baseDirection?.rawValue ?? "", lhs.datatype?.rawValue ?? "")
            < (rhs.lexicalForm, rhs.languageTag ?? "", rhs.baseDirection?.rawValue ?? "", rhs.datatype?.rawValue ?? "")
    }
}

extension Literal {
    /// Whether `tag` matches BCP 47 §2.1 `Language-Tag`:
    ///
    /// ```
    /// Language-Tag  = langtag / privateuse / grandfathered
    /// langtag       = language ["-" script] ["-" region] *("-" variant)
    ///                 *("-" extension) ["-" privateuse]
    /// language      = 2*3ALPHA ["-" extlang] / 4ALPHA / 5*8ALPHA
    /// extlang       = 3ALPHA *2("-" 3ALPHA)
    /// script        = 4ALPHA
    /// region        = 2ALPHA / 3DIGIT
    /// variant       = 5*8alphanum / (DIGIT 3alphanum)
    /// extension     = singleton 1*("-" (2*8alphanum))
    /// singleton     = DIGIT / %x41-57 / %x59-5A / %x61-77 / %x79-7A
    /// privateuse    = "x" 1*("-" (1*8alphanum))
    /// ```
    ///
    /// The ABNF is case-insensitive. `grandfathered` lists the irregular
    /// tags; the regular ones already match `langtag`.
    private static func isWellFormed(languageTag tag: String) -> Bool {
        let languageTag = #/(?i)(?:(?:[a-z]{2,3}(?:-[a-z]{3}){0,3}|[a-z]{4}|[a-z]{5,8})(?:-[a-z]{4})?(?:-(?:[a-z]{2}|[0-9]{3}))?(?:-(?:[a-z0-9]{5,8}|[0-9][a-z0-9]{3}))*(?:-[a-wyz0-9](?:-[a-z0-9]{2,8})+)*(?:-x(?:-[a-z0-9]{1,8})+)?|x(?:-[a-z0-9]{1,8})+|en-gb-oed|i-ami|i-bnn|i-default|i-enochian|i-hak|i-klingon|i-lux|i-mingo|i-navajo|i-pwn|i-tao|i-tay|i-tsu|sgn-be-fr|sgn-be-nl|sgn-ch-de)/#
        return tag.unicodeScalars.allSatisfy(\.isASCII) && tag.wholeMatch(of: languageTag) != nil
    }
}
