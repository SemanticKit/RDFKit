import IRIKit
import RDFCore
import RDFKit

/// A recursive-descent parser for the RDF 1.2 Turtle grammar (§7.3), with
/// the triple-producing actions of §7.4.
struct TurtleParser {
    var lexer: TurtleLexer
    var current: (token: TurtleToken, position: Int)
    var base: String?
    /// Prefix labels declared by `@prefix` / `PREFIX`, with their namespace
    /// IRI as written after resolution.
    var namespaces: [String: String] = [:]
    var blankNodes = BlankNodeLabels()
    var graph: Graph = []

    init(_ document: String, base: String?) throws {
        lexer = TurtleLexer(document)
        self.base = base
        current = (.end, 0)
        current = try lexer.next()
    }

    // MARK: - Tokens

    mutating func advance() throws {
        current = try lexer.next()
    }

    func error(_ message: String) -> SyntaxError {
        lexer.scanner.error(message, at: current.position)
    }

    func isPunctuation(_ text: String) -> Bool {
        current.token == .punctuation(text)
    }

    mutating func expect(_ text: String, _ context: String) throws {
        guard isPunctuation(text) else { throw error("expected '\(text)' \(context)") }
        try advance()
    }

    // MARK: - Statements

    /// `turtleDoc ::= statement*`
    mutating func parseDocument() throws -> Graph {
        while current.token != .end {
            try parseStatement()
        }
        return graph
    }

    /// `statement ::= directive | (triples '.')`
    mutating func parseStatement() throws {
        switch current.token {
        case .atWord("prefix"):
            try advance()
            try parsePrefix()
            try expect(".", "after @prefix")
        case .atWord("base"):
            try advance()
            try parseBase()
            try expect(".", "after @base")
        case .atWord("version"):
            try advance()
            try parseVersion()
            try expect(".", "after @version")
        case .word(let word) where word.uppercased() == "PREFIX":
            try advance()
            try parsePrefix()
        case .word(let word) where word.uppercased() == "BASE":
            try advance()
            try parseBase()
        case .word(let word) where word.uppercased() == "VERSION":
            try advance()
            try parseVersion()
        default:
            try parseTriples()
            try expect(".", "after triples")
        }
    }

    /// `PNAME_NS IRIREF`
    mutating func parsePrefix() throws {
        guard case .prefixedName(let prefix, let local) = current.token, local.isEmpty else {
            throw error("expected a prefix label ending in ':'")
        }
        try advance()
        guard case .iriReference(let reference) = current.token else {
            throw error("expected an IRI for prefix '\(prefix):'")
        }
        namespaces[prefix] = try resolve(reference).rawValue
        try advance()
    }

    /// `IRIREF`
    mutating func parseBase() throws {
        guard case .iriReference(let reference) = current.token else {
            throw error("expected a base IRI")
        }
        base = try resolve(reference).rawValue
        try advance()
    }

    /// `VersionSpecifier ::= STRING_LITERAL_QUOTE | STRING_LITERAL_SINGLE_QUOTE`
    mutating func parseVersion() throws {
        guard case .string(_, isLong: false) = current.token else {
            throw error("expected a single-line quoted version specifier")
        }
        try advance()
    }

    /// `triples ::= (subject predicateObjectList) | (blankNodePropertyList predicateObjectList?) | (reifiedTriple predicateObjectList?)`
    mutating func parseTriples() throws {
        if isPunctuation("[") {
            try advance()
            let subject = SubjectTerm.blankNode(try blankNodes.fresh())
            if isPunctuation("]") {
                try advance()
                try parsePredicateObjectList(subject: subject)
                return
            }
            try parsePredicateObjectList(subject: subject)
            try expect("]", "to close a blank node property list")
            if isVerbStart { try parsePredicateObjectList(subject: subject) }
        } else if isPunctuation("<<") {
            let subject = try parseReifiedTriple()
            if isVerbStart { try parsePredicateObjectList(subject: subject) }
        } else {
            let subject = try parseSubject()
            try parsePredicateObjectList(subject: subject)
        }
    }

    // MARK: - Predicates and objects

    var isVerbStart: Bool {
        switch current.token {
        case .iriReference, .prefixedName, .word("a"): true
        default: false
        }
    }

    /// `predicateObjectList ::= verb objectList (';' (verb objectList)?)*`
    mutating func parsePredicateObjectList(subject: SubjectTerm) throws {
        let predicate = try parseVerb()
        try parseObjectList(subject: subject, predicate: predicate)
        while isPunctuation(";") {
            try advance()
            if isVerbStart {
                let predicate = try parseVerb()
                try parseObjectList(subject: subject, predicate: predicate)
            }
        }
    }

    /// `objectList ::= object annotation (',' object annotation)*`
    mutating func parseObjectList(subject: SubjectTerm, predicate: IRI) throws {
        repeat {
            let object = try parseObject()
            emit(subject, predicate, object)
            try parseAnnotation(of: Graph.Element(subject: subject, predicate: predicate, object: object))
        } while try consume(",")
    }

