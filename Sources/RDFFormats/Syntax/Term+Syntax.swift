import IRIKit
import RDFCore

extension IRI {
    /// The IRI as an `IRIREF` (RDF 1.2 N-Triples §5.3, Turtle §6.5):
    /// between angle brackets, with each scalar the production does not
    /// allow written as a `UCHAR`.
    var iriReference: String {
        let written = "<" + rawValue + ">"
        if NTriplesGrammar.IRIREF.matches(written) { return written }
        var text = "<"
        for scalar in rawValue.unicodeScalars {
            if NTriplesGrammar.IRIREF.matches("<" + String(scalar) + ">") {
                text.unicodeScalars.append(scalar)
            } else {
                text += scalar.uchar
            }
        }
        return text + ">"
    }

    /// The namespace and local name of the IRI, split after its last `#`
    /// or `/`, when the local name can be written as a Turtle `PN_LOCAL`
    /// as it is, or is empty, and the namespace is an IRI.
    var prefixableParts: (namespace: IRI, local: String)? {
        let scalars = Array(rawValue.unicodeScalars)
        guard let split = scalars.lastIndex(where: { $0 == "#" || $0 == "/" }) else { return nil }
        let local = String(String.UnicodeScalarView(scalars[(split + 1)...]))
        guard local.isEmpty || TurtleGrammar.PN_LOCAL.matches(local),
              let namespace = try? IRI(validating: String(String.UnicodeScalarView(scalars[...split]))) else { return nil }
        return (namespace, local)
    }
}

extension Unicode.Scalar {
    /// The scalar as a `UCHAR`: `\uXXXX`, or `\UXXXXXXXX` beyond the Basic
    /// Multilingual Plane.
    var uchar: String {
        let hex = String(value, radix: 16, uppercase: true)
        return value > 0xFFFF
            ? "\\U" + String(repeating: "0", count: 8 - hex.count) + hex
            : "\\u" + String(repeating: "0", count: 4 - hex.count) + hex
    }
}

extension Literal {
    /// The lexical form as a `STRING_LITERAL_QUOTE`, escaped as canonical
    /// N-Triples escapes it (RDF 1.2 N-Triples §4): `ECHAR` for `"`, `\`,
    /// and the line feed, carriage return, tab, backspace and form feed;
    /// `UCHAR` for the other control characters and U+FFFE and U+FFFF.
    var quotedLexicalForm: String {
        var text = String.UnicodeScalarView()
        text.append("\"")
        for scalar in lexicalForm.unicodeScalars {
            switch scalar {
            case "\"": text.append(contentsOf: #"\""#.unicodeScalars)
            case "\\": text.append(contentsOf: #"\\"#.unicodeScalars)
            case "\n": text.append(contentsOf: #"\n"#.unicodeScalars)
            case "\r": text.append(contentsOf: #"\r"#.unicodeScalars)
            case "\t": text.append(contentsOf: #"\t"#.unicodeScalars)
            case "\u{08}": text.append(contentsOf: #"\b"#.unicodeScalars)
            case "\u{0C}": text.append(contentsOf: #"\f"#.unicodeScalars)
            case "\u{00}"..."\u{1F}", "\u{7F}", "\u{FFFE}", "\u{FFFF}": text.append(contentsOf: scalar.uchar.unicodeScalars)
            default: text.append(scalar)
            }
        }
        text.append("\"")
        return String(text)
    }

    /// The `LANG_DIR` of a language-tagged string, after the `@`.
    var languageDirection: String? {
        guard let languageTag else { return nil }
        return baseDirection.map { "\(languageTag)--\($0.rawValue)" } ?? languageTag
    }

    /// The literal as an N-Triples `literal` writes it (RDF 1.2 N-Triples
    /// §4): `xsd:string` is never written.
    var nTriples: String {
        if let languageDirection { return quotedLexicalForm + "@" + languageDirection }
        if let datatype { return quotedLexicalForm + "^^" + datatype.iriReference }
        return quotedLexicalForm
    }

    /// The literal a document writes as `"lexicalForm"^^<datatype>`.
    ///
    /// RDF 1.2 Concepts §3.4 Literals: "Simple literals are syntactic sugar
    /// for abstract syntax literals with the datatype IRI
    /// http://www.w3.org/2001/XMLSchema#string", so `^^xsd:string` gives the
    /// simple literal; and a language tag is present "if and only if the
    /// datatype IRI is `rdf:langString` or `rdf:dirLangString`".
    ///
    /// - Throws: ``TermError/datatypeRequiresLanguageTag`` for
    ///   `rdf:langString` and `rdf:dirLangString`.
    init(_ lexicalForm: String, datatypeIRI datatype: IRI) throws(TermError) {
        switch datatype {
        case .xsdString: self.init(lexicalForm)
        case .rdfLangString, .rdfDirLangString: throw .datatypeRequiresLanguageTag
        default: self.init(lexicalForm, datatype: datatype)
        }
    }

    /// A language-tagged string from a `LANG_DIR`: `word` is the text after
    /// `@`, a language tag and an optional `--` base direction.
    ///
    /// - Throws: ``TermError/malformedBaseDirection`` when the direction is
    ///   neither `ltr` nor `rtl`, and the errors of
    ///   ``RDFCore/Literal/init(_:languageTag:baseDirection:)``.
    init(_ lexicalForm: String, languageDirection word: String) throws(TermError) {
        let parts = word.components(separatedBy: "--")
        var direction: BaseDirection?
        if parts.count == 2 {
            guard let value = BaseDirection(rawValue: parts[1]) else { throw .malformedBaseDirection }
            direction = value
        }
        try self.init(lexicalForm, languageTag: parts[0], baseDirection: direction)
    }

    /// A language-tagged string read from a document: `word` is the
    /// `LANG_DIR` after `@`, and a tag that is not well-formed BCP 47, or a
    /// direction that is not `ltr` or `rtl`, is reported at `line` and
    /// `column`, where the `LANG_DIR` starts.
    init(_ lexicalForm: String, languageDirection word: String, line: Int, column: Int) throws(SyntaxError) {
        do {
            try self.init(lexicalForm, languageDirection: word)
        } catch .malformedBaseDirection {
            throw SyntaxError(line: line, column: column, message: "base direction must be 'ltr' or 'rtl'")
        } catch {
            throw SyntaxError(line: line, column: column, message: "'\(word.components(separatedBy: "--")[0])' is not a well-formed BCP 47 language tag")
        }
    }
}
