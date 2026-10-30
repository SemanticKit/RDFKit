import IRIKit
import RDFCore

// The terms of RDF 1.2 N-Triples (§7), each read by an initializer on its
// own type at the scanner's cursor. ``NTriplesDecoder`` reads the statements
// and the lines; the terms read themselves.

extension IRI {
    /// An `IRIREF`, which N-Triples requires to be absolute.
    init(nTriples scanner: inout Scanner) throws {
        let start = scanner.index
        guard scanner.peek(is: "<") else { throw scanner.error("expected an IRI") }
        let text = try scanner.scanIRIReference()
        do {
            try self.init(validating: text)
        } catch {
            throw scanner.error("<\(text)> is not an absolute IRI", at: start)
        }
    }
}

extension BlankNode {
    /// A `BLANK_NODE_LABEL`.
    init(nTriples scanner: inout Scanner) throws {
        try self.init(scanner.scanBlankNodeLabel())
    }
}

extension SubjectTerm {
    /// `subject ::= IRIREF | BLANK_NODE_LABEL`
    init(nTriples scanner: inout Scanner) throws {
        if scanner.peek(spells: "_:") {
            self = .blankNode(try BlankNode(nTriples: &scanner))
            return
        }
        guard scanner.peek(is: "<"), !scanner.peek(is: "<", at: 1) else {
            throw scanner.error("expected an IRI or blank node as subject")
        }
        self = .iri(try IRI(nTriples: &scanner))
    }
}

extension ObjectTerm {
    /// `object ::= IRIREF | BLANK_NODE_LABEL | literal | tripleTerm`
    init(nTriples scanner: inout Scanner) throws {
        if scanner.peek(spells: "<<(") {
            self = .tripleTerm(try Graph.Element(nTriples: &scanner))
        } else if scanner.peek(is: "\"") {
            self = .literal(try Literal(nTriples: &scanner))
        } else {
            self = try SubjectTerm(nTriples: &scanner).object
        }
    }
}

extension Triple where SubjectValue == SubjectTerm, ObjectValue == ObjectTerm {
    /// `tripleTerm ::= '<<(' subject predicate object ')>>'`
    init(nTriples scanner: inout Scanner) throws {
        guard scanner.consume("<<(") else { throw scanner.error("expected '<<(' to open a triple term") }
        scanner.skipLineSpace()
        let subject = try SubjectTerm(nTriples: &scanner)
        scanner.skipLineSpace()
        let predicate = try IRI(nTriples: &scanner)
        scanner.skipLineSpace()
        let object = try ObjectTerm(nTriples: &scanner)
        scanner.skipLineSpace()
        guard scanner.consume(")>>") else { throw scanner.error("expected ')>>' to close a triple term") }
        self.init(subject: subject, predicate: predicate, object: object)
    }
}

extension Literal {
    /// `literal ::= STRING_LITERAL_QUOTE ('^^' IRIREF | LANG_DIR)?`
    init(nTriples scanner: inout Scanner) throws {
        let start = scanner.index
        let lexicalForm = try scanner.scanStringLiteralQuote()
        scanner.skipLineSpace()
        if scanner.consume("^^") {
            scanner.skipLineSpace()
            let datatype = try IRI(nTriples: &scanner)
            do {
                try self.init(lexicalForm, datatype: datatype)
            } catch {
                throw scanner.error("a language-tagged string cannot be written with '^^'", at: start)
            }
        } else if scanner.peek(is: "@") {
            let position = scanner.index
            try self.init(lexicalForm, languageDirection: try scanner.scanAtWord(), at: position, in: scanner)
        } else {
            self.init(lexicalForm)
        }
    }
}

extension Scanner {
    /// Skips spaces, tabs and comments, staying on the current line: the
    /// white space between N-Triples terms.
    mutating func skipLineSpace() {
        while let scalar = peek() {
            if scalar == " " || scalar == "\t" {
                advance()
            } else if scalar == "#" {
                while let scalar = peek(), scalar != "\n", scalar != "\r" { advance() }
            } else {
                return
            }
        }
    }
}
