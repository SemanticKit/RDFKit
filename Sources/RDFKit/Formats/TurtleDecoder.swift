import Foundation

/// Decodes Turtle source into RDF graphs.
struct TurtleDecoder {
    private var lexer: TurtleLexer
    private var prefixes: [String: IRI] = [:]
    private var baseIRI: IRI?
    private var graph = Graph()
    private var blankNodeCounter = 0
    private let generatedBlankNodePrefix = "genid"

    /// Creates a Turtle graph decoder.
    init(text: String, baseIRI: IRI?) {
        self.lexer = TurtleLexer(text)
        self.baseIRI = baseIRI
    }

    /// Decodes a graph from the complete Turtle source.
    mutating func decodeGraph() throws -> Graph {
        while true {
            lexer.skipWhitespaceAndComments()
            if lexer.isAtEnd { break }
            if try parseDirectiveIfPresent() {
                continue
            }
            try parseTriples()
        }
        return graph
    }

    private mutating func parseDirectiveIfPresent() throws -> Bool {
        if lexer.peek() == "@" {
            _ = lexer.advance()
            lexer.skipWhitespaceAndComments()
            if lexer.consumeWord("prefix", caseInsensitive: true) {
                try parsePrefixDirective()
                return true
            }
            if lexer.consumeWord("base", caseInsensitive: true) {
                try parseBaseDirective()
                return true
            }
            throw lexer.errorUnexpectedToken("@")
        }

        if lexer.consumeWord("PREFIX", caseInsensitive: true) {
            try parsePrefixDirective()
            return true
        }
        if lexer.consumeWord("BASE", caseInsensitive: true) {
            try parseBaseDirective()
            return true
        }
        return false
    }

    private mutating func parsePrefixDirective() throws {
        lexer.skipWhitespaceAndComments()
        let prefix = try parsePrefixLabel()
        lexer.skipWhitespaceAndComments()
        let iriRef = try parseIriRef()
        lexer.skipWhitespaceAndComments()
        try lexer.expect(".")
        prefixes[prefix] = iriRef
    }

    private mutating func parseBaseDirective() throws {
        lexer.skipWhitespaceAndComments()
        let iriRef = try parseIriRef()
        lexer.skipWhitespaceAndComments()
        try lexer.expect(".")
        baseIRI = iriRef
    }

    private mutating func parseTriples() throws {
        let subject = try parseSubject()
        lexer.skipWhitespaceAndComments()
        try parsePredicateObjectList(subject: subject)
        lexer.skipWhitespaceAndComments()
        try lexer.expect(".")
    }

    private mutating func parsePredicateObjectList(subject: AnyRDFSubject) throws {
        var continueList = true
        while continueList {
            let predicate = try parseVerb()
            lexer.skipWhitespaceAndComments()
            let objects = try parseObjectList()
            for object in objects {
                try addTriple(subject: subject, predicate: predicate, object: object)
            }
            lexer.skipWhitespaceAndComments()
            if lexer.peek() == ";" {
                _ = lexer.advance()
                lexer.skipWhitespaceAndComments()
                if lexer.peek() == "." || lexer.peek() == "]" {
                    return
                }
            } else {
                continueList = false
            }
        }
    }

    private mutating func parseVerb() throws -> IRI {
        if lexer.consumeWord("a", caseInsensitive: false, wordBoundary: true) {
            return RDF.type.iri
        }
        return try parseIri()
    }

    private mutating func parseObjectList() throws -> [AnyRDFObject] {
        var objects: [AnyRDFObject] = [try parseObject()]
        lexer.skipWhitespaceAndComments()
        while lexer.peek() == "," {
            _ = lexer.advance()
            lexer.skipWhitespaceAndComments()
            objects.append(try parseObject())
            lexer.skipWhitespaceAndComments()
        }
        return objects
    }

    private mutating func parseSubject() throws -> AnyRDFSubject {
        if lexer.peek() == "[" {
            let blank = try parseBlankNodePropertyList()
            return AnyRDFSubject(blank)
        }
        if lexer.peek() == "(" {
            let obj = try parseCollection()
            return try asSubject(obj)
        }
        return try asSubject(parseIriOrBlankNode())
    }

