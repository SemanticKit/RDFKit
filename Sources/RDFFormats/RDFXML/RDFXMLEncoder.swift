import IRIKit
import RDFCore

/// Encodes a graph as an RDF 1.2 XML Syntax document.
///
/// Each subject is one `rdf:Description` node element (RDF 1.2 XML Syntax
/// §2.2) named by `rdf:about`, or by `rdf:nodeID` for a blank node (§2.10),
/// with one property element per triple: `rdf:resource` or `rdf:nodeID`
/// for a node object, the text of a literal with its `xml:lang` (§2.7),
/// `its:dir` (§2.8) or `rdf:datatype` (§2.9), and `rdf:parseType="Triple"`
/// for a triple term. A document with a base direction or a triple term
/// announces RDF 1.2 with `rdf:version="1.2"`. Subjects and their triples
/// are written in the graph's order.
///
///     let document = try RDFXMLEncoder().encode(graph)
public struct RDFXMLEncoder: Sendable {
    /// Creates an RDF/XML encoder.
    public init() {}

    /// Encodes a graph as an RDF/XML document.
    ///
    /// - Throws: `EncodingError.invalidValue` for a graph RDF/XML cannot
    ///   write: a predicate that does not end in an XML name or that is one
    ///   of the syntax's own names (§5.1), or text with a character XML 1.0
    ///   does not allow.
    public func encode(_ graph: Graph) throws -> String {
        var document = RDFXMLDocument(graph)
        return try document.write()
    }

    /// Encodes descriptions as an RDF/XML document: the triples each one
    /// states through its `Encodable` conformance (see ``GraphEncoder``).
    ///
    ///     let document = try RDFXMLEncoder().encode([alice, bob])
    public func encode(_ descriptions: [any Description]) throws -> String {
        try encode(try GraphEncoder().encode(descriptions))
    }

    /// Encodes one description as an RDF/XML document.
    public func encode(_ description: some Description) throws -> String {
        try encode(try GraphEncoder().encode(description))
    }
}

/// One RDF/XML document being written: its namespace prefixes and the
/// `rdf:nodeID` of each blank node.
private struct RDFXMLDocument {
    static let rdf = RDFXMLParser.rdf
    static let its = RDFXMLParser.its

    /// The names of the RDF namespace a property element cannot have:
    /// `coreSyntaxTerms`, `rdf:Description`, `rdf:li` and `oldTerms`
    /// (RDF 1.2 XML Syntax §7.2.5, propertyElementURIs).
    static let reservedPredicates: Set<String> = RDFXMLParser.coreSyntaxTerms
        .union(RDFXMLParser.oldTerms)
        .union([rdf + "Description", rdf + "li"])

    let graph: Graph
    private var prefixes: [String: String] = [Self.rdf: "rdf"]
    private var namespaceOrder: [String] = [Self.rdf]
    private var nodeIDs: [BlankNode: String] = [:]
    private var usedNodeIDs: Set<String> = []
    private var nextNodeID = 0
    private var announcesRDF12 = false
    private var usesITS = false

    init(_ graph: Graph) {
        self.graph = graph
        for triple in graph {
            collect(triple)
        }
    }

    /// Notes what the document must declare for one triple.
    private mutating func collect(_ triple: Graph.Element) {
        if let (namespace, _) = Self.split(triple.predicate), prefixes[namespace] == nil {
            prefixes[namespace] = "ns\(namespaceOrder.count)"
            namespaceOrder.append(namespace)
        }
        if case .blankNode(let node) = triple.subject, Self.isNCName(node.identifier) { usedNodeIDs.insert(node.identifier) }
        switch triple.object {
        case .literal(let literal) where literal.baseDirection != nil:
            announcesRDF12 = true
            usesITS = true
        case .tripleTerm(let term):
            announcesRDF12 = true
            collect(term)
        case .blankNode(let node) where Self.isNCName(node.identifier):
            usedNodeIDs.insert(node.identifier)
        default:
            break
        }
    }

