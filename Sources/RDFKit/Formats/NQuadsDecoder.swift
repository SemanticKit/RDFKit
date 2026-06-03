import Foundation

/// Decodes N-Quads source into RDF datasets.
struct NQuadsDecoder {
    private var lexer: NQuadsLexer
    private var defaultGraph = Graph()
    private var namedGraphs: [IRI: Graph] = [:]

    /// Creates an N-Quads decoder.
    init(text: String) {
        self.lexer = NQuadsLexer(text)
    }

    /// Decodes a dataset from the complete source.
    mutating func decodeDataset() throws -> Dataset {
        while true {
            lexer.skipWhitespaceAndComments()
            if lexer.isAtEnd { break }
            if try parseVersionDirectiveIfPresent() {
                continue
            }
            try parseQuad()
        }

        return Dataset(defaultGraph: defaultGraph, namedGraphs: namedGraphs)
    }

    private mutating func parseVersionDirectiveIfPresent() throws -> Bool {
        if lexer.consumeWord("VERSION", caseInsensitive: false, wordBoundary: true) {
            lexer.skipWhitespaceAndComments()
            _ = try parseStringLiteral()
            lexer.skipWhitespaceAndComments()
            if lexer.peek() == "." {
                _ = lexer.advance()
            }
            return true
        }
        return false
    }

    private mutating func parseQuad() throws {
        let subject = try parseSubject()
        lexer.skipWhitespaceAndComments()
        let predicate = try parsePredicate()
        lexer.skipWhitespaceAndComments()
        let object = try parseObject()
        lexer.skipWhitespaceAndComments()

        var graphName: IRI? = nil
        if let ch = lexer.peek(), ch != "." {
            graphName = try parseGraphName()
            lexer.skipWhitespaceAndComments()
        }

        try lexer.expect(".")
        try addQuad(subject: subject, predicate: predicate, object: object, graphName: graphName)
    }

    private mutating func parseSubject() throws -> AnyRDFSubject {
        if lexer.starts(with: "_:") {
            let blank = try parseBlankNode()
            return AnyRDFSubject(blank)
        }
        let iri = try parseIriRef()
        return AnyRDFSubject(iri)
    }

    private mutating func parsePredicate() throws -> IRI {
        return try parseIriRef()
    }

    private mutating func parseObject() throws -> AnyRDFObject {
        if lexer.starts(with: "<<") {
            let term = try parseTripleTerm()
            return AnyRDFObject(term)
        }
        if lexer.starts(with: "_:") {
            let blank = try parseBlankNode()
            return AnyRDFObject(blank)
        }
        if lexer.peek() == "<" {
            let iri = try parseIriRef()
            return AnyRDFObject(iri)
        }
        if lexer.peek() == "\"" || lexer.peek() == "'" {
            let literal = try parseLiteral()
            return AnyRDFObject(literal)
        }

        throw lexer.errorUnexpectedCharacter()
    }

    private mutating func parseGraphName() throws -> IRI {
        if lexer.starts(with: "_:") {
            _ = try parseBlankNode()
            throw NQuadsError.invalidGraphName(line: lexer.line, column: lexer.column)
        }
        return try parseIriRef()
    }

    private mutating func parseTripleTerm() throws -> TripleTerm {
        try lexer.expect("<<")
        lexer.skipWhitespaceAndComments()
        var hasParens = false
        if lexer.peek() == "(" {
            hasParens = true
            _ = lexer.advance()
            lexer.skipWhitespaceAndComments()
        }
        let subject = try parseSubject()
        lexer.skipWhitespaceAndComments()
        let predicate = try parsePredicate()
        lexer.skipWhitespaceAndComments()
        let object = try parseObject()
        lexer.skipWhitespaceAndComments()
        if hasParens {
            try lexer.expect(")")
            lexer.skipWhitespaceAndComments()
        }
        try lexer.expect(">>")
        return TripleTerm(subject: subject, predicate: predicate, object: object)
    }

    private mutating func parseBlankNode() throws -> BlankNode {
        try lexer.expect("_:")
        let label = try parseNameToken()
        return try BlankNode(label)
    }

    private mutating func parseIriRef() throws -> IRI {
        let value = try parseIriRefString()
        return IRI(value)
    }

    private mutating func parseIriRefString() throws -> String {
        try lexer.expect("<")
        var value = ""
        while let ch = lexer.peek() {
            if ch == ">" {
                _ = lexer.advance()
                return value
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
            let datatype = try parseIriRef()
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

        var value = ""
        while let ch = lexer.peek() {
            if ch == quoteChar {
                _ = lexer.advance()
                return value
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
            if ch == "-" && lexer.peekNext() == "-" {
                break
            }
            if ch.isWhitespace { break }
            if ch == "-" || ch.isLetter || ch.isNumber {
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

    private mutating func parseNameToken() throws -> String {
        var token = ""
        while let ch = lexer.peek() {
            if ch.isWhitespace || "<>\"'".contains(ch) { break }
            if ch == "." {
                if lexer.peekNext()?.isWhitespace == true { break }
            }
            token.append(ch)
            _ = lexer.advance()
        }
        if token.isEmpty {
            throw lexer.errorUnexpectedCharacter()
        }
        return token
    }

    private mutating func addQuad(
        subject: AnyRDFSubject,
        predicate: IRI,
        object: AnyRDFObject,
        graphName: IRI?
    ) throws {
        let triple = Graph.TripleType(subject: subject, predicate: predicate, object: object)
        if let name = graphName {
            var graph = try (namedGraphs[name] ?? Graph(name: name))
            do {
                try graph.insert(triple)
            } catch RDFGraphError.duplicateTriple {
                return
            }
            namedGraphs[name] = graph
        } else {
            do {
                try defaultGraph.insert(triple)
            } catch RDFGraphError.duplicateTriple {
                return
            }
        }
    }
}
