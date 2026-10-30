import IRIKit
import RDFCore

/// The RDF 1.2 XML Syntax grammar productions over the events of one document's
/// XML Information Set (Syntax Data Model), with each production's triple-emitting actions.
struct RDFXMLParser {
    /// The RDF namespace IRI (The RDF Namespace and Vocabulary), against which the syntax names of the
    /// grammar are matched.
    static let rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    /// The ITS namespace of `its:dir` and `its:version` (Base Direction: its:dir).
    static let its = "http://www.w3.org/2005/11/its"

    /// Production coreSyntaxTerms, as the grammar summary lists it.
    static let coreSyntaxTerms: Set<String> = [
        "RDF", "ID", "about", "annotation", "annotationNodeID", "parseType",
        "resource", "nodeID", "datatype", "version",
    ].reduce(into: []) { $0.insert(rdf + $1) }
    /// Production oldTerms.
    static let oldTerms: Set<String> = ["aboutEach", "aboutEachPrefix", "bagID"].reduce(into: []) { $0.insert(rdf + $1) }
    /// Unqualified attribute names that the Attribute Event maps into the RDF namespace.
    static let unqualifiedAttributes: Set<String> = ["ID", "about", "parseType", "resource", "type", "version"]

    /// The accessors an element event inherits from its parent (Element Event).
    struct Scope {
        var base: String?
        var language = ""
        var direction = ""
        var version: String?

        /// Whether `rdf:version` announces RDF 1.2 features: `"1.2-basic"`,
        /// `"1.2"` or greater (Element Event, attributes).
        var announcesRDF12: Bool {
            guard let version else { return false }
            let number = version.prefix { $0 != "-" }.split(separator: ".", omittingEmptySubsequences: false)
            guard number.count == 2, let major = Int(number[0]), let minor = Int(number[1]) else { return false }
            return (major, minor) >= (1, 2)
        }
    }

    /// An attribute event: its IRI and string-value.
    struct AttributeEvent {
        var iri: String
        var value: String
    }

    /// The attributes of an element event, by the roles the grammar gives
    /// them.
    struct Attributes {
        var id: String?
        var nodeID: String?
        var about: String?
        var resource: String?
        var datatype: String?
        var parseType: String?
        var annotation: String?
        var annotationNodeID: String?
        var properties: [AttributeEvent] = []

        var hasNodeOrLiteralAttribute: Bool {
            nodeID != nil || resource != nil || datatype != nil || !properties.isEmpty
        }
    }

    let infoset: XMLInfoset
    let documentBase: String?
    var blankNodes = BlankNodeLabels()
    var triples: Graph = []
    /// The IRIs `rdf:ID` attributes have produced (constraint-id).
    var identifiers: Set<IRI> = []

    init(_ document: String, base: String?) throws {
        infoset = try XMLInfoset(document)
        documentBase = base
    }

    // MARK: - Productions

    /// Grammar start: production doc, or nodeElement for a document
    /// whose element is not `rdf:RDF`.
    mutating func parseDocument() throws -> Graph {
        let root = infoset.documentElement
        let scope = Scope(base: documentBase)
        if try iri(of: root) == Self.rdf + "RDF" {
            try parseRDF(root, scope)
        } else {
            _ = try parseNodeElement(root, scope)
        }
        return triples
    }

    /// Production RDF: `rdf:RDF` with no attributes, holding a nodeElementList.
    mutating func parseRDF(_ element: XMLInfoset.Element, _ parent: Scope) throws {
        let (scope, events) = try elementEvent(element, parent)
        if let attribute = events.first {
            throw error("rdf:RDF does not take the attribute <\(attribute.iri)>", at: element)
        }
        _ = try parseNodeElementList(element, scope)
    }

    /// Production nodeElementList: the node elements, between white space.
    mutating func parseNodeElementList(_ element: XMLInfoset.Element, _ scope: Scope) throws -> [SubjectTerm] {
        var subjects: [SubjectTerm] = []
        for child in try elementChildren(of: element) {
            subjects.append(try parseNodeElement(child, scope))
        }
        return subjects
    }