    private mutating func parseObject() throws -> AnyRDFObject {
        if lexer.peek() == "[" {
            let blank = try parseBlankNodePropertyList()
            return AnyRDFObject(blank)
        }
        if lexer.peek() == "(" {
            return try parseCollection()
        }
        if lexer.starts(with: "<<") {
            let term = try parseTripleTerm()
            return AnyRDFObject(term)
        }
        if lexer.starts(with: "true", caseInsensitive: true), isBooleanBoundary(offset: 4) {
            _ = lexer.consumeWord("true", caseInsensitive: true)
            return AnyRDFObject(try Literal("true", datatype: TurtleDatatypes.xsdBoolean))
        }
        if lexer.starts(with: "false", caseInsensitive: true), isBooleanBoundary(offset: 5) {
            _ = lexer.consumeWord("false", caseInsensitive: true)
            return AnyRDFObject(try Literal("false", datatype: TurtleDatatypes.xsdBoolean))
        }
        if lexer.peek() == "<" || lexer.peek() == ":" || lexer.peek() == "_" || lexer.peek()?.isLetter == true {
            return try parseIriOrBlankNode()
        }
        if lexer.peek() == "\"" || lexer.peek() == "'" {
            let literal = try parseLiteral()
            return AnyRDFObject(literal)
        }
        if let token = lexer.peek(), token == "-" || token == "+" || token.isNumber {
            let literal = try parseNumericOrBooleanLiteral()
            return AnyRDFObject(literal)
        }

        throw lexer.errorUnexpectedCharacter()
    }

    private mutating func parseBlankNodePropertyList() throws -> BlankNode {
        try lexer.expect("[")
        lexer.skipWhitespaceAndComments()
        let blank = try newBlankNode()
        if lexer.peek() == "]" {
            _ = lexer.advance()
            return blank
        }
        let subject = AnyRDFSubject(blank)
        try parsePredicateObjectList(subject: subject)
        lexer.skipWhitespaceAndComments()
        try lexer.expect("]")
        return blank
    }

    private mutating func parseCollection() throws -> AnyRDFObject {
        try lexer.expect("(")
        lexer.skipWhitespaceAndComments()
        if lexer.peek() == ")" {
            _ = lexer.advance()
            return AnyRDFObject(RDF.nilValue)
        }

        var items: [AnyRDFObject] = []
        while lexer.peek() != ")" {
            items.append(try parseObject())
            lexer.skipWhitespaceAndComments()
        }
        try lexer.expect(")")

        let headBlank = try newBlankNode()
        var currentBlank = headBlank

        for (index, item) in items.enumerated() {
            let subject = AnyRDFSubject(currentBlank)
            try addTriple(
                subject: subject,
                predicate: RDF.first.iri,
                object: item
            )

            if index == items.count - 1 {
                try addTriple(
                    subject: subject,
                    predicate: RDF.rest.iri,
                    object: AnyRDFObject(RDF.nilValue)
                )
            } else {
                let nextBlank = try newBlankNode()
                try addTriple(
                    subject: subject,
                    predicate: RDF.rest.iri,
                    object: AnyRDFObject(nextBlank)
                )
                currentBlank = nextBlank
            }
        }

        return AnyRDFObject(headBlank)
    }

    private mutating func parseTripleTerm() throws -> TripleTerm {
        try lexer.expect("<<")
        lexer.skipWhitespaceAndComments()
        let subject = try parseSubject()
        lexer.skipWhitespaceAndComments()
        let predicate = try parseVerb()
        lexer.skipWhitespaceAndComments()
        let object = try parseObject()
        lexer.skipWhitespaceAndComments()
        try lexer.expect(">>")
        return TripleTerm(subject: subject, predicate: predicate, object: object)
    }

    private mutating func parseIriOrBlankNode() throws -> AnyRDFObject {
        if lexer.starts(with: "_:") {
            _ = lexer.advance()
            _ = lexer.advance()
            let label = try parseNameToken()
            return AnyRDFObject(try BlankNode(label))
        }
        let iri = try parseIri()
        return AnyRDFObject(iri)
    }

    private mutating func parseIri() throws -> IRI {
        if lexer.peek() == "<" {
            let value = try parseIriRefString()
            return try resolveIri(value)
        }
        if lexer.peek() == ":" || lexer.peek()?.isLetter == true || lexer.peek() == "_" {
            let (prefix, local) = try parsePrefixedName()
            guard let base = prefixes[prefix] else {
                throw lexer.errorUndefinedPrefix(prefix)
            }
            let iriString = base.string + local
            return try resolveIri(iriString)
        }
        throw lexer.errorUnexpectedCharacter()
    }

