import Foundation

/// Decodes OWL 2 Functional-Style Syntax into RDF graphs.
struct OWLFunctionalSyntaxDecoder {
    private var lexer: OWLFunctionalSyntaxLexer
    private var prefixes: [String: IRI] = [:]
    private var graph = Graph()
    private var blankNodeCounter = 0

    /// Creates an OWL Functional-Style Syntax decoder.
    init(text: String) {
        self.lexer = OWLFunctionalSyntaxLexer(text)
    }

    /// Decodes a graph from the complete source.
    mutating func decodeGraph() throws -> Graph {
        try parsePrefixDeclarations()
        try parseOntology()
        lexer.skipWhitespaceAndComments()
        if !lexer.isAtEnd {
            throw lexer.errorUnexpectedCharacter()
        }
        return graph
    }

    private mutating func parsePrefixDeclarations() throws {
        while true {
            lexer.skipWhitespaceAndComments()
            if lexer.consumeWord("Prefix") {
                try parsePrefixDeclaration()
            } else {
                return
            }
        }
    }

    private mutating func parsePrefixDeclaration() throws {
        lexer.skipWhitespaceAndComments()
        try lexer.expect("(")
        lexer.skipWhitespaceAndComments()

        let prefixLabel = try parsePrefixLabel()
        lexer.skipWhitespaceAndComments()
        try lexer.expect(":=")
        lexer.skipWhitespaceAndComments()

        let iri = try parseIri()
        lexer.skipWhitespaceAndComments()
        try lexer.expect(")")

        prefixes[prefixLabel] = iri
    }

    private mutating func parseOntology() throws {
        lexer.skipWhitespaceAndComments()
        guard lexer.consumeWord("Ontology") else {
            throw lexer.errorUnexpectedToken("Ontology")
        }
        lexer.skipWhitespaceAndComments()
        try lexer.expect("(")
        lexer.skipWhitespaceAndComments()

        var ontologyIRI: IRI? = nil
        var versionIRI: IRI? = nil

        if lexer.isStartOfIriRef() {
            ontologyIRI = try parseIri()
            lexer.skipWhitespaceAndComments()
            if lexer.isStartOfIriRef() {
                versionIRI = try parseIri()
                _ = versionIRI
                lexer.skipWhitespaceAndComments()
            }
        }

        if let ontologyIRI {
            try insertTriple(
                subject: AnyRDFSubject(ontologyIRI),
                predicate: RDF.type,
                object: AnyRDFObject(OWL.Ontology.iri)
            )
        }

        while true {
            lexer.skipWhitespaceAndComments()
            if lexer.peek() == ")" {
                _ = lexer.advance()
                return
            }
            let keyword = try parseIdentifier()
            switch keyword {
            case "Import":
                try parseImport(ontologyIRI: ontologyIRI)
            case "Annotation":
                _ = try parseAnnotation()
            case "Declaration":
                try parseDeclaration()
            case "SubClassOf":
                try parseSubClassOf()
            case "EquivalentClasses":
                try parseEquivalentClasses()
            case "DisjointClasses":
                try parseDisjointClasses()
            case "ClassAssertion":
                try parseClassAssertion()
            case "ObjectPropertyAssertion":
                try parseObjectPropertyAssertion()
            case "DataPropertyAssertion":
                try parseDataPropertyAssertion()
            case "AnnotationAssertion":
                try parseAnnotationAssertion()
            default:
                throw lexer.errorUnsupported(keyword)
            }
        }
    }

    private mutating func parseImport(ontologyIRI: IRI?) throws {
        lexer.skipWhitespaceAndComments()
        try lexer.expect("(")
        lexer.skipWhitespaceAndComments()
        let imported = try parseIri()
        lexer.skipWhitespaceAndComments()
        try lexer.expect(")")

        guard let ontologyIRI else { return }
        try insertTriple(
            subject: AnyRDFSubject(ontologyIRI),
            predicate: OWL.imports,
            object: AnyRDFObject(imported)
        )
    }

    private mutating func parseDeclaration() throws {
        lexer.skipWhitespaceAndComments()
        try lexer.expect("(")
        lexer.skipWhitespaceAndComments()

        let entityType = try parseIdentifier()
        lexer.skipWhitespaceAndComments()
        try lexer.expect("(")
        lexer.skipWhitespaceAndComments()
        let entity = try parseIri()
        lexer.skipWhitespaceAndComments()
        try lexer.expect(")")
        lexer.skipWhitespaceAndComments()
        try lexer.expect(")")

        let subject = AnyRDFSubject(entity)
        let object: IRI

        switch entityType {
        case "Class":
            object = OWL.Class.iri
        case "ObjectProperty":
            object = OWL.ObjectProperty.iri
        case "DataProperty":
            object = OWL.DatatypeProperty.iri
        case "AnnotationProperty":
            object = OWL.AnnotationProperty.iri
        case "NamedIndividual":
            object = OWL.NamedIndividual.iri
        case "Datatype":
            object = RDFS.Datatype.iri
        default:
            throw lexer.errorUnsupported(entityType)
        }

        try insertTriple(
            subject: subject,
            predicate: RDF.type,
            object: AnyRDFObject(object)
        )
    }