    /// Production nodeElement.
    mutating func parseNodeElement(_ element: XMLInfoset.Element, _ parent: Scope) throws -> SubjectTerm {
        let elementIRI = try iri(of: element)
        guard !Self.coreSyntaxTerms.contains(elementIRI), elementIRI != Self.rdf + "li", !Self.oldTerms.contains(elementIRI) else {
            throw error("<\(elementIRI)> cannot be a node element", at: element)
        }
        let (scope, events) = try elementEvent(element, parent)
        let attributes = try roles(of: events, at: element)
        guard attributes.resource == nil, attributes.datatype == nil, attributes.parseType == nil,
              attributes.annotation == nil, attributes.annotationNodeID == nil else {
            throw error("a node element takes only rdf:ID, rdf:nodeID or rdf:about, and property attributes", at: element)
        }
        guard [attributes.id, attributes.nodeID, attributes.about].compactMap({ $0 }).count <= 1 else {
            throw error("a node element takes at most one of rdf:ID, rdf:nodeID and rdf:about", at: element)
        }

        let subject: SubjectTerm
        if let id = attributes.id {
            subject = .iri(try identifier(id, scope, at: element))
        } else if let nodeID = attributes.nodeID {
            subject = .blankNode(try blankNode(nodeID, at: element))
        } else if let about = attributes.about {
            subject = .iri(try resolve(about, scope, at: element))
        } else {
            subject = .blankNode(try blankNodes.fresh())
        }

        if elementIRI != Self.rdf + "Description" {
            emit(subject, Self.typeIRI, .iri(try makeIRI(elementIRI, at: element)))
        }
        try emitPropertyAttributes(attributes.properties, of: subject, scope, at: element)

        var liCounter = 1
        for child in try elementChildren(of: element) {
            try parsePropertyElement(child, of: subject, scope, liCounter: &liCounter)
        }
        return subject
    }

    /// Production propertyElt and the productions it chooses between.
    mutating func parsePropertyElement(
        _ element: XMLInfoset.Element,
        of subject: SubjectTerm,
        _ parent: Scope,
        liCounter: inout Int
    ) throws {
        var elementIRI = try iri(of: element)
        guard !Self.coreSyntaxTerms.contains(elementIRI), elementIRI != Self.rdf + "Description", !Self.oldTerms.contains(elementIRI) else {
            throw error("<\(elementIRI)> cannot be a property element", at: element)
        }
        // List Expansion Rules, applied before the sub-productions.
        if elementIRI == Self.rdf + "li" {
            elementIRI = Self.rdf + "_" + String(liCounter)
            liCounter += 1
        }
        let predicate = try makeIRI(elementIRI, at: element)
        let (scope, events) = try elementEvent(element, parent)
        let attributes = try roles(of: events, at: element)
        guard attributes.about == nil else {
            throw error("rdf:about is not allowed on a property element", at: element)
        }
        guard attributes.annotation == nil || attributes.annotationNodeID == nil else {
            throw error("a property element takes rdf:annotation or rdf:annotationNodeID, not both", at: element)
        }

        if let parseType = attributes.parseType {
            guard !attributes.hasNodeOrLiteralAttribute else {
                throw error("rdf:parseType does not combine with rdf:nodeID, rdf:resource, rdf:datatype or property attributes", at: element)
            }
            switch parseType {
            case "Resource":
                try parseTypeResource(element, subject, predicate, attributes, scope)
            case "Collection":
                try parseTypeCollection(element, subject, predicate, attributes, scope)
            case "Triple":
                try parseTypeTriple(element, subject, predicate, attributes, scope)
            default:
                // Production parseTypeOtherPropertyElt: every other value is treated as "Literal".
                let literal = try makeLiteral(
                    ExclusiveCanonicalXML.serialize(element.children),
                    datatype: Self.xmlLiteralIRI,
                    at: element
                )
                try emitStatement(subject, predicate, .literal(literal), attributes, scope, at: element)
            }
            return
        }

        let children = try contentElements(of: element)
        if let node = children.first {
            // Production resourcePropertyElt.
            guard children.count == 1 else {
                throw error("a property element holds at most one node element", at: element)
            }
            guard !attributes.hasNodeOrLiteralAttribute else {
                throw error("a property element with a node element takes only rdf:ID and an annotation", at: element)
            }
            let object = try parseNodeElement(node, scope)
            try emitStatement(subject, predicate, object.object, attributes, scope, at: element)
            return
        }

        let text = element.children.reduce(into: "") { text, item in
            if case .text(let characters) = item { text += characters }
        }
        if !text.isEmpty || (attributes.datatype != nil && attributes.resource == nil && attributes.nodeID == nil && attributes.properties.isEmpty) {
            // Production literalPropertyElt, with the empty text of an empty
            // element that names a datatype.
            guard attributes.resource == nil, attributes.nodeID == nil, attributes.properties.isEmpty else {
                throw error("a property element with text takes only rdf:ID, rdf:datatype and an annotation", at: element)
            }
            let literal: Literal
            if let datatype = attributes.datatype {
                literal = try makeLiteral(text, datatype: resolve(datatype, scope, at: element), at: element)
            } else {
                literal = try plainLiteral(text, scope, at: element)
            }
            try emitStatement(subject, predicate, .literal(literal), attributes, scope, at: element)
            return
        }

        // Production emptyPropertyElt.
        guard attributes.datatype == nil else {
            throw error("rdf:datatype does not combine with rdf:resource, rdf:nodeID or property attributes", at: element)
        }
        guard attributes.resource == nil || attributes.nodeID == nil else {
            throw error("a property element takes rdf:resource or rdf:nodeID, not both", at: element)
        }
        if attributes.resource == nil, attributes.nodeID == nil, attributes.properties.isEmpty {
            try emitStatement(subject, predicate, .literal(try plainLiteral("", scope, at: element)), attributes, scope, at: element)
            return
        }
        let object: SubjectTerm
        if let resource = attributes.resource {
            object = .iri(try resolve(resource, scope, at: element))
        } else if let nodeID = attributes.nodeID {
            object = .blankNode(try blankNode(nodeID, at: element))
        } else {
            object = .blankNode(try blankNodes.fresh())
        }
        try emitPropertyAttributes(attributes.properties, of: object, scope, at: element)
        try emitStatement(subject, predicate, object.object, attributes, scope, at: element)
    }