    private mutating func parseIriRef() throws -> IRI {
        let value = try parseIriRefString()
        return try resolveIri(value)
    }

    private mutating func parseIriRefString() throws -> String {
        try lexer.expect("<")
        var value = ""
        while let ch = lexer.peek() {
            if ch == ">" {
                _ = lexer.advance()
                return unescapeIri(value)
            }
            if ch == "\\" {
                _ = lexer.advance()
                guard let escaped = lexer.advance() else {
                    throw lexer.errorUnexpectedEnd()
                }
                switch escaped {
                case "u":
                    value.append(try lexer.readUnicodeScalar(count: 4))
                case "U":
                    value.append(try lexer.readUnicodeScalar(count: 8))
                default:
                    value.append(escaped)
                }
            } else {
                value.append(ch)
                _ = lexer.advance()
            }
        }
        throw lexer.errorUnexpectedEnd()
    }

    private mutating func parsePrefixedName() throws -> (String, String) {
        var prefix = ""
        if lexer.peek() == ":" {
            _ = lexer.advance()
        } else {
            prefix = try parseNameToken()
            try lexer.expect(":")
        }

        var local = ""
        while let ch = lexer.peek() {
            if ch.isWhitespace || ";,.[]()".contains(ch) {
                break
            }
            if ch == "\\" {
                _ = lexer.advance()
                guard let escaped = lexer.advance() else {
                    throw lexer.errorUnexpectedEnd()
                }
                switch escaped {
                case "u":
                    local.append(try lexer.readUnicodeScalar(count: 4))
                case "U":
                    local.append(try lexer.readUnicodeScalar(count: 8))
                default:
                    local.append(escaped)
                }
            } else {
                local.append(ch)
                _ = lexer.advance()
            }
        }
        return (prefix, local)
    }

    private mutating func parsePrefixLabel() throws -> String {
        var prefix = ""
        while let ch = lexer.peek() {
            if ch == ":" { _ = lexer.advance(); return prefix }
            if ch.isWhitespace { break }
            prefix.append(ch)
            _ = lexer.advance()
        }
        throw lexer.errorUnexpectedCharacter()
    }

    private mutating func parseNameToken() throws -> String {
        var token = ""
        while let ch = lexer.peek() {
            if ch.isWhitespace || ":;,.[]()".contains(ch) {
                break
            }
            token.append(ch)
            _ = lexer.advance()
        }
        if token.isEmpty {
            throw lexer.errorUnexpectedCharacter()
        }
        return token
    }

    private mutating func parseLiteral() throws -> Literal {
        let string = try parseStringLiteral()
        lexer.skipWhitespaceAndComments()
        if lexer.peek() == "@" {
            _ = lexer.advance()
            let lang = try parseLanguageTag()
            var direction: TextDirection? = nil
            if lexer.starts(with: "--") {
                _ = lexer.advance()
                _ = lexer.advance()
                let dirToken = try parseNameToken()
                guard let parsed = TextDirection(rawValue: dirToken) else {
                    throw lexer.errorUnexpectedToken(dirToken)
                }
                direction = parsed
            }
            return try Literal(string, languageTag: lang, textDirection: direction)
        }
        if lexer.starts(with: "^^") {
            _ = lexer.advance()
            _ = lexer.advance()
            let datatype = try parseIri()
            return try Literal(string, datatype: datatype)
        }
        return try Literal(string)
    }