    private mutating func parseSubClassOf() throws {
        lexer.skipWhitespaceAndComments()
        try lexer.expect("(")
        lexer.skipWhitespaceAndComments()
        let subClass = try parseClassIriOnly()
        lexer.skipWhitespaceAndComments()
        let superClass = try parseClassIriOnly()
        lexer.skipWhitespaceAndComments()
        try lexer.expect(")")

        try insertTriple(
            subject: AnyRDFSubject(subClass),
            predicate: RDFS.subClassOf,
            object: AnyRDFObject(superClass)
        )
    }

    private mutating func parseEquivalentClasses() throws {
        lexer.skipWhitespaceAndComments()
        try lexer.expect("(")
        lexer.skipWhitespaceAndComments()

        var classes: [IRI] = []
        while true {
            classes.append(try parseClassIriOnly())
            lexer.skipWhitespaceAndComments()
            if lexer.peek() == ")" { break }
        }
        try lexer.expect(")")

        guard let first = classes.first else { return }
        for other in classes.dropFirst() {
            try insertTriple(
                subject: AnyRDFSubject(first),
                predicate: OWL.equivalentClass,
                object: AnyRDFObject(other)
            )
        }
    }

    private mutating func parseDisjointClasses() throws {
        lexer.skipWhitespaceAndComments()
        try lexer.expect("(")
        lexer.skipWhitespaceAndComments()

        var classes: [IRI] = []
        while true {
            classes.append(try parseClassIriOnly())
            lexer.skipWhitespaceAndComments()
            if lexer.peek() == ")" { break }
        }
        try lexer.expect(")")

        guard let first = classes.first else { return }
        for other in classes.dropFirst() {
            try insertTriple(
                subject: AnyRDFSubject(first),
                predicate: OWL.disjointWith,
                object: AnyRDFObject(other)
            )
        }
    }

    private mutating func parseClassAssertion() throws {
        lexer.skipWhitespaceAndComments()
        try lexer.expect("(")
        lexer.skipWhitespaceAndComments()
        let classIri = try parseClassIriOnly()
        lexer.skipWhitespaceAndComments()
        let individual = try parseIndividual()
        lexer.skipWhitespaceAndComments()
        try lexer.expect(")")

        try insertTriple(
            subject: individual,
            predicate: RDF.type,
            object: AnyRDFObject(classIri)
        )
    }

    private mutating func parseObjectPropertyAssertion() throws {
        lexer.skipWhitespaceAndComments()
        try lexer.expect("(")
        lexer.skipWhitespaceAndComments()
        let property = try parseIri()
        lexer.skipWhitespaceAndComments()
        let subject = try parseIndividual()
        lexer.skipWhitespaceAndComments()
        let object = try parseIndividualObject()
        lexer.skipWhitespaceAndComments()
        try lexer.expect(")")

        try insertTriple(
            subject: subject,
            predicate: property,
            object: object
        )
    }

    private mutating func parseDataPropertyAssertion() throws {
        lexer.skipWhitespaceAndComments()
        try lexer.expect("(")
        lexer.skipWhitespaceAndComments()
        let property = try parseIri()
        lexer.skipWhitespaceAndComments()
        let subject = try parseIndividual()
        lexer.skipWhitespaceAndComments()
        let literal = try parseLiteral()
        lexer.skipWhitespaceAndComments()
        try lexer.expect(")")

        try insertTriple(
            subject: subject,
            predicate: property,
            object: AnyRDFObject(literal)
        )
    }

    private mutating func parseAnnotationAssertion() throws {
        lexer.skipWhitespaceAndComments()
        try lexer.expect("(")
        lexer.skipWhitespaceAndComments()

        while lexer.consumeWord("Annotation") {
            _ = try parseAnnotation()
            lexer.skipWhitespaceAndComments()
        }

        let property = try parseIri()
        lexer.skipWhitespaceAndComments()
        let subject = try parseAnnotationSubject()
        lexer.skipWhitespaceAndComments()
        let value = try parseAnnotationValue()
        lexer.skipWhitespaceAndComments()
        try lexer.expect(")")

        try insertTriple(
            subject: subject,
            predicate: property,
            object: value
        )
    }

    private mutating func parseAnnotation() throws -> (IRI, AnyRDFObject) {
        lexer.skipWhitespaceAndComments()
        try lexer.expect("(")
        lexer.skipWhitespaceAndComments()
        let property = try parseIri()
        lexer.skipWhitespaceAndComments()
        let value = try parseAnnotationValue()
        lexer.skipWhitespaceAndComments()
        try lexer.expect(")")
        return (property, value)
    }

    private mutating func parseClassIriOnly() throws -> IRI {
        if lexer.isStartOfIriRef() {
            return try parseIri()
        }
        let keyword = try parseIdentifier()
        throw lexer.errorUnsupported(keyword)
    }

