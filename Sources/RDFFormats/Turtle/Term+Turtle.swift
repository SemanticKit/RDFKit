import IRIKit
import RDFCore

// The terms of RDF 1.2 Turtle (§7.3), each read by an initializer on its own
// type at the parser's current token. ``TurtleParser`` reads the statements,
// directives, collections, blank node property lists and annotations; the
// terms read themselves. An initializer that returns `nil` leaves the parser
// where it was, for a token that does not start its term.

extension IRI {
    /// `iri ::= IRIREF | PrefixedName`: an `IRIREF` resolved against the
    /// parser's base, or a prefixed name expanded with its declared
    /// namespace. `nil` for any other token.
    init?(turtle parser: inout TurtleParser) throws {
        switch parser.current.token {
        case .iriReference(let reference):
            try self.init(turtleReference: reference, in: parser)
        case .prefixedName(let prefix, let local):
            guard let namespace = parser.namespaces[Array(prefix.unicodeScalars)] else {
                throw parser.error("prefix '\(prefix):' is not declared")
            }
            let expanded = namespace + local
            guard let iri = IRI(rawValue: expanded) else {
                throw parser.error("'\(prefix):\(local)' expands to <\(expanded)>, which is not an IRI")
            }
            self = iri
        default:
            return nil
        }
        try parser.advance()
    }

    /// An `IRIREF`'s text, resolved against the parser's base (RFC 3986
    /// §5.2, as ``init(reference:base:)`` applies it).
    init(turtleReference reference: String, in parser: TurtleParser) throws {
        do {
            self = try IRI(reference: reference, base: parser.base)
        } catch .relativeWithoutBase {
            throw parser.error("<\(reference)> is relative and there is no base IRI")
        } catch .unresolvable(let base) {
            throw parser.error("<\(reference)> does not resolve to an IRI against <\(base)>")
        }
    }
}

extension BlankNode {
    /// `BlankNode ::= BLANK_NODE_LABEL | ANON`. `nil` for any other token.
    init?(turtle parser: inout TurtleParser) throws {
        switch parser.current.token {
        case .blankNodeLabel(let label):
            try parser.advance()
            self = try parser.blankNodes.node(labelled: label)
        case .punctuation("["):
            // ANON ::= '[' WS* ']'
            let position = parser.current.position
            try parser.advance()
            guard parser.isPunctuation("]") else {
                throw parser.lexer.scanner.error("expected ']': a blank node property list is not allowed here", at: position)
            }
            try parser.advance()
            self = try parser.blankNodes.fresh()
        default:
            return nil
        }
    }
}

extension Literal {
    /// `literal ::= RDFLiteral | NumericLiteral | BooleanLiteral`. `nil` for
    /// any other token.
    init?(turtle parser: inout TurtleParser) throws {
        if let literal = Literal(parser.current.token) {
            try parser.advance()
            self = literal
            return
        }
        guard case .string(let lexicalForm, _) = parser.current.token else { return nil }
        let start = parser.current.position
        try parser.advance()
        if case .atWord(let word) = parser.current.token {
            self = try Literal(lexicalForm, languageDirection: word, at: parser.current.position, in: parser.lexer.scanner)
            try parser.advance()
            return
        }
        if parser.isPunctuation("^^") {
            try parser.advance()
            guard let datatype = try IRI(turtle: &parser) else { throw parser.error("expected a datatype IRI") }
            do {
                self = try Literal(lexicalForm, datatypeIRI: datatype)
            } catch {
                throw parser.lexer.scanner.error("a language-tagged string cannot be written with '^^'", at: start)
            }
            return
        }
        self.init(lexicalForm)
    }

    /// The literal a Turtle `NumericLiteral` or `BooleanLiteral` token
    /// stands for (RDF 1.2 Turtle §2.5.2, §7.4): `INTEGER`, `DECIMAL` and
    /// `DOUBLE` with their XML Schema datatypes, `true` and `false` as
    /// `xsd:boolean`. `nil` for any other token.
    init?(_ token: TurtleToken) {
        let datatype: IRI
        let text: String
        switch token {
        case .integer(let lexicalForm): (datatype, text) = (.xsdInteger, lexicalForm)
        case .decimal(let lexicalForm): (datatype, text) = (.xsdDecimal, lexicalForm)
        case .double(let lexicalForm): (datatype, text) = (.xsdDouble, lexicalForm)
        case .word("true"): (datatype, text) = (.xsdBoolean, "true")
        case .word("false"): (datatype, text) = (.xsdBoolean, "false")
        default: return nil
        }
        self.init(text, datatype: datatype)
    }

    /// The lexical form itself, when Turtle reads it back as this literal
    /// (RDF 1.2 Turtle §2.5.2): `INTEGER`, `DECIMAL` and `DOUBLE` with their
    /// XML Schema datatypes, and `true` and `false` as `xsd:boolean`.
    var turtleShortForm: String? {
        guard let datatype else { return nil }
        let matches: Bool
        switch datatype {
        case .xsdInteger: matches = lexicalForm.wholeMatch(of: #/[+-]?[0-9]+/#) != nil
        case .xsdDecimal: matches = lexicalForm.wholeMatch(of: #/[+-]?[0-9]*\.[0-9]+/#) != nil
        case .xsdDouble: matches = lexicalForm.wholeMatch(of: #/[+-]?(?:[0-9]+\.[0-9]*|\.?[0-9]+)[eE][+-]?[0-9]+/#) != nil
        case .xsdBoolean: matches = lexicalForm == "true" || lexicalForm == "false"
        default: matches = false
        }
        return matches ? lexicalForm : nil
    }
}

extension Triple where SubjectValue == SubjectTerm, ObjectValue == ObjectTerm {
    /// `tripleTerm ::= '<<(' ttSubject verb ttObject ')>>'`
    init(turtle parser: inout TurtleParser) throws {
        try parser.expect("<<(", "to open a triple term")
        // ttSubject ::= iri | BlankNode
        let subject: SubjectTerm
        if let iri = try IRI(turtle: &parser) {
            subject = .iri(iri)
        } else if let node = try BlankNode(turtle: &parser) {
            subject = .blankNode(node)
        } else {
            throw parser.error("expected an IRI or blank node as the subject of a triple term")
        }
        let predicate = try parser.parseVerb()
        let object = try ObjectTerm(turtleTripleTermObject: &parser, of: "a triple term")
        try parser.expect(")>>", "to close a triple term")
        self.init(subject: subject, predicate: predicate, object: object)
    }
}

extension ObjectTerm {
    /// `ttObject ::= iri | BlankNode | literal | tripleTerm`, the object of
    /// `construct`, a triple term or a reified triple.
    init(turtleTripleTermObject parser: inout TurtleParser, of construct: String) throws {
        if let iri = try IRI(turtle: &parser) {
            self = .iri(iri)
        } else if let node = try BlankNode(turtle: &parser) {
            self = .blankNode(node)
        } else if let literal = try Literal(turtle: &parser) {
            self = .literal(literal)
        } else if parser.isPunctuation("<<(") {
            self = .tripleTerm(try Graph.Element(turtle: &parser))
        } else {
            throw parser.error("expected an IRI, blank node, literal or triple term as the object of \(construct)")
        }
    }
}
