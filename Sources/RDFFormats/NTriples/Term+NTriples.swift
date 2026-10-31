import IRIKit
import RDFCore

// The terms of RDF 1.2 N-Triples, each made by an initializer on its own
// type from the production that writes it. The productions come from the
// grammar as published, translated into ``NTriplesGrammar``;
// ``NTriplesDecoder`` reads the statements and the lines, and the terms read
// themselves.

extension IRI {
    /// An `IRIREF`, the characters between `<` and `>` with their numeric
    /// escapes replaced, which N-Triples requires to be an absolute IRI.
    init(_ syntax: NTriplesGrammar.IRIREF) throws {
        let text = Escape.unescaped(syntax.text, delimiter: 1, try syntax.uchars.map { try Escape($0, from: syntax.location) })
        do {
            try self.init(validating: text)
        } catch {
            throw SyntaxError("<\(text)> is not an absolute IRI", at: syntax.location)
        }
    }
}

extension Escape {
    /// A numeric escape, `UCHAR`, in a terminal that starts at `start`.
    init(_ uchar: NTriplesGrammar.UCHAR, from start: NTriplesGrammar.Location) throws {
        guard let scalar = Unicode.Scalar(hexadecimal: uchar.hexes.map(\.text)) else {
            throw SyntaxError("escape \(uchar.text) names no Unicode scalar value", at: uchar.location)
        }
        let offset = uchar.location.offset - start.offset
        self.init(range: offset..<(offset + uchar.text.unicodeScalars.count), scalar: scalar)
    }

    /// A string escape, `ECHAR`, in a terminal that starts at `start`.
    init(_ echar: NTriplesGrammar.ECHAR, from start: NTriplesGrammar.Location) {
        let offset = echar.location.offset - start.offset
        self.init(range: offset..<(offset + 2), scalar: Unicode.Scalar(stringEscape: echar.text))
    }
}

extension BlankNode {
    /// A `BLANK_NODE_LABEL`: the node the label after `_:` names.
    init(_ syntax: NTriplesGrammar.BLANK_NODE_LABEL) throws {
        try self.init(String(String.UnicodeScalarView(syntax.text.unicodeScalars.dropFirst(2))))
    }
}

extension SubjectTerm {
    /// `subject ::= IRIREF | BLANK_NODE_LABEL`
    init(_ syntax: NTriplesGrammar.Subject) throws {
        switch syntax {
        case .iriref(let iri): self = .iri(try IRI(iri))
        case .blankNodeLabel(let label): self = .blankNode(try BlankNode(label))
        }
    }
}

extension ObjectTerm {
    /// `object ::= IRIREF | BLANK_NODE_LABEL | literal | tripleTerm`
    init(_ syntax: NTriplesGrammar.Object) throws {
        switch syntax {
        case .iriref(let iri): self = .iri(try IRI(iri))
        case .blankNodeLabel(let label): self = .blankNode(try BlankNode(label))
        case .literal(let literal): self = .literal(try Literal(literal))
        case .tripleTerm(let triple): self = .tripleTerm(try Graph.Element(triple))
        }
    }
}

extension Triple where SubjectValue == SubjectTerm, ObjectValue == ObjectTerm {
    /// `triple ::= subject predicate object '.'`
    init(_ syntax: NTriplesGrammar.Triple) throws {
        try self.init(subject: SubjectTerm(syntax.subject), predicate: IRI(syntax.predicate.iriref), object: ObjectTerm(syntax.object))
    }

    /// `tripleTerm ::= '<<(' subject predicate object ')>>'`
    init(_ syntax: NTriplesGrammar.TripleTerm) throws {
        try self.init(subject: SubjectTerm(syntax.subject), predicate: IRI(syntax.predicate.iriref), object: ObjectTerm(syntax.object))
    }
}

extension Literal {
    /// `literal ::= STRING_LITERAL_QUOTE ('^^' IRIREF | LANG_DIR)?`
    init(_ syntax: NTriplesGrammar.Literal) throws {
        let string = syntax.stringLiteralQuote
        let lexicalForm = Escape.unescaped(
            string.text, delimiter: 1,
            try string.uchars.map { try Escape($0, from: string.location) } + string.echars.map { Escape($0, from: string.location) }
        )
        switch syntax.irirefOrLangDir {
        case .iriref(let datatype)?:
            let iri = try IRI(datatype)
            do {
                try self.init(lexicalForm, datatypeIRI: iri)
            } catch {
                throw SyntaxError("a language-tagged string cannot be written with '^^'", at: string.location)
            }
        case .langDir(let tag)?:
            // LANG_DIR ::= '@' …: the tag and direction follow the `@`.
            let word = String(String.UnicodeScalarView(tag.text.unicodeScalars.dropFirst()))
            try self.init(lexicalForm, languageDirection: word, line: tag.location.line, column: tag.location.column)
        case nil:
            self.init(lexicalForm)
        }
    }
}