    mutating func write() throws -> String {
        var root = "<rdf:RDF"
        for namespace in namespaceOrder {
            root += "\n    xmlns:\(prefixes[namespace]!)=\"\(try Self.attribute(namespace))\""
        }
        if usesITS { root += "\n    xmlns:its=\"\(Self.its)\" its:version=\"2.0\"" }
        if announcesRDF12 { root += "\n    rdf:version=\"1.2\"" }
        root += ">\n"
        var document = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n" + root
        var subjects: [SubjectTerm] = []
        var triples: [SubjectTerm: [Graph.Element]] = [:]
        for triple in graph {
            if triples[triple.subject] == nil { subjects.append(triple.subject) }
            triples[triple.subject, default: []].append(triple)
        }
        for subject in subjects {
            document += try nodeElement(subject, triples[subject] ?? [], indent: "  ")
        }
        return document + "</rdf:RDF>\n"
    }

    /// `nodeElement`: an `rdf:Description` of `subject` with a property
    /// element for each triple.
    private mutating func nodeElement(_ subject: SubjectTerm, _ triples: [Graph.Element], indent: String) throws -> String {
        var text = "\(indent)<rdf:Description \(try nodeAttribute(subject, about: true))>\n"
        for triple in triples {
            text += try propertyElement(triple, indent: indent + "  ")
        }
        return text + "\(indent)</rdf:Description>\n"
    }

    /// `propertyElt`: the triple's predicate as an element, its object as
    /// an attribute, text, or a nested triple.
    private mutating func propertyElement(_ triple: Graph.Element, indent: String) throws -> String {
        guard !Self.reservedPredicates.contains(triple.predicate.rawValue), let (namespace, local) = Self.split(triple.predicate) else {
            throw EncodingError.invalidValue(triple.predicate, EncodingError.Context(
                codingPath: [],
                debugDescription: "RDF/XML writes a predicate as an element name, an XML name that is not one of the syntax's own (RDF 1.2 XML Syntax §5.1): <\(triple.predicate)>"
            ))
        }
        let name = "\(prefixes[namespace]!):\(local)"
        switch triple.object {
        case .iri, .blankNode:
            return "\(indent)<\(name) \(try nodeAttribute(triple.object.subject!, about: false))/>\n"
        case .literal(let literal):
            var attributes = ""
            if let language = literal.languageTag {
                attributes += " xml:lang=\"\(try Self.attribute(language))\""
                if let direction = literal.baseDirection { attributes += " its:dir=\"\(direction.rawValue)\"" }
            } else if let datatype = literal.datatype {
                attributes += " rdf:datatype=\"\(try Self.attribute(datatype.rawValue))\""
            }
            return "\(indent)<\(name)\(attributes)>\(try Self.text(literal.lexicalForm))</\(name)>\n"
        case .tripleTerm(let term):
            var text = "\(indent)<\(name) rdf:parseType=\"Triple\">\n"
            text += try nodeElement(term.subject, [term], indent: indent + "  ")
            return text + "\(indent)</\(name)>\n"
        }
    }

    /// `rdf:about` or `rdf:resource` for an IRI, `rdf:nodeID` for a blank
    /// node.
    private mutating func nodeAttribute(_ node: SubjectTerm, about: Bool) throws -> String {
        switch node {
        case .iri(let iri): return "rdf:\(about ? "about" : "resource")=\"\(try Self.attribute(iri.rawValue))\""
        case .blankNode(let blank): return "rdf:nodeID=\"\(nodeID(blank))\""
        }
    }

    /// The `rdf:nodeID` of a blank node: its identifier when that is an XML
    /// `NCName`, a fresh one otherwise.
    private mutating func nodeID(_ node: BlankNode) -> String {
        if Self.isNCName(node.identifier) { return node.identifier }
        if let id = nodeIDs[node] { return id }
        var id: String
        repeat {
            id = "b\(nextNodeID)"
            nextNodeID += 1
        } while usedNodeIDs.contains(id)
        nodeIDs[node] = id
        return id
    }