    /// Production parseTypeResourcePropertyElt.
    mutating func parseTypeResource(
        _ element: XMLInfoset.Element,
        _ subject: SubjectTerm,
        _ predicate: IRI,
        _ attributes: Attributes,
        _ scope: Scope
    ) throws {
        let node = SubjectTerm.blankNode(try blankNodes.fresh())
        try emitStatement(subject, predicate, node.object, attributes, scope, at: element)
        // The content is the propertyEltList of an rdf:Description whose
        // subject is the new blank node and that has no attributes.
        var liCounter = 1
        for child in try elementChildren(of: element) {
            try parsePropertyElement(child, of: node, scope, liCounter: &liCounter)
        }
    }

    /// Production parseTypeCollectionPropertyElt.
    mutating func parseTypeCollection(
        _ element: XMLInfoset.Element,
        _ subject: SubjectTerm,
        _ predicate: IRI,
        _ attributes: Attributes,
        _ scope: Scope
    ) throws {
        let members = try parseNodeElementList(element, scope)
        let cells = try members.map { _ in SubjectTerm.blankNode(try blankNodes.fresh()) }
        try emitStatement(subject, predicate, cells.first?.object ?? .iri(Self.nilIRI), attributes, scope, at: element)
        for (index, cell) in cells.enumerated() {
            emit(cell, IRI.rdfFirst, members[index].object)
            emit(cell, IRI.rdfRest, index + 1 < cells.count ? cells[index + 1].object : .iri(Self.nilIRI))
        }
    }

    /// Production parseTypeTriplePropertyElt: the content describes the one
    /// triple of a new graph, and the object is that triple as a triple term.
    mutating func parseTypeTriple(
        _ element: XMLInfoset.Element,
        _ subject: SubjectTerm,
        _ predicate: IRI,
        _ attributes: Attributes,
        _ scope: Scope
    ) throws {
        guard attributes.id == nil, attributes.annotation == nil, attributes.annotationNodeID == nil else {
            throw error("rdf:parseType=\"Triple\" takes no other attributes", at: element)
        }
        let nodes = try contentElements(of: element)
        guard nodes.count == 1 else {
            throw error("rdf:parseType=\"Triple\" holds one node element", at: element)
        }
        let outer = triples
        triples = []
        _ = try parseNodeElement(nodes[0], scope)
        let graph = Set(triples)
        triples = outer
        guard graph.count == 1, let triple = graph.first else {
            throw error("rdf:parseType=\"Triple\" must describe exactly one triple, not \(graph.count)", at: element)
        }
        // A document that does not announce RDF 1.2 with rdf:version does
        // not produce triple terms.
        guard scope.announcesRDF12 else { return }
        let term = Graph.Element(subject: triple.subject, predicate: triple.predicate, object: triple.object)
        emit(subject, predicate, .tripleTerm(term))
    }

