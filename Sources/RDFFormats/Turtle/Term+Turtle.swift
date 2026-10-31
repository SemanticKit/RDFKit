import IRIKit
import RDFCore

// The terms of RDF 1.2 Turtle, each made by an initializer on its own type
// from the production that writes it (§7.4, RDF Term Constructors). The
// productions come from the grammar as published, translated into
// ``TurtleGrammar``; ``TurtleDecoding`` reads the statements, and the terms
// read themselves. A term that writes triples of its own, a collection, a
// blank node property list or a reified triple, adds them to the document.

extension IRI {
    /// `IRIREF`: the characters between `<` and `>`, with their numeric
    /// escapes replaced (§6.4), resolved against the document's base
    /// (§6.3, RFC 3986 §5.2, as ``init(reference:base:)`` applies it).
    init(_ syntax: TurtleGrammar.IRIREF, in decoding: TurtleDecoding) throws {
        let reference = Escape.unescaped(syntax.text, delimiter: 1, try syntax.uchars.map { try Escape($0, from: syntax.location) })
        do {
            self = try IRI(reference: reference, base: decoding.base)
        } catch .relativeWithoutBase {
            throw SyntaxError("<\(reference)> is relative and there is no base IRI", at: syntax.location)
        } catch .unresolvable(let base) {
            throw SyntaxError("<\(reference)> does not resolve to an IRI against <\(base)>", at: syntax.location)
        }
    }

    /// `iri ::= IRIREF | PrefixedName`
    init(_ syntax: TurtleGrammar.Iri, in decoding: TurtleDecoding) throws {
        switch syntax {
        case .iriref(let reference): try self.init(reference, in: decoding)
        case .prefixedName(.pnameNs(let name)): try self.init(prefix: name, local: "", at: name.location, in: decoding)
        case .prefixedName(.pnameLn(let name)):
            let local = name.pnLocal
            let escapes = local.plxes.compactMap { plx in
                // A reserved character escape stands for the character after
                // the backslash; a percent escape stays as written (§6.4).
                plx.pnLocalEsc.map { Escape(range: Escape.range(of: $0.location, from: local.location, length: 2), scalar: $0.text.unicodeScalars.last!) }
            }
            try self.init(prefix: name.pnameNs, local: Escape.unescaped(local.text, delimiter: 0, escapes), at: name.location, in: decoding)
        }
    }

    /// A prefixed name: the namespace IRI declared for the label of `name`,
    /// followed by `local` (§6.3, §7.4).
    init(prefix name: TurtleGrammar.PNAME_NS, local: String, at location: TurtleGrammar.Location, in decoding: TurtleDecoding) throws {
        let prefix = name.pnPrefix?.text ?? ""
        guard let namespace = decoding.namespaces[Array(prefix.unicodeScalars)] else {
            throw SyntaxError("prefix '\(prefix):' is not declared", at: location)
        }
        let expanded = namespace + local
        guard let iri = IRI(rawValue: expanded) else {
            throw SyntaxError("'\(prefix):\(local)' expands to <\(expanded)>, which is not an IRI", at: location)
        }
        self = iri
    }

    /// `verb ::= predicate | 'a'`: `a` is `rdf:type` (§2.4).
    init(_ syntax: TurtleGrammar.Verb, in decoding: TurtleDecoding) throws {
        switch syntax {
        case .predicate(let predicate): try self.init(predicate.iri, in: decoding)
        case .a: self = .rdfType
        }
    }
}

extension Escape {
    /// A numeric escape, `UCHAR`, in a terminal that starts at `start`.
    init(_ uchar: TurtleGrammar.UCHAR, from start: TurtleGrammar.Location) throws {
        guard let scalar = Unicode.Scalar(hexadecimal: uchar.hexes.map(\.text)) else {
            throw SyntaxError("escape \(uchar.text) names no Unicode scalar value", at: uchar.location)
        }
        self.init(range: Self.range(of: uchar.location, from: start, length: uchar.text.unicodeScalars.count), scalar: scalar)
    }