    // MARK: - XML

    /// The namespace and local name of an IRI written as an element name:
    /// the longest suffix that is an XML `NCName`.
    static func split(_ iri: IRI) -> (namespace: String, local: String)? {
        let scalars = Array(iri.rawValue.unicodeScalars)
        var start = scalars.endIndex
        while start > scalars.startIndex, isNameCharacter(scalars[start - 1]) { start -= 1 }
        while start < scalars.endIndex, !isNameStartCharacter(scalars[start]) { start += 1 }
        guard start < scalars.endIndex, start > scalars.startIndex else { return nil }
        return (String(String.UnicodeScalarView(scalars[..<start])), String(String.UnicodeScalarView(scalars[start...])))
    }

    /// `NCName`: an XML `Name` without `:` (Namespaces in XML 1.0, §3).
    static func isNCName(_ text: String) -> Bool {
        guard let first = text.unicodeScalars.first, isNameStartCharacter(first) else { return false }
        return text.unicodeScalars.allSatisfy(isNameCharacter)
    }

    /// `NameStartChar` without `:` (XML 1.0, §2.3).
    static func isNameStartCharacter(_ scalar: Unicode.Scalar) -> Bool {
        switch scalar.value {
        case 0x41...0x5A, 0x61...0x7A, 0x5F, 0xC0...0xD6, 0xD8...0xF6, 0xF8...0x2FF, 0x370...0x37D,
             0x37F...0x1FFF, 0x200C...0x200D, 0x2070...0x218F, 0x2C00...0x2FEF, 0x3001...0xD7FF,
             0xF900...0xFDCF, 0xFDF0...0xFFFD, 0x10000...0xEFFFF: true
        default: false
        }
    }

    /// `NameChar` without `:` (XML 1.0, §2.3).
    static func isNameCharacter(_ scalar: Unicode.Scalar) -> Bool {
        switch scalar.value {
        case 0x2D, 0x2E, 0x30...0x39, 0xB7, 0x300...0x36F, 0x203F...0x2040: true
        default: isNameStartCharacter(scalar)
        }
    }

    /// `Char` (XML 1.0, §2.2): the characters an XML document can hold.
    static func isCharacter(_ scalar: Unicode.Scalar) -> Bool {
        switch scalar.value {
        case 0x9, 0xA, 0xD, 0x20...0xD7FF, 0xE000...0xFFFD, 0x10000...0x10FFFF: true
        default: false
        }
    }

    /// Character data, with `&`, `<` and `>` escaped, and the carriage
    /// return as a character reference so that it is not read as a line
    /// end (XML 1.0, §2.11).
    static func text(_ value: String) throws -> String {
        var text = ""
        for scalar in value.unicodeScalars {
            switch scalar {
            case "&": text += "&amp;"
            case "<": text += "&lt;"
            case ">": text += "&gt;"
            case "\r": text += "&#xD;"
            default:
                guard isCharacter(scalar) else { throw unrepresentable(value) }
                text.unicodeScalars.append(scalar)
            }
        }
        return text
    }

    /// An attribute value between double quotes, with white space other
    /// than the space as character references so that attribute-value
    /// normalization (XML 1.0, §3.3.3) keeps it.
    static func attribute(_ value: String) throws -> String {
        var text = ""
        for scalar in value.unicodeScalars {
            switch scalar {
            case "&": text += "&amp;"
            case "<": text += "&lt;"
            case "\"": text += "&quot;"
            case "\t": text += "&#x9;"
            case "\n": text += "&#xA;"
            case "\r": text += "&#xD;"
            default:
                guard isCharacter(scalar) else { throw unrepresentable(value) }
                text.unicodeScalars.append(scalar)
            }
        }
        return text
    }

    static func unrepresentable(_ value: String) -> EncodingError {
        EncodingError.invalidValue(value, EncodingError.Context(
            codingPath: [],
            debugDescription: "XML 1.0 cannot hold every character of this text (XML 1.0, §2.2 Char)."
        ))
    }
}