    // MARK: - Element events

    /// The element event's accessors (Element Event): its inherited scope with the
    /// element's `xml:lang`, `xml:base`, `rdf:version` and `its:dir`
    /// applied, and its remaining attribute events.
    func elementEvent(_ element: XMLInfoset.Element, _ parent: Scope) throws -> (Scope, [AttributeEvent]) {
        var scope = parent
        var events: [AttributeEvent] = []
        var direction: String?
        for attribute in element.attributes {
            if attribute.namespaceName == XMLInfoset.xmlNamespace {
                switch attribute.localName {
                case "lang":
                    scope.language = attribute.normalizedValue
                case "base":
                    scope.base = try resolveBase(attribute.normalizedValue, against: parent.base, at: element)
                default:
                    break
                }
                continue
            }
            if attribute.namespaceName == Self.its {
                if attribute.localName == "dir" { direction = attribute.normalizedValue }
                continue
            }
            // Element Event: the remaining reserved XML Names are removed.
            if (attribute.prefix ?? attribute.localName).lowercased().hasPrefix("xml") {
                continue
            }
            let iri: String
            if let namespace = attribute.namespaceName {
                try checkNamespace(namespace, at: element)
                iri = namespace + attribute.localName
            } else if Self.unqualifiedAttributes.contains(attribute.localName) {
                iri = Self.rdf + attribute.localName
            } else {
                throw error("the unqualified attribute '\(attribute.localName)' is not allowed", at: element)
            }
            if events.contains(where: { $0.iri == iri }) {
                throw error("two attributes name <\(iri)>", at: element)
            }
            if iri == Self.rdf + "version" {
                scope.version = attribute.normalizedValue
            } else {
                events.append(AttributeEvent(iri: iri, value: attribute.normalizedValue))
            }
        }
        if let direction, scope.announcesRDF12 {
            guard ["ltr", "rtl", ""].contains(direction) else {
                throw error("its:dir must be \"ltr\", \"rtl\" or empty, not \"\(direction)\"", at: element)
            }
            scope.direction = direction
        }
        return (scope, events)
    }

    /// Sorts attribute events into the roles of the grammar's attribute
    /// productions (idAttr to parseOther).
    func roles(of events: [AttributeEvent], at element: XMLInfoset.Element) throws -> Attributes {
        var attributes = Attributes()
        for event in events {
            switch event.iri {
            case Self.rdf + "ID": attributes.id = event.value
            case Self.rdf + "nodeID": attributes.nodeID = event.value
            case Self.rdf + "about": attributes.about = event.value
            case Self.rdf + "resource": attributes.resource = event.value
            case Self.rdf + "datatype": attributes.datatype = event.value
            case Self.rdf + "parseType": attributes.parseType = event.value
            case Self.rdf + "annotation": attributes.annotation = event.value
            case Self.rdf + "annotationNodeID": attributes.annotationNodeID = event.value
            default:
                // Production propertyAttributeIRIs.
                guard !Self.coreSyntaxTerms.contains(event.iri), event.iri != Self.rdf + "Description",
                      event.iri != Self.rdf + "li", !Self.oldTerms.contains(event.iri) else {
                    throw error("<\(event.iri)> cannot be a property attribute", at: element)
                }
                attributes.properties.append(event)
            }
        }
        return attributes
    }

    /// The element children of an element whose content is a
    /// nodeElementList or propertyEltList: white space between elements,
    /// and nothing else. Elements with reserved XML Names have no events
    /// (Syntax Data Model).
    func elementChildren(of element: XMLInfoset.Element) throws -> [XMLInfoset.Element] {
        var children: [XMLInfoset.Element] = []
        for item in element.children {
            switch item {
            case .element(let child):
                if !Self.isReserved(child) { children.append(child) }
            case .text(let text):
                guard text.unicodeScalars.allSatisfy(Self.isWhiteSpace) else {
                    throw error("text is not allowed here", at: element)
                }
            case .comment, .processingInstruction:
                break
            }
        }
        return children
    }