    private mutating func parseStringLiteral() throws -> String {
        guard let quote = lexer.peek(), quote == "\"" || quote == "'" else {
            throw lexer.errorUnexpectedCharacter()
        }
        let quoteChar = quote
        _ = lexer.advance()

        var triple = false
        if lexer.peek() == quoteChar {
            _ = lexer.advance()
            if lexer.peek() == quoteChar {
                _ = lexer.advance()
                triple = true
            } else {
                return ""
            }
        }

        var value = ""
        while let ch = lexer.peek() {
            if ch == quoteChar {
                _ = lexer.advance()
                if triple {
                    if lexer.peek() == quoteChar {
                        _ = lexer.advance()
                        if lexer.peek() == quoteChar {
                            _ = lexer.advance()
                            return value
                        }
                        value.append(quoteChar)
                    } else {
                        value.append(ch)
                    }
                } else {
                    return value
                }
            } else if ch == "\\" {
                _ = lexer.advance()
                guard let escaped = lexer.advance() else {
                    throw lexer.errorUnexpectedEnd()
                }
                switch escaped {
                case "n": value.append("\n")
                case "t": value.append("\t")
                case "r": value.append("\r")
                case "\\": value.append("\\")
                case "\"": value.append("\"")
                case "'": value.append("'")
                case "u": value.append(try lexer.readUnicodeScalar(count: 4))
                case "U": value.append(try lexer.readUnicodeScalar(count: 8))
                default: value.append(escaped)
                }
            } else {
                value.append(ch)
                _ = lexer.advance()
            }
        }
        throw lexer.errorUnexpectedEnd()
    }

    private mutating func parseLanguageTag() throws -> String {
        var tag = ""
        while let ch = lexer.peek() {
            if ch.isWhitespace || ";,.[]()".contains(ch) {
                break
            }
            if ch == "-" {
                if lexer.peekNext() == "-" {
                    break
                }
                tag.append(ch)
                _ = lexer.advance()
                continue
            }
            if ch.isLetter || ch.isNumber {
                tag.append(ch)
                _ = lexer.advance()
            } else {
                break
            }
        }
        if tag.isEmpty {
            throw lexer.errorUnexpectedCharacter()
        }
        return tag.lowercased()
    }

    private mutating func parseNumericOrBooleanLiteral() throws -> Literal {
        let token = try parseNumericToken()
        let lower = token.lowercased()
        if lower == "true" || lower == "false" {
            return try Literal(lower, datatype: TurtleDatatypes.xsdBoolean)
        }
        if lower.contains("e") {
            return try Literal(token, datatype: TurtleDatatypes.xsdDouble)
        }
        if lower.contains(".") {
            return try Literal(token, datatype: TurtleDatatypes.xsdDecimal)
        }
        return try Literal(token, datatype: TurtleDatatypes.xsdInteger)
    }

    private mutating func parseNumericToken() throws -> String {
        var token = ""
        while let ch = lexer.peek() {
            if ch.isWhitespace || ";,[]()".contains(ch) {
                break
            }
            if ch == "." {
                let next = lexer.peekNext()
                if next == nil || next?.isWhitespace == true || ";,])".contains(next ?? " ") {
                    break
                }
            }
            if ch == "." || ch == "+" || ch == "-" || ch == "e" || ch == "E" || ch.isNumber {
                token.append(ch)
                _ = lexer.advance()
            } else {
                break
            }
        }
        if token.isEmpty {
            throw lexer.errorUnexpectedCharacter()
        }
        return token
    }

    private func isBooleanBoundary(offset: Int) -> Bool {
        guard let next = lexer.peek(after: offset) else { return true }
        if next.isWhitespace { return true }
        return ";,.])".contains(next)
    }

    private mutating func resolveIri(_ value: String) throws -> IRI {
        if let base = baseIRI {
            if let resolved = URL(string: value, relativeTo: try base.asURL())?.absoluteString {
                return IRI(resolved)
            }
        }
        return IRI(value)
    }

    private func unescapeIri(_ value: String) -> String {
        value
    }

    private mutating func newBlankNode() throws -> BlankNode {
        defer { blankNodeCounter += 1 }
        return try BlankNode("\(generatedBlankNodePrefix)\(blankNodeCounter)")
    }

    private mutating func addTriple(subject: AnyRDFSubject, predicate: IRI, object: AnyRDFObject) throws {
        let triple = Graph.TripleType(subject: subject, predicate: predicate, object: object)
        do {
            try graph.insert(triple)
        } catch RDFGraphError.duplicateTriple {
            return
        }
    }

    private func asSubject(_ object: AnyRDFObject) throws -> AnyRDFSubject {
        if let iri = object.node as? IRI {
            return AnyRDFSubject(iri)
        }
        if let blank = object.node as? BlankNode {
            return AnyRDFSubject(blank)
        }
        throw TurtleError.invalidToken("Object is not a valid subject", line: lexer.line, column: lexer.column)
    }
}