    mutating func consume(_ text: String) throws -> Bool {
        guard isPunctuation(text) else { return false }
        try advance()
        return true
    }

    /// `verb ::= predicate | 'a'`
    mutating func parseVerb() throws -> IRI {
        if current.token == .word("a") {
            try advance()
            return RDF.type<any RDFCore.Resource>.metadata.id
        }
        guard let iri = try parseIRIIfPresent() else { throw error("expected a predicate") }
        return iri
    }

    /// `subject ::= iri | BlankNode | collection`
    mutating func parseSubject() throws -> SubjectTerm {
        if let iri = try parseIRIIfPresent() { return .iri(iri) }
        switch current.token {
        case .blankNodeLabel(let label):
            try advance()
            return .blankNode(try blankNodes.node(labelled: label))
        case .punctuation("("):
            return try parseCollection()
        default:
            throw error("expected a subject")
        }
    }

    /// `object ::= iri | BlankNode | collection | blankNodePropertyList | literal | tripleTerm | reifiedTriple`
    mutating func parseObject() throws -> ObjectTerm {
        if let iri = try parseIRIIfPresent() { return .iri(iri) }
        if let literal = try parseLiteralIfPresent() { return .literal(literal) }
        switch current.token {
        case .blankNodeLabel(let label):
            try advance()
            return .blankNode(try blankNodes.node(labelled: label))
        case .punctuation("["):
            try advance()
            let node = try blankNodes.fresh()
            if !isPunctuation("]") {
                try parsePredicateObjectList(subject: .blankNode(node))
            }
            try expect("]", "to close a blank node property list")
            return .blankNode(node)
        case .punctuation("("):
            return try parseCollection().object
        case .punctuation("<<("):
            return .tripleTerm(try parseTripleTerm())
        case .punctuation("<<"):
            return try parseReifiedTriple().object
        default:
            throw error("expected an object")
        }
    }

    /// `collection ::= '(' object* ')'`, as an `rdf:first` / `rdf:rest` list.
    mutating func parseCollection() throws -> SubjectTerm {
        try expect("(", "to open a collection")
        var items: [ObjectTerm] = []
        while !isPunctuation(")") {
            items.append(try parseObject())
        }
        try advance()
        var list = SubjectTerm.iri(type(of: RDF.nil).metadata.id)
        for item in items.reversed() {
            let cell = SubjectTerm.blankNode(try blankNodes.fresh())
            emit(cell, RDF.first.metadata.id, item)
            emit(cell, RDF.rest.metadata.id, list.object)
            list = cell
        }
        return list
    }

    // MARK: - RDF 1.2 triple terms, reification and annotation

    /// `annotation ::= (reifier | annotationBlock)*`
    ///
    /// Each reifier reifies the triple. An annotation block describes the
    /// reifier just before it, or a fresh blank node reifier when none is
    /// waiting for a block.
    mutating func parseAnnotation(of triple: Graph.Element) throws {
        var pending: SubjectTerm?
        while true {
            if isPunctuation("~") {
                try advance()
                let reifier = try parseReifierIdentifier() ?? .blankNode(blankNodes.fresh())
                emit(reifier, RDF.reifies.metadata.id, .tripleTerm(triple))
                pending = reifier
            } else if isPunctuation("{|") {
                try advance()
                let reifier: SubjectTerm
                if let waiting = pending {
                    reifier = waiting
                } else {
                    reifier = .blankNode(try blankNodes.fresh())
                    emit(reifier, RDF.reifies.metadata.id, .tripleTerm(triple))
                }
                pending = nil
                try parsePredicateObjectList(subject: reifier)
                try expect("|}", "to close an annotation block")
            } else {
                return
            }
        }
    }

    /// The `(iri | BlankNode)?` after `~`.
    mutating func parseReifierIdentifier() throws -> SubjectTerm? {
        if let iri = try parseIRIIfPresent() { return .iri(iri) }
        if let node = try parseBlankNodeIfPresent() { return .blankNode(node) }
        return nil
    }

    /// `reifiedTriple ::= '<<' rtSubject verb rtObject reifier? '>>'`,
    /// returning the reifier.
    mutating func parseReifiedTriple() throws -> SubjectTerm {
        try expect("<<", "to open a reified triple")
        // rtSubject ::= iri | BlankNode | reifiedTriple
        let subject: SubjectTerm
        if let iri = try parseIRIIfPresent() {
            subject = .iri(iri)
        } else if let node = try parseBlankNodeIfPresent() {
            subject = .blankNode(node)
        } else if isPunctuation("<<") {
            subject = try parseReifiedTriple()
        } else {
            throw error("expected an IRI, blank node or reified triple as the subject of a reified triple")
        }
        let predicate = try parseVerb()
        // rtObject ::= iri | BlankNode | literal | tripleTerm | reifiedTriple
        let object: ObjectTerm
        if isPunctuation("<<") {
            object = try parseReifiedTriple().object
        } else {
            object = try parseTripleTermObject(context: "a reified triple")
        }
        var reifier: SubjectTerm?
        if isPunctuation("~") {
            try advance()
            reifier = try parseReifierIdentifier()
        }
        try expect(">>", "to close a reified triple")
        let node = try reifier ?? .blankNode(blankNodes.fresh())
        emit(node, RDF.reifies.metadata.id, .tripleTerm(Graph.Element(subject: subject, predicate: predicate, object: object)))
        return node
    }