    /// The element children of a property element when it has any; then
    /// its text must be white space.
    func contentElements(of element: XMLInfoset.Element) throws -> [XMLInfoset.Element] {
        let hasElements = element.children.contains {
            if case .element(let child) = $0 { return !Self.isReserved(child) }
            return false
        }
        return hasElements ? try elementChildren(of: element) : []
    }

    static func isReserved(_ element: XMLInfoset.Element) -> Bool {
        (element.prefix ?? element.localName).lowercased().hasPrefix("xml")
    }

    /// XML 1.0 [3] S.
    static func isWhiteSpace(_ scalar: Unicode.Scalar) -> Bool {
        scalar == " " || scalar == "\t" || scalar == "\n" || scalar == "\r"
    }

    // MARK: - Terms

    static let typeIRI = IRI.rdfType
    static let nilIRI = IRI.rdfNil
    static let xmlLiteralIRI = IRI.rdfXMLLiteral

    /// The element event's IRI (Element Event): namespace name and local name.
    func iri(of element: XMLInfoset.Element) throws -> String {
        guard let namespace = element.namespaceName else {
            throw error("the element '\(element.qualifiedName)' has no namespace", at: element)
        }
        try checkNamespace(namespace, at: element)
        return namespace + element.localName
    }

    /// The RDF Namespace and Vocabulary: no namespace may extend the RDF namespace IRI.
    func checkNamespace(_ namespace: String, at element: XMLInfoset.Element) throws {
        if namespace.hasPrefix(Self.rdf) && namespace != Self.rdf {
            throw error("the namespace <\(namespace)> extends the RDF namespace IRI", at: element)
        }
    }

    func makeIRI(_ string: String, at element: XMLInfoset.Element) throws -> IRI {
        guard let iri = IRI(rawValue: string) else {
            throw error("<\(string)> is not an IRI", at: element)
        }
        return iri
    }

    /// Resolving IRIs: a reference resolved against the in-scope base.
    func resolve(_ reference: String, _ scope: Scope, at element: XMLInfoset.Element) throws -> IRI {
        guard let base = scope.base else {
            guard let iri = IRI(rawValue: reference) else {
                throw error("<\(reference)> is relative and there is no base IRI", at: element)
            }
            return iri
        }
        guard let iri = IRI(resolving: reference, against: base) else {
            throw error("<\(reference)> does not resolve to an IRI against <\(base)>", at: element)
        }
        return iri
    }

    /// XML Base: an `xml:base` value resolved against the parent's base.
    func resolveBase(_ value: String, against parent: String?, at element: XMLInfoset.Element) throws -> String {
        guard let parent else { return value }
        guard let base = IRI(resolving: value, against: parent) else {
            throw error("xml:base <\(value)> does not resolve to an IRI against <\(parent)>", at: element)
        }
        return base.rawValue
    }

    /// The IRI of an `rdf:ID` value (production idAttr): `#` and the value, resolved
    /// against the base, unique in the document (constraint-id).
    mutating func identifier(_ id: String, _ scope: Scope, at element: XMLInfoset.Element) throws -> IRI {
        guard Self.isNCName(id) else {
            throw error("rdf:ID \"\(id)\" is not an XML NCName", at: element)
        }
        let iri = try resolve("#" + id, scope, at: element)
        guard identifiers.insert(iri).inserted else {
            throw error("rdf:ID \"\(id)\" names <\(iri)>, which another rdf:ID already names", at: element)
        }
        return iri
    }

    /// The blank node of an `rdf:nodeID` or `rdf:annotationNodeID` value.
    mutating func blankNode(_ id: String, at element: XMLInfoset.Element) throws -> BlankNode {
        guard Self.isNCName(id) else {
            throw error("the blank node identifier \"\(id)\" is not an XML NCName", at: element)
        }
        return try blankNodes.node(labelled: id)
    }

    /// A literal without datatype (Literal Without Datatype Event): the in-scope language and base
    /// direction make it a language-tagged or directional string.
    func plainLiteral(_ value: String, _ scope: Scope, at element: XMLInfoset.Element) throws -> Literal {
        do {
            guard !scope.language.isEmpty else { return Literal(value) }
            return try Literal(value, languageTag: scope.language, baseDirection: BaseDirection(rawValue: scope.direction))
        } catch {
            throw self.error("\(error)", at: element)
        }
    }