    private mutating func parseIndividual() throws -> AnyRDFSubject {
        if lexer.starts(with: "_:") {
            let blank = try parseBlankNode()
            return AnyRDFSubject(blank)
        }
        let iri = try parseIri()
        return AnyRDFSubject(iri)
    }

    private mutating func parseIndividualObject() throws -> AnyRDFObject {
        if lexer.starts(with: "_:") {
            return AnyRDFObject(try parseBlankNode())
        }
        return AnyRDFObject(try parseIri())
    }

    private mutating func parseAnnotationSubject() throws -> AnyRDFSubject {
        if lexer.starts(with: "_:") {
            return try AnyRDFSubject(parseBlankNode())
        }
        return try AnyRDFSubject(parseIri())
    }

    private mutating func parseAnnotationValue() throws -> AnyRDFObject {
        if lexer.peek() == "\"" {
            return AnyRDFObject(try parseLiteral())
        }
        if lexer.starts(with: "_:") {
            return AnyRDFObject(try parseBlankNode())
        }
        return AnyRDFObject(try parseIri())
    }

    private mutating func parseIri() throws -> IRI {
        if lexer.peek() == "<" {
            let value = try parseIriRefString()
            return try resolveIri(value)
        }
        let token = try parsePrefixedName()
        guard let base = prefixes[token.prefix] else {
            throw lexer.errorUndefinedPrefix(token.prefix)
        }
        return try resolveIri(base.string + token.local)
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
                guard let escaped = lexer.advance() else { throw lexer.errorUnexpectedEnd() }
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

    private mutating func parsePrefixedName() throws -> (prefix: String, local: String) {
        var token = ""
        while let ch = lexer.peek(), !ch.isWhitespace, ch != "(", ch != ")" {
            token.append(ch)
            _ = lexer.advance()
        }
        guard let colonIndex = token.firstIndex(of: ":") else {
            throw lexer.errorUnexpectedToken(token)
        }
        let prefix = String(token[..<colonIndex])
        let local = String(token[token.index(after: colonIndex)...])
        return (prefix, local)
    }

    private mutating func parsePrefixLabel() throws -> String {
        var label = ""
        while let ch = lexer.peek() {
            if ch == ":" {
                _ = lexer.advance()
                return label
            }
            if ch.isWhitespace || ch == "(" || ch == ")" {
                break
            }
            label.append(ch)
            _ = lexer.advance()
        }
        throw lexer.errorUnexpectedCharacter()
    }

    private mutating func parseBlankNode() throws -> BlankNode {
        try lexer.expect("_:")
        let label = try parseNameToken()
        return try BlankNode(label)
    }

    private mutating func parseNameToken() throws -> String {
        var token = ""
        while let ch = lexer.peek(), !ch.isWhitespace, ch != "(", ch != ")" {
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
            return try Literal(string, languageTag: lang)
        }
        if lexer.starts(with: "^^") {
            _ = lexer.advance()
            _ = lexer.advance()
            lexer.skipWhitespaceAndComments()
            let datatype = try parseIri()
            return try Literal(string, datatype: datatype)
        }
        return try Literal(string)
    }

    private mutating func parseStringLiteral() throws -> String {
        try lexer.expect("\"")
        var value = ""
        while let ch = lexer.peek() {
            if ch == "\"" {
                _ = lexer.advance()
                return value
            }
            if ch == "\\" {
                _ = lexer.advance()
                guard let escaped = lexer.advance() else { throw lexer.errorUnexpectedEnd() }
                switch escaped {
                case "t": value.append("\t")
                case "b": value.append("\u{0008}")
                case "n": value.append("\n")
                case "r": value.append("\r")
                case "f": value.append("\u{000C}")
                case "\"": value.append("\"")
                case "\\": value.append("\\")
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
        guard let first = lexer.peek(), first.isLetter else {
            throw lexer.errorUnexpectedCharacter()
        }
        while let ch = lexer.peek(), ch.isLetter {
            tag.append(ch)
            _ = lexer.advance()
        }
        while let ch = lexer.peek(), ch == "-" {
            _ = lexer.advance()
            tag.append("-")
            var segment = ""
            while let next = lexer.peek(), next.isLetter || next.isNumber {
                segment.append(next)
                _ = lexer.advance()
            }
            if segment.isEmpty {
                throw lexer.errorUnexpectedCharacter()
            }
            tag.append(segment)
        }
        return tag.lowercased()
    }

    private mutating func parseIdentifier() throws -> String {
        var ident = ""
        guard let first = lexer.peek(), first.isLetter else {
            throw lexer.errorUnexpectedCharacter()
        }
        while let ch = lexer.peek(), ch.isLetter || ch.isNumber || ch == "-" {
            ident.append(ch)
            _ = lexer.advance()
        }
        return ident
    }

    private mutating func insertTriple<Predicate: IRIRepresentable>(subject: AnyRDFSubject, predicate: Predicate, object: AnyRDFObject) throws {
        do {
            try graph.insert(Graph.TripleType(subject: subject, predicate: predicate, object: object))
        } catch RDFGraphError.duplicateTriple {
            return
        }
    }

    private func resolveIri(_ value: String) throws -> IRI {
        IRI(value)
    }
}