    /// A string escape, `ECHAR`, in a terminal that starts at `start`.
    init(_ echar: TurtleGrammar.ECHAR, from start: TurtleGrammar.Location) {
        self.init(range: Self.range(of: echar.location, from: start, length: 2), scalar: Unicode.Scalar(stringEscape: echar.text))
    }

    /// The range of a part of a terminal that starts at `start`: the part
    /// starts at `location` and is `length` scalars long.
    static func range(of location: TurtleGrammar.Location, from start: TurtleGrammar.Location, length: Int) -> Range<Int> {
        let offset = location.offset - start.offset
        return offset..<(offset + length)
    }

    /// The escapes of a string: its numeric and string escapes.
    static func escapes(uchars: [TurtleGrammar.UCHAR], echars: [TurtleGrammar.ECHAR], from start: TurtleGrammar.Location) throws -> [Escape] {
        try uchars.map { try Escape($0, from: start) } + echars.map { Escape($0, from: start) }
    }
}

extension String {
    /// The lexical form a Turtle `String` writes: the characters between
    /// its quotes, one or three, with their escapes replaced (§6.4).
    init(_ syntax: TurtleGrammar.String) throws {
        switch syntax {
        case .stringLiteralQuote(let string):
            self = Escape.unescaped(string.text, delimiter: 1, try Escape.escapes(uchars: string.uchars, echars: string.echars, from: string.location))
        case .stringLiteralSingleQuote(let string):
            self = Escape.unescaped(string.text, delimiter: 1, try Escape.escapes(uchars: string.uchars, echars: string.echars, from: string.location))
        case .stringLiteralLongQuote(let string):
            self = Escape.unescaped(string.text, delimiter: 3, try Escape.escapes(uchars: string.uchars, echars: string.echars, from: string.location))
        case .stringLiteralLongSingleQuote(let string):
            self = Escape.unescaped(string.text, delimiter: 3, try Escape.escapes(uchars: string.uchars, echars: string.echars, from: string.location))
        }
    }
}

extension TurtleGrammar.String {
    /// Where the string starts in the document.
    var location: TurtleGrammar.Location {
        switch self {
        case .stringLiteralQuote(let string): string.location
        case .stringLiteralSingleQuote(let string): string.location
        case .stringLiteralLongQuote(let string): string.location
        case .stringLiteralLongSingleQuote(let string): string.location
        }
    }
}

extension BlankNode {
    /// `BlankNode ::= BLANK_NODE_LABEL | ANON`: the node a label names,
    /// the same node every time, or a fresh node for `[]` (§7.4).
    init(_ syntax: TurtleGrammar.BlankNode, in decoding: inout TurtleDecoding) throws {
        switch syntax {
        case .blankNodeLabel(let label):
            // BLANK_NODE_LABEL ::= '_:' …: the label is what follows `_:`.
            self = try decoding.blankNodes.node(labelled: String(String.UnicodeScalarView(label.text.unicodeScalars.dropFirst(2))))
        case .anon:
            self = try decoding.blankNodes.fresh()
        }
    }

    /// `blankNodePropertyList ::= '[' predicateObjectList ']'`: a fresh
    /// node, the subject of the list's triples.
    init(_ syntax: TurtleGrammar.BlankNodePropertyList, in decoding: inout TurtleDecoding) throws {
        self = try decoding.blankNodes.fresh()
        try decoding.read(syntax.predicateObjectList, subject: .blankNode(self))
    }
}

extension Literal {
    /// `literal ::= RDFLiteral | NumericLiteral | BooleanLiteral`
    init(_ syntax: TurtleGrammar.Literal, in decoding: TurtleDecoding) throws {
        switch syntax {
        case .rdfLiteral(let literal): try self.init(literal, in: decoding)
        case .numericLiteral(let number): self.init(number)
        case .booleanLiteral(let boolean): self.init(boolean)
        }
    }