    /// `tripleTerm ::= '<<(' ttSubject verb ttObject ')>>'`
    mutating func parseTripleTerm() throws -> Graph.Element {
        try expect("<<(", "to open a triple term")
        // ttSubject ::= iri | BlankNode
        let subject: SubjectTerm
        if let iri = try parseIRIIfPresent() {
            subject = .iri(iri)
        } else if let node = try parseBlankNodeIfPresent() {
            subject = .blankNode(node)
        } else {
            throw error("expected an IRI or blank node as the subject of a triple term")
        }
        let predicate = try parseVerb()
        let object = try parseTripleTermObject(context: "a triple term")
        try expect(")>>", "to close a triple term")
        return Graph.Element(subject: subject, predicate: predicate, object: object)
    }

    /// `ttObject ::= iri | BlankNode | literal | tripleTerm`
    mutating func parseTripleTermObject(context: String) throws -> ObjectTerm {
        if let iri = try parseIRIIfPresent() { return .iri(iri) }
        if let node = try parseBlankNodeIfPresent() { return .blankNode(node) }
        if let literal = try parseLiteralIfPresent() { return .literal(literal) }
        if isPunctuation("<<(") { return .tripleTerm(try parseTripleTerm()) }
        throw error("expected an IRI, blank node, literal or triple term as the object of \(context)")
    }

    // MARK: - Terms

    /// `BlankNode ::= BLANK_NODE_LABEL | ANON`
    mutating func parseBlankNodeIfPresent() throws -> BlankNode? {
        switch current.token {
        case .blankNodeLabel(let label):
            try advance()
            return try blankNodes.node(labelled: label)
        case .punctuation("["):
            // ANON ::= '[' WS* ']'
            let position = current.position
            try advance()
            guard isPunctuation("]") else {
                throw lexer.scanner.error("expected ']': a blank node property list is not allowed here", at: position)
            }
            try advance()
            return try blankNodes.fresh()
        default:
            return nil
        }
    }

    /// `iri ::= IRIREF | PrefixedName`
    mutating func parseIRIIfPresent() throws -> IRI? {
        switch current.token {
        case .iriReference(let reference):
            let iri = try resolve(reference)
            try advance()
            return iri
        case .prefixedName(let prefix, let local):
            guard let namespace = namespaces[prefix] else {
                throw error("prefix '\(prefix):' is not declared")
            }
            let expanded = namespace + local
            guard let iri = IRI(rawValue: expanded) else {
                throw error("'\(prefix):\(local)' expands to <\(expanded)>, which is not an IRI")
            }
            try advance()
            return iri
        default:
            return nil
        }
    }

    /// `literal ::= RDFLiteral | NumericLiteral | BooleanLiteral`
    mutating func parseLiteralIfPresent() throws -> Literal? {
        let literal: Literal
        switch current.token {
        case .string(let lexicalForm, _):
            let start = current.position
            try advance()
            if case .atWord(let word) = current.token {
                let literal = try lexer.scanner.languageTaggedLiteral(lexicalForm, atWord: word, at: current.position)
                try advance()
                return literal
            }
            if isPunctuation("^^") {
                try advance()
                guard let datatype = try parseIRIIfPresent() else { throw error("expected a datatype IRI") }
                do {
                    return try Literal(lexicalForm, datatype: datatype)
                } catch {
                    throw lexer.scanner.error("a language-tagged string cannot be written with '^^'", at: start)
                }
            }
            return Literal(lexicalForm)
        case .integer(let text):
            literal = try Literal(text, datatype: XSD.integer.metadata.id)
        case .decimal(let text):
            literal = try Literal(text, datatype: XSD.decimal.metadata.id)
        case .double(let text):
            literal = try Literal(text, datatype: XSD.double.metadata.id)
        case .word("true"), .word("false"):
            guard case .word(let text) = current.token else { return nil }
            literal = try Literal(text, datatype: XSD.boolean.metadata.id)
        default:
            return nil
        }
        try advance()
        return literal
    }

    /// Resolves an `IRIREF` against the base IRI and validates the result.
    func resolve(_ reference: String) throws -> IRI {
        if let iri = IRI(rawValue: reference) { return iri }
        guard let base else {
            throw error("<\(reference)> is relative and there is no base IRI")
        }
        let resolved = IRIReferenceResolution.resolve(reference, against: base)
        guard let iri = IRI(rawValue: resolved) else {
            throw error("<\(reference)> resolves to <\(resolved)>, which is not an IRI")
        }
        return iri
    }

    mutating func emit(_ subject: SubjectTerm, _ predicate: IRI, _ object: ObjectTerm) {
        graph.insert(Graph.Element(subject: subject, predicate: predicate, object: object))
    }
}
