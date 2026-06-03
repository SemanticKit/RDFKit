import Foundation

/// Decodes RDF/XML source into RDF graphs.
struct RDFXMLDecoder {
    private let text: String
    private let baseIRI: IRI?
    private var graph = Graph()
    private var blankNodeCounter: Int = 0

    private let rdfNamespace = RDF.namespace.rawValue
    private let itsNamespace = "http://www.w3.org/2005/11/its"

    /// Creates an RDF/XML graph decoder.
    init(text: String, baseIRI: IRI?) {
        self.text = text
        self.baseIRI = baseIRI
    }

    /// Decodes a graph from the complete RDF/XML source.
    mutating func decodeGraph() throws -> Graph {
        let builder = XMLTreeBuilder()
        let data = Data(text.utf8)
        let root = try builder.buildRoot(from: data)

        let rootContext = try elementContext(root, inherited: ElementContext(baseIRI: baseIRI, language: nil, direction: nil))
        if isRdfElement(root, localName: "RDF") {
            for child in root.children {
                if case let .element(element) = child {
                    _ = try parseNodeElement(element, inherited: rootContext)
                } else if case let .text(text) = child, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    throw RDFXMLError.invalidDocument("Unexpected text at document root.")
                }
            }
        } else {
            _ = try parseNodeElement(root, inherited: rootContext)
        }
        return graph
    }

    private struct ElementContext {
        let baseIRI: IRI?
        let language: String?
        let direction: TextDirection?
    }

    private mutating func parseNodeElement(_ element: XMLElement, inherited: ElementContext) throws -> AnyRDFSubject {
        let context = try elementContext(element, inherited: inherited)
        let subject = try parseSubject(from: element, context: context)

        if !isRdfElement(element, localName: "Description") {
            let typeIRI = try elementIRI(element)
            try insertTriple(subject: subject, predicate: RDF.type, object: AnyRDFObject(typeIRI))
        }

        for attr in element.attributes where isPropertyAttribute(attr) {
            let predicate = try attributeIRI(attr)
            if predicate == RDF.type {
                let iri = try resolveIriReference(attr.value, base: context.baseIRI)
                try insertTriple(subject: subject, predicate: predicate, object: AnyRDFObject(iri))
            } else {
                let literal = try makeLiteral(
                    value: attr.value,
                    language: context.language,
                    direction: context.direction
                )
                try insertTriple(subject: subject, predicate: predicate, object: AnyRDFObject(literal))
            }
        }

        var liCounter = 1
        for child in element.children {
            switch child {
            case let .element(propertyElement):
                try parsePropertyElement(propertyElement, subject: subject, inherited: context, liCounter: &liCounter)
            case let .text(text):
                if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    throw RDFXMLError.invalidElement("Unexpected text in node element.")
                }
            }
        }

        return subject
    }

    private mutating func parsePropertyElement(_ element: XMLElement, subject: AnyRDFSubject, inherited: ElementContext, liCounter: inout Int) throws {
        let context = try elementContext(element, inherited: inherited)
        let predicate = try predicateIRI(for: element, liCounter: &liCounter)
        let parseType = attributeValue(element, namespace: rdfNamespace, localName: "parseType")
        let resourceAttr = attributeValue(element, namespace: rdfNamespace, localName: "resource")
        let nodeIdAttr = attributeValue(element, namespace: rdfNamespace, localName: "nodeID")
        let datatypeAttr = attributeValue(element, namespace: rdfNamespace, localName: "datatype")
        let idAttr = attributeValue(element, namespace: rdfNamespace, localName: "ID")
        let annotationAttr = attributeValue(element, namespace: rdfNamespace, localName: "annotation")
        let annotationNodeIDAttr = attributeValue(element, namespace: rdfNamespace, localName: "annotationNodeID")

        let propertyAttributes = element.attributes.filter { isPropertyAttribute($0) }
        let childElements = element.children.compactMap { child -> XMLElement? in
            if case let .element(element) = child { return element }
            return nil
        }
        let textContent = element.children.compactMap { child -> String? in
            if case let .text(text) = child { return text }
            return nil
        }.joined()
        let hasSignificantText = !textContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        if let parseType {
            switch parseType {
            case "Literal":
                let xmlLiteral = serializeChildren(element.children)
                let object = try Literal(xmlLiteral, datatype: RDF.XMLLiteral.iri)
                let statement = try emitStatement(subject: subject, predicate: predicate, object: AnyRDFObject(object), idAttr: idAttr, annotationAttr: annotationAttr, annotationNodeIDAttr: annotationNodeIDAttr, context: context)
                _ = statement
                return
            case "Resource":
                let blank = try newBlankNode()
                _ = try emitStatement(subject: subject, predicate: predicate, object: AnyRDFObject(blank), idAttr: idAttr, annotationAttr: annotationAttr, annotationNodeIDAttr: annotationNodeIDAttr, context: context)
                var childLiCounter = 1
                for child in childElements {
                    try parsePropertyElement(child, subject: AnyRDFSubject(blank), inherited: context, liCounter: &childLiCounter)
                }
                return
            case "Collection":
                let objects = try childElements.map { child -> AnyRDFObject in
                    let node = try parseNodeElement(child, inherited: context)
                    return try asObject(node)
                }
                try buildCollection(objects, subject: subject, predicate: predicate, idAttr: idAttr, annotationAttr: annotationAttr, annotationNodeIDAttr: annotationNodeIDAttr, context: context)
                return
            case "Triple":
                let tripleTerm = try parseTripleTermContent(element, inherited: context)
                _ = try emitStatement(subject: subject, predicate: predicate, object: AnyRDFObject(tripleTerm), idAttr: idAttr, annotationAttr: annotationAttr, annotationNodeIDAttr: annotationNodeIDAttr, context: context)
                return
            default:
                let xmlLiteral = serializeChildren(element.children)
                let object = try Literal(xmlLiteral, datatype: RDF.XMLLiteral.iri)
                _ = try emitStatement(subject: subject, predicate: predicate, object: AnyRDFObject(object), idAttr: idAttr, annotationAttr: annotationAttr, annotationNodeIDAttr: annotationNodeIDAttr, context: context)
                return
            }
        }

        if !childElements.isEmpty {
            guard childElements.count == 1 else {
                throw RDFXMLError.invalidElement("Property element must contain a single node element.")
            }
            let node = try parseNodeElement(childElements[0], inherited: context)
            _ = try emitStatement(subject: subject, predicate: predicate, object: try asObject(node), idAttr: idAttr, annotationAttr: annotationAttr, annotationNodeIDAttr: annotationNodeIDAttr, context: context)
            return
        }

        if hasSignificantText || datatypeAttr != nil {
            let literalValue = textContent
            let object: Literal
            if let datatypeValue = datatypeAttr {
                let datatypeIRI = try resolveIriReference(datatypeValue, base: context.baseIRI)
                object = try Literal(literalValue, datatype: datatypeIRI)
            } else {
                object = try makeLiteral(value: literalValue, language: context.language, direction: context.direction)
            }
            _ = try emitStatement(subject: subject, predicate: predicate, object: AnyRDFObject(object), idAttr: idAttr, annotationAttr: annotationAttr, annotationNodeIDAttr: annotationNodeIDAttr, context: context)
            return
        }

        if resourceAttr == nil && nodeIdAttr == nil && datatypeAttr == nil && propertyAttributes.isEmpty {
            let object = try makeLiteral(value: "", language: context.language, direction: context.direction)
            _ = try emitStatement(subject: subject, predicate: predicate, object: AnyRDFObject(object), idAttr: idAttr, annotationAttr: annotationAttr, annotationNodeIDAttr: annotationNodeIDAttr, context: context)
            return
        }

        if let datatypeValue = datatypeAttr, resourceAttr == nil, nodeIdAttr == nil, propertyAttributes.isEmpty {
            let datatypeIRI = try resolveIriReference(datatypeValue, base: context.baseIRI)
            let object = try Literal("", datatype: datatypeIRI)
            _ = try emitStatement(subject: subject, predicate: predicate, object: AnyRDFObject(object), idAttr: idAttr, annotationAttr: annotationAttr, annotationNodeIDAttr: annotationNodeIDAttr, context: context)
            return
        }

        let resourceNode: AnyRDFObject
        if let resourceValue = resourceAttr {
            let iri = try resolveIriReference(resourceValue, base: context.baseIRI)
            resourceNode = AnyRDFObject(iri)
        } else if let nodeIdValue = nodeIdAttr {
            let blank = try BlankNode(nodeIdValue)
            resourceNode = AnyRDFObject(blank)
        } else {
            let blank = try newBlankNode()
            resourceNode = AnyRDFObject(blank)
        }

        if let blank = resourceNode.node as? BlankNode {
            for attr in propertyAttributes {
                let predicateIRI = try attributeIRI(attr)
                if predicateIRI == RDF.type {
                    let typeIRI = try resolveIriReference(attr.value, base: context.baseIRI)
                    try insertTriple(subject: AnyRDFSubject(blank), predicate: predicateIRI, object: AnyRDFObject(typeIRI))
                } else {
                    let literal = try makeLiteral(value: attr.value, language: context.language, direction: context.direction)
                    try insertTriple(subject: AnyRDFSubject(blank), predicate: predicateIRI, object: AnyRDFObject(literal))
                }
            }
        } else if let iri = resourceNode.node as? IRI {
            for attr in propertyAttributes {
                let predicateIRI = try attributeIRI(attr)
                if predicateIRI == RDF.type {
                    let typeIRI = try resolveIriReference(attr.value, base: context.baseIRI)
                    try insertTriple(subject: AnyRDFSubject(iri), predicate: predicateIRI, object: AnyRDFObject(typeIRI))
                } else {
                    let literal = try makeLiteral(value: attr.value, language: context.language, direction: context.direction)
                    try insertTriple(subject: AnyRDFSubject(iri), predicate: predicateIRI, object: AnyRDFObject(literal))
                }
            }
        }

        _ = try emitStatement(subject: subject, predicate: predicate, object: resourceNode, idAttr: idAttr, annotationAttr: annotationAttr, annotationNodeIDAttr: annotationNodeIDAttr, context: context)
    }

    private mutating func parseTripleTermContent(_ element: XMLElement, inherited: ElementContext) throws -> TripleTerm {
        var tempDecoder = RDFXMLDecoder(text: "", baseIRI: inherited.baseIRI)
        tempDecoder.blankNodeCounter = blankNodeCounter
        let childElements = element.children.compactMap { child -> XMLElement? in
            if case let .element(element) = child { return element }
            return nil
        }
        let hasText = element.children.contains { child in
            if case let .text(text) = child {
                return !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            return false
        }
        if hasText {
            throw RDFXMLError.invalidTripleTerm("parseType=\"Triple\" cannot contain text content.")
        }

        if childElements.count == 1 {
            _ = try tempDecoder.parseNodeElement(childElements[0], inherited: inherited)
        } else {
            let blank = try tempDecoder.newBlankNode()
            var liCounter = 1
            for child in childElements {
                try tempDecoder.parsePropertyElement(child, subject: AnyRDFSubject(blank), inherited: inherited, liCounter: &liCounter)
            }
        }

        let triples = tempDecoder.graph.triples
        guard triples.count == 1, let triple = triples.first else {
            throw RDFXMLError.invalidTripleTerm("parseType=\"Triple\" must produce exactly one triple.")
        }
        blankNodeCounter = tempDecoder.blankNodeCounter
        return TripleTerm(subject: triple.subject, predicate: triple.predicate, object: triple.object)
    }

    private mutating func buildCollection(_ objects: [AnyRDFObject], subject: AnyRDFSubject, predicate: IRI, idAttr: String?, annotationAttr: String?, annotationNodeIDAttr: String?, context: ElementContext) throws {
        if objects.isEmpty {
            _ = try emitStatement(subject: subject, predicate: predicate, object: AnyRDFObject(RDF.nilValue), idAttr: idAttr, annotationAttr: annotationAttr, annotationNodeIDAttr: annotationNodeIDAttr, context: context)
            return
        }

        var blanks: [BlankNode] = []
        for _ in objects {
            blanks.append(try newBlankNode())
        }

        _ = try emitStatement(subject: subject, predicate: predicate, object: AnyRDFObject(blanks[0]), idAttr: idAttr, annotationAttr: annotationAttr, annotationNodeIDAttr: annotationNodeIDAttr, context: context)

        for (index, item) in objects.enumerated() {
            let current = blanks[index]
            try insertTriple(
                subject: AnyRDFSubject(current),
                predicate: RDF.first,
                object: item
            )
            let restObject: AnyRDFObject
            if index == blanks.count - 1 {
                restObject = AnyRDFObject(RDF.nilValue)
            } else {
                restObject = AnyRDFObject(blanks[index + 1])
            }
            try insertTriple(
                subject: AnyRDFSubject(current),
                predicate: RDF.rest,
                object: restObject
            )
        }
    }

    private mutating func emitStatement(subject: AnyRDFSubject, predicate: IRI, object: AnyRDFObject, idAttr: String?, annotationAttr: String?, annotationNodeIDAttr: String?, context: ElementContext) throws -> Graph.TripleType {
        let statement = Graph.TripleType(subject: subject, predicate: predicate, object: object)
        try insertTriple(statement)

        if let idValue = idAttr {
            let reifierIRI = try resolveIriReference("#" + idValue, base: context.baseIRI)
            try reify(statement: statement, reifier: reifierIRI)
        }
        if let annotationValue = annotationAttr {
            let reifierIRI = try resolveIriReference(annotationValue, base: context.baseIRI)
            try annotate(statement: statement, reifier: AnyRDFSubject(reifierIRI))
        } else if let annotationNodeID = annotationNodeIDAttr {
            let blank = try BlankNode(annotationNodeID)
            try annotate(statement: statement, reifier: AnyRDFSubject(blank))
        }

        return statement
    }

    private mutating func reify(statement: Graph.TripleType, reifier: IRI) throws {
        let reifierSubject = AnyRDFSubject(reifier)
        try insertTriple(subject: reifierSubject, predicate: RDF.subject, object: try asObject(statement.subject))
        try insertTriple(subject: reifierSubject, predicate: RDF.predicate, object: AnyRDFObject(statement.predicate))
        try insertTriple(subject: reifierSubject, predicate: RDF.object, object: statement.object)
        try insertTriple(subject: reifierSubject, predicate: RDF.type, object: AnyRDFObject(RDF.Statement.iri))
    }

    private mutating func annotate(statement: Graph.TripleType, reifier: AnyRDFSubject) throws {
        let tripleTerm = TripleTerm(subject: statement.subject, predicate: statement.predicate, object: statement.object)
        try insertTriple(subject: reifier, predicate: RDF.reifies, object: AnyRDFObject(tripleTerm))
    }

    private mutating func insertTriple(_ triple: Graph.TripleType) throws {
        do {
            try graph.insert(triple)
        } catch RDFGraphError.duplicateTriple {
            return
        }
    }

    private mutating func insertTriple<Predicate: IRIRepresentable>(subject: AnyRDFSubject, predicate: Predicate, object: AnyRDFObject) throws {
        try insertTriple(Graph.TripleType(subject: subject, predicate: predicate, object: object))
    }

    private mutating func newBlankNode() throws -> BlankNode {
        blankNodeCounter += 1
        return try BlankNode("genid\(blankNodeCounter)")
    }

    private mutating func parseSubject(from element: XMLElement, context: ElementContext) throws -> AnyRDFSubject {
        let about = attributeValue(element, namespace: rdfNamespace, localName: "about")
        let nodeID = attributeValue(element, namespace: rdfNamespace, localName: "nodeID")
        let id = attributeValue(element, namespace: rdfNamespace, localName: "ID")

        let provided = [about, nodeID, id].compactMap { $0 }
        if provided.count > 1 {
            throw RDFXMLError.invalidAttribute("rdf:about, rdf:nodeID, and rdf:ID are mutually exclusive.")
        }

        if let about {
            let iri = try resolveIriReference(about, base: context.baseIRI)
            return AnyRDFSubject(iri)
        }
        if let nodeID {
            return try AnyRDFSubject(BlankNode(nodeID))
        }
        if let id {
            let iri = try resolveIriReference("#" + id, base: context.baseIRI)
            return AnyRDFSubject(iri)
        }
        return try AnyRDFSubject(newBlankNode())
    }

    private func predicateIRI(for element: XMLElement, liCounter: inout Int) throws -> IRI {
        if isRdfElement(element, localName: "li") {
            let iri = try RDF.containerMembershipProperty(liCounter)
            liCounter += 1
            return iri
        }
        return try elementIRI(element)
    }

    private func elementIRI(_ element: XMLElement) throws -> IRI {
        guard let namespace = element.namespaceURI else {
            throw RDFXMLError.invalidElement("Missing namespace for element \(element.localName).")
        }
        return IRI(namespace + element.localName)
    }

    private func attributeIRI(_ attribute: XMLAttribute) throws -> IRI {
        guard let namespace = attribute.namespaceURI else {
            throw RDFXMLError.invalidAttribute("Missing namespace for attribute \(attribute.localName).")
        }
        return IRI(namespace + attribute.localName)
    }

    private func resolveIriReference(_ value: String, base: IRI?) throws -> IRI {
        if let base, let baseURL = URL(string: base.string) {
            if let resolved = URL(string: value, relativeTo: baseURL)?.absoluteString {
                return IRI(resolved)
            }
        }
        return IRI(value)
    }

    private func resolveBase(_ value: String?, inherited: IRI?) throws -> IRI? {
        guard let value else { return inherited }
        if let inherited, let baseURL = URL(string: inherited.string), let resolved = URL(string: value, relativeTo: baseURL)?.absoluteString {
            return IRI(resolved)
        }
        return IRI(value)
    }

    private func elementContext(_ element: XMLElement, inherited: ElementContext) throws -> ElementContext {
        let baseValue = attributeValue(element, namespace: "http://www.w3.org/XML/1998/namespace", localName: "base")
        let baseIRI = try resolveBase(baseValue, inherited: inherited.baseIRI)
        let languageValue = attributeValue(element, namespace: "http://www.w3.org/XML/1998/namespace", localName: "lang")
        let language = languageValue?.isEmpty == true ? nil : languageValue ?? inherited.language
        let directionValue = attributeValue(element, namespace: itsNamespace, localName: "dir")
        let direction = directionValue.flatMap { TextDirection(rawValue: $0.lowercased()) } ?? inherited.direction
        return ElementContext(baseIRI: baseIRI, language: language, direction: direction)
    }

    private func attributeValue(_ element: XMLElement, namespace: String?, localName: String) -> String? {
        element.attributes.first { $0.namespaceURI == namespace && $0.localName == localName }?.value
    }

    private func isRdfElement(_ element: XMLElement, localName: String) -> Bool {
        element.namespaceURI == rdfNamespace && element.localName == localName
    }

    private func isPropertyAttribute(_ attribute: XMLAttribute) -> Bool {
        if attribute.prefix == "xmlns" || attribute.localName == "xmlns" { return false }
        if attribute.namespaceURI == "http://www.w3.org/XML/1998/namespace" { return false }
        if attribute.namespaceURI == itsNamespace { return false }
        if attribute.namespaceURI == rdfNamespace {
            return attribute.localName == "type"
        }
        return true
    }

    private func makeLiteral(value: String, language: String?, direction: TextDirection?) throws -> Literal {
        if let language {
            return try Literal(value, languageTag: language, textDirection: direction)
        }
        return try Literal(value)
    }

    private func asObject(_ subject: AnyRDFSubject) throws -> AnyRDFObject {
        if let iri = subject.node as? IRI {
            return AnyRDFObject(iri)
        }
        if let blank = subject.node as? BlankNode {
            return AnyRDFObject(blank)
        }
        throw RDFXMLError.invalidElement("Subject cannot be used as object.")
    }

    private func serializeChildren(_ children: [XMLChild]) -> String {
        children.map { child in
            switch child {
            case let .text(text):
                return escapeText(text)
            case let .element(element):
                return serializeElement(element)
            }
        }.joined()
    }

    private func serializeElement(_ element: XMLElement) -> String {
        let name = element.prefix.map { "\($0):\(element.localName)" } ?? element.localName
        let attributes = element.attributes.map { attr -> String in
            let attrName = attr.prefix.map { "\($0):\(attr.localName)" } ?? attr.localName
            return "\(attrName)=\"\(escapeAttribute(attr.value))\""
        }.joined(separator: " ")
        let attributeString = attributes.isEmpty ? "" : " " + attributes
        let content = serializeChildren(element.children)
        if content.isEmpty {
            return "<\(name)\(attributeString)/>"
        }
        return "<\(name)\(attributeString)>\(content)</\(name)>"
    }

    private func escapeText(_ text: String) -> String {
        text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }

    private func escapeAttribute(_ text: String) -> String {
        text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "<", with: "&lt;")
    }
}