    /// `RDFLiteral ::= String (LANG_DIR | '^^' iri)?`
    init(_ syntax: TurtleGrammar.RDFLiteral, in decoding: TurtleDecoding) throws {
        let lexicalForm = try String(syntax.string)
        switch syntax.langDirOrIri {
        case .langDir(let tag)?:
            // LANG_DIR ::= '@' …: the tag and direction follow the `@`.
            let word = String(String.UnicodeScalarView(tag.text.unicodeScalars.dropFirst()))
            try self.init(lexicalForm, languageDirection: word, line: tag.location.line, column: tag.location.column)
        case .iri(let datatype)?:
            do {
                self = try Literal(lexicalForm, datatypeIRI: IRI(datatype, in: decoding))
            } catch let error as SyntaxError {
                throw error
            } catch {
                throw SyntaxError("a language-tagged string cannot be written with '^^'", at: syntax.string.location)
            }
        case nil:
            self.init(lexicalForm)
        }
    }

    /// `NumericLiteral ::= INTEGER | DECIMAL | DOUBLE`: the number as
    /// written, with the XML Schema datatype of its production (§7.4).
    init(_ syntax: TurtleGrammar.NumericLiteral) {
        switch syntax {
        case .integer(let number): self.init(number.text, datatype: .xsdInteger)
        case .decimal(let number): self.init(number.text, datatype: .xsdDecimal)
        case .double(let number): self.init(number.text, datatype: .xsdDouble)
        }
    }

    /// `BooleanLiteral ::= 'true' | 'false'`: "a lexical form of the true or
    /// false, depending on which matched the input, and a datatype of
    /// xsd:boolean" (§7.4).
    init(_ syntax: TurtleGrammar.BooleanLiteral) {
        switch syntax {
        case .true: self.init("true", datatype: .xsdBoolean)
        case .false: self.init("false", datatype: .xsdBoolean)
        }
    }

    /// The lexical form itself, when Turtle reads it back as this literal
    /// (§2.5.2): a `NumericLiteral` or `BooleanLiteral` whose literal is
    /// this one.
    var turtleShortForm: String? {
        guard datatype != nil, let syntax = try? TurtleGrammar.Literal.parse(lexicalForm) else { return nil }
        let literal: Literal
        switch syntax {
        case .numericLiteral(let number): literal = Literal(number)
        case .booleanLiteral(let boolean): literal = Literal(boolean)
        case .rdfLiteral: return nil
        }
        return literal == self ? lexicalForm : nil
    }
}

extension SubjectTerm {
    /// `subject ::= iri | BlankNode | collection`
    init(_ syntax: TurtleGrammar.Subject, in decoding: inout TurtleDecoding) throws {
        switch syntax {
        case .iri(let iri): self = .iri(try IRI(iri, in: decoding))
        case .blankNode(let node): self = .blankNode(try BlankNode(node, in: &decoding))
        case .collection(let collection): self = try SubjectTerm(collection, in: &decoding)
        }
    }

    /// `collection ::= '(' object* ')'`: an `rdf:first` / `rdf:rest` list
    /// of the objects, or `rdf:nil` when there are none (§7.4).
    init(_ syntax: TurtleGrammar.Collection, in decoding: inout TurtleDecoding) throws {
        var items: [ObjectTerm] = []
        for object in syntax.objects {
            items.append(try ObjectTerm(object, in: &decoding))
        }
        var list = SubjectTerm.iri(.rdfNil)
        for item in items.reversed() {
            let cell = SubjectTerm.blankNode(try decoding.blankNodes.fresh())
            decoding.emit(cell, .rdfFirst, item)
            decoding.emit(cell, .rdfRest, list.object)
            list = cell
        }
        self = list
    }

    /// `reifier ::= '~' (iri | BlankNode)?`: the reifier named, or a fresh
    /// blank node.
    init(_ syntax: TurtleGrammar.Reifier, in decoding: inout TurtleDecoding) throws {
        switch syntax.iriOrBlankNode {
        case .iri(let iri)?: self = .iri(try IRI(iri, in: decoding))
        case .blankNode(let node)?: self = .blankNode(try BlankNode(node, in: &decoding))
        case nil: self = .blankNode(try decoding.blankNodes.fresh())
        }
    }