    /// A typed literal (Typed Literal Event).
    func makeLiteral(_ value: String, datatype: IRI, at element: XMLInfoset.Element) throws -> Literal {
        guard let literal = try? Literal(value, datatypeIRI: datatype) else {
            throw error("<\(datatype)> cannot be the datatype of \"\(value)\"", at: element)
        }
        return literal
    }

    /// XML Namespaces 1.0 [4] NCName.
    static func isNCName(_ value: String) -> Bool {
        guard let first = value.unicodeScalars.first, isNameStartChar(first) else { return false }
        return value.unicodeScalars.dropFirst().allSatisfy(isNameChar)
    }

    /// XML 1.0 [4] NameStartChar, without ':'.
    static func isNameStartChar(_ scalar: Unicode.Scalar) -> Bool {
        switch scalar.value {
        case 0x41...0x5A, 0x5F, 0x61...0x7A, 0xC0...0xD6, 0xD8...0xF6, 0xF8...0x2FF, 0x370...0x37D,
             0x37F...0x1FFF, 0x200C...0x200D, 0x2070...0x218F, 0x2C00...0x2FEF, 0x3001...0xD7FF,
             0xF900...0xFDCF, 0xFDF0...0xFFFD, 0x10000...0xEFFFF:
            true
        default:
            false
        }
    }

    /// XML 1.0 [4a] NameChar, without ':'.
    static func isNameChar(_ scalar: Unicode.Scalar) -> Bool {
        switch scalar.value {
        case 0x2D, 0x2E, 0x30...0x39, 0xB7, 0x300...0x36F, 0x203F...0x2040:
            true
        default:
            isNameStartChar(scalar)
        }
    }

    // MARK: - Emitting

    mutating func emit(_ subject: SubjectTerm, _ predicate: IRI, _ object: ObjectTerm) {
        triples.insert(Graph.Element(subject: subject, predicate: predicate, object: object))
    }

    /// Emits a property element's statement, then reifies it for `rdf:ID`
    /// (Reification Rules) and gives it the reifier of
    /// `rdf:annotation` or `rdf:annotationNodeID`.
    mutating func emitStatement(
        _ subject: SubjectTerm,
        _ predicate: IRI,
        _ object: ObjectTerm,
        _ attributes: Attributes,
        _ scope: Scope,
        at element: XMLInfoset.Element
    ) throws {
        emit(subject, predicate, object)
        if let id = attributes.id {
            let reifier = SubjectTerm.iri(try identifier(id, scope, at: element))
            emit(reifier, IRI.rdfSubject, subject.object)
            emit(reifier, IRI.rdfPredicate, .iri(predicate))
            emit(reifier, IRI.rdfObject, object)
            emit(reifier, Self.typeIRI, .iri(IRI.rdfStatement))
        }
        let reifier: SubjectTerm?
        if let annotation = attributes.annotation {
            reifier = .iri(try resolve(annotation, scope, at: element))
        } else if let annotationNodeID = attributes.annotationNodeID {
            reifier = .blankNode(try blankNode(annotationNodeID, at: element))
        } else {
            reifier = nil
        }
        if let reifier {
            emit(reifier, IRI.rdfReifies, .tripleTerm(Graph.Element(subject: subject, predicate: predicate, object: object)))
        }
    }

    /// Productions nodeElement and emptyPropertyElt: property attributes become triples about
    /// `subject`, `rdf:type` with an IRI object and every other with a
    /// literal in the element's language and base direction.
    mutating func emitPropertyAttributes(
        _ properties: [AttributeEvent],
        of subject: SubjectTerm,
        _ scope: Scope,
        at element: XMLInfoset.Element
    ) throws {
        for property in properties {
            let predicate = try makeIRI(property.iri, at: element)
            if predicate == Self.typeIRI {
                emit(subject, predicate, .iri(try resolve(property.value, scope, at: element)))
            } else {
                emit(subject, predicate, .literal(try plainLiteral(property.value, scope, at: element)))
            }
        }
    }

    func error(_ message: String, at element: XMLInfoset.Element) -> SyntaxError {
        SyntaxError(line: element.line, column: element.column, message: message)
    }
}