    /// `reifiedTriple ::= '<<' rtSubject verb rtObject reifier? '>>'`: the
    /// reifier, which `rdf:reifies` the triple term of the triple (§7.4).
    init(_ syntax: TurtleGrammar.ReifiedTriple, in decoding: inout TurtleDecoding) throws {
        let subject = try SubjectTerm(syntax.rtSubject, in: &decoding)
        let predicate = try IRI(syntax.verb, in: decoding)
        let object = try ObjectTerm(syntax.rtObject, in: &decoding)
        let reifier = try syntax.reifier.map { try SubjectTerm($0, in: &decoding) } ?? .blankNode(decoding.blankNodes.fresh())
        decoding.emit(reifier, .rdfReifies, .tripleTerm(Graph.Element(subject: subject, predicate: predicate, object: object)))
        self = reifier
    }

    /// `rtSubject ::= iri | BlankNode | reifiedTriple`
    init(_ syntax: TurtleGrammar.RtSubject, in decoding: inout TurtleDecoding) throws {
        switch syntax {
        case .iri(let iri): self = .iri(try IRI(iri, in: decoding))
        case .blankNode(let node): self = .blankNode(try BlankNode(node, in: &decoding))
        case .reifiedTriple(let triple): self = try SubjectTerm(triple, in: &decoding)
        }
    }

    /// `ttSubject ::= iri | BlankNode`
    init(_ syntax: TurtleGrammar.TtSubject, in decoding: inout TurtleDecoding) throws {
        switch syntax {
        case .iri(let iri): self = .iri(try IRI(iri, in: decoding))
        case .blankNode(let node): self = .blankNode(try BlankNode(node, in: &decoding))
        }
    }
}

extension ObjectTerm {
    /// `object ::= iri | BlankNode | collection | blankNodePropertyList | literal | tripleTerm | reifiedTriple`
    init(_ syntax: TurtleGrammar.Object, in decoding: inout TurtleDecoding) throws {
        switch syntax {
        case .iri(let iri): self = .iri(try IRI(iri, in: decoding))
        case .blankNode(let node): self = .blankNode(try BlankNode(node, in: &decoding))
        case .collection(let collection): self = try SubjectTerm(collection, in: &decoding).object
        case .blankNodePropertyList(let properties): self = .blankNode(try BlankNode(properties, in: &decoding))
        case .literal(let literal): self = .literal(try Literal(literal, in: decoding))
        case .tripleTerm(let triple): self = .tripleTerm(try Graph.Element(triple, in: &decoding))
        case .reifiedTriple(let triple): self = try SubjectTerm(triple, in: &decoding).object
        }
    }

    /// `rtObject ::= iri | BlankNode | literal | tripleTerm | reifiedTriple`
    init(_ syntax: TurtleGrammar.RtObject, in decoding: inout TurtleDecoding) throws {
        switch syntax {
        case .iri(let iri): self = .iri(try IRI(iri, in: decoding))
        case .blankNode(let node): self = .blankNode(try BlankNode(node, in: &decoding))
        case .literal(let literal): self = .literal(try Literal(literal, in: decoding))
        case .tripleTerm(let triple): self = .tripleTerm(try Graph.Element(triple, in: &decoding))
        case .reifiedTriple(let triple): self = try SubjectTerm(triple, in: &decoding).object
        }
    }

    /// `ttObject ::= iri | BlankNode | literal | tripleTerm`
    init(_ syntax: TurtleGrammar.TtObject, in decoding: inout TurtleDecoding) throws {
        switch syntax {
        case .iri(let iri): self = .iri(try IRI(iri, in: decoding))
        case .blankNode(let node): self = .blankNode(try BlankNode(node, in: &decoding))
        case .literal(let literal): self = .literal(try Literal(literal, in: decoding))
        case .tripleTerm(let triple): self = .tripleTerm(try Graph.Element(triple, in: &decoding))
        }
    }
}

extension Triple where SubjectValue == SubjectTerm, ObjectValue == ObjectTerm {
    /// `tripleTerm ::= '<<(' ttSubject verb ttObject ')>>'`
    init(_ syntax: TurtleGrammar.TripleTerm, in decoding: inout TurtleDecoding) throws {
        let subject = try SubjectTerm(syntax.ttSubject, in: &decoding)
        let predicate = try IRI(syntax.verb, in: decoding)
        self.init(subject: subject, predicate: predicate, object: try ObjectTerm(syntax.ttObject, in: &decoding))
    }
}
