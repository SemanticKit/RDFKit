import IRIKit
import RDFCore

/// Encodes Swift values as an RDF graph.
///
/// A value describes a node the way a JSON-LD 1.1 node object does (§9.2):
/// its keys are `@id`, the node's IRI, `@type`, the IRIs of its classes
/// (`rdf:type`), and the IRIs of its properties, each with the value or the
/// values of that property. A node with no `@id` is a blank node.
///
///     enum CodingKeys: String, CodingKey {
///         case id = "@id"
///         case type = "@type"
///         case knows = "http://xmlns.com/foaf/0.1/knows"
///     }
///
/// A property's value is an object of the property: a `Literal` is itself;
/// a string is a simple literal, a `Bool` an `xsd:boolean`, an integer an
/// `xsd:integer`, a `Double` an `xsd:double` and a `Float` an `xsd:float`,
/// each in its canonical lexical form (XSD 1.1 Part 2 §3.3); a value with
/// keys is a node; a sequence is that many objects, a set as the graph is
/// (RDF 1.2 Concepts §3.1). An instance of a class is one node however many
/// times it is encoded, so values that refer to each other, `alice.knows`
/// holding `bob` and `bob.knows` holding `alice`, encode as the cycle they
/// are. The values at the top level, one or a sequence of them, are nodes.
public struct GraphEncoder: Sendable {
    /// Creates a graph encoder.
    public init() {}

    /// The graph a value, or a sequence of values, describes.
    public func encode(_ value: some Encodable) throws -> Graph {
        let writer = GraphWriter()
        try writer.encode(value, codingPath: []) { object in
            if case .literal(let literal) = object {
                writer.fail(EncodingError.invalidValue(literal, EncodingError.Context(
                    codingPath: [], debugDescription: "A literal at the top level is not a node of a graph")))
            }
        }
        return try writer.graph()
    }
}

/// A node of the graph being written: named by its `@id`, a blank node
/// otherwise.
private final class GraphNode {
    var iri: IRI?
}

/// The object of a statement being written.
private enum GraphObject {
    case node(GraphNode)
    case literal(Literal)
}

/// The statements written so far, and the node each class instance is.
private final class GraphWriter {
    var statements: [(subject: GraphNode, predicate: IRI, object: GraphObject)] = []
    var instances: [ObjectIdentifier: GraphNode] = [:]
    private var failure: (any Error)?

    /// Writes a value, handing each object it is to `sink`.
    func encode<T: Encodable>(_ value: T, codingPath: [any CodingKey], sink: @escaping (GraphObject) -> Void) throws {
        if let literal = value as? Literal {
            sink(.literal(literal))
            return
        }
        var identity: ObjectIdentifier?
        if type(of: value as Any) is AnyClass {
            let instance = ObjectIdentifier(value as AnyObject)
            if let node = instances[instance] {
                sink(.node(node))
                return
            }
            identity = instance
        }
        try value.encode(to: ObjectEncoder(writer: self, codingPath: codingPath, identity: identity, sink: sink))
        if let failure { throw failure }
    }

    /// Records an error found where the encoding API cannot throw.
    func fail(_ error: any Error) {
        if failure == nil { failure = error }
    }

    func graph() throws -> Graph {
        if let failure { throw failure }
        var blankNodes: [ObjectIdentifier: BlankNode] = [:]
        func term(_ node: GraphNode) throws -> SubjectTerm {
            if let iri = node.iri { return .iri(iri) }
            if let blankNode = blankNodes[ObjectIdentifier(node)] { return .blankNode(blankNode) }
            let blankNode = try BlankNode("b\(blankNodes.count)")
            blankNodes[ObjectIdentifier(node)] = blankNode
            return .blankNode(blankNode)
        }
        var graph = Graph()
        for statement in statements {
            let object: ObjectTerm
            switch statement.object {
            case .node(let node): object = try term(node).object
            case .literal(let literal): object = .literal(literal)
            }
            graph.insert(Triple(subject: try term(statement.subject), predicate: statement.predicate, object: object))
        }
        return graph
    }
}

/// The encoder of one value: with keys it is a node, with one value a
/// literal, with a sequence that many objects.
private final class ObjectEncoder: Encoder {
    let writer: GraphWriter
    let codingPath: [any CodingKey]
    let identity: ObjectIdentifier?
    let sink: (GraphObject) -> Void
    var userInfo: [CodingUserInfoKey: Any] { [:] }
    private var node: GraphNode?

    init(writer: GraphWriter, codingPath: [any CodingKey], identity: ObjectIdentifier?, sink: @escaping (GraphObject) -> Void, node: GraphNode? = nil) {
        self.writer = writer
        self.codingPath = codingPath
        self.identity = identity
        self.sink = sink
        self.node = node
    }

    func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        if let node { return KeyedEncodingContainer(NodeContainer(writer: writer, node: node, codingPath: codingPath)) }
        let node = GraphNode()
        self.node = node
        if let identity { writer.instances[identity] = node }
        sink(.node(node))
        return KeyedEncodingContainer(NodeContainer(writer: writer, node: node, codingPath: codingPath))
    }

    func unkeyedContainer() -> any UnkeyedEncodingContainer {
        ObjectList(writer: writer, codingPath: codingPath, sink: sink)
    }

    func singleValueContainer() -> any SingleValueEncodingContainer {
        LiteralContainer(writer: writer, codingPath: codingPath, sink: sink)
    }
}

/// The key of an element of a sequence.
private struct IndexKey: CodingKey {
    let intValue: Int?
    var stringValue: String { "\(intValue ?? 0)" }
    init(intValue: Int) { self.intValue = intValue }
    init?(stringValue: String) { nil }
}

/// The keys of a node: `@id`, `@type` and its properties' IRIs.
private struct NodeContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
    let writer: GraphWriter
    let node: GraphNode
    let codingPath: [any CodingKey]

    mutating func encodeNil(forKey key: Key) throws {}

    mutating func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
        try put(value, forKey: key)
    }

    private func put<T: Encodable>(_ value: T, forKey key: Key) throws {
        let path = codingPath + [key]
        let writer = writer
        let node = node
        switch key.stringValue {
        case "@id":
            guard let text = value as? String else {
                throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: path, debugDescription: "@id is a node's IRI, as a String"))
            }
            node.iri = try IRI(validating: text)
        case "@type":
            try writer.encode(value, codingPath: path) { object in
                guard case .literal(let literal) = object, literal.datatype == nil, literal.languageTag == nil else {
                    writer.fail(EncodingError.invalidValue(value, EncodingError.Context(codingPath: path, debugDescription: "@type holds the IRIs of a node's classes, as Strings")))
                    return
                }
                do {
                    writer.statements.append((node, .rdfType, .node(Self.named(try IRI(validating: literal.lexicalForm)))))
                } catch {
                    writer.fail(error)
                }
            }
        default:
            let predicate = try IRI(validating: key.stringValue)
            try writer.encode(value, codingPath: path) { writer.statements.append((node, predicate, $0)) }
        }
    }

    /// A node named by an IRI.
    static func named(_ iri: IRI) -> GraphNode {
        let node = GraphNode()
        node.iri = iri
        return node
    }

    private func objects(forKey key: Key) throws -> (GraphObject) -> Void {
        let predicate = try IRI(validating: key.stringValue)
        let writer = writer
        let node = node
        return { writer.statements.append((node, predicate, $0)) }
    }

    mutating func encode(_ value: Bool, forKey key: Key) throws { try put(value, forKey: key) }
    mutating func encode(_ value: String, forKey key: Key) throws { try put(value, forKey: key) }
    mutating func encode(_ value: Double, forKey key: Key) throws { try put(value, forKey: key) }
    mutating func encode(_ value: Float, forKey key: Key) throws { try put(value, forKey: key) }
    mutating func encode(_ value: Int, forKey key: Key) throws { try put(value, forKey: key) }
    mutating func encode(_ value: Int8, forKey key: Key) throws { try put(value, forKey: key) }
    mutating func encode(_ value: Int16, forKey key: Key) throws { try put(value, forKey: key) }
    mutating func encode(_ value: Int32, forKey key: Key) throws { try put(value, forKey: key) }
    mutating func encode(_ value: Int64, forKey key: Key) throws { try put(value, forKey: key) }
    mutating func encode(_ value: UInt, forKey key: Key) throws { try put(value, forKey: key) }
    mutating func encode(_ value: UInt8, forKey key: Key) throws { try put(value, forKey: key) }
    mutating func encode(_ value: UInt16, forKey key: Key) throws { try put(value, forKey: key) }
    mutating func encode(_ value: UInt32, forKey key: Key) throws { try put(value, forKey: key) }
    mutating func encode(_ value: UInt64, forKey key: Key) throws { try put(value, forKey: key) }

    mutating func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
        let sink: (GraphObject) -> Void
        do { sink = try objects(forKey: key) } catch { writer.fail(error); sink = { _ in } }
        return ObjectEncoder(writer: writer, codingPath: codingPath + [key], identity: nil, sink: sink).container(keyedBy: keyType)
    }

    mutating func nestedUnkeyedContainer(forKey key: Key) -> any UnkeyedEncodingContainer {
        let sink: (GraphObject) -> Void
        do { sink = try objects(forKey: key) } catch { writer.fail(error); sink = { _ in } }
        return ObjectList(writer: writer, codingPath: codingPath + [key], sink: sink)
    }

    mutating func superEncoder() -> any Encoder {
        ObjectEncoder(writer: writer, codingPath: codingPath, identity: nil, sink: { _ in }, node: node)
    }

    mutating func superEncoder(forKey key: Key) -> any Encoder {
        superEncoder()
    }
}

/// The values of a sequence, each an object.
private struct ObjectList: UnkeyedEncodingContainer {
    let writer: GraphWriter
    let codingPath: [any CodingKey]
    let sink: (GraphObject) -> Void
    private(set) var count = 0

    init(writer: GraphWriter, codingPath: [any CodingKey], sink: @escaping (GraphObject) -> Void) {
        self.writer = writer
        self.codingPath = codingPath
        self.sink = sink
    }

    private var nextPath: [any CodingKey] { codingPath + [IndexKey(intValue: count)] }

    mutating func encodeNil() throws { count += 1 }

    mutating func encode<T: Encodable>(_ value: T) throws {
        try put(value)
    }

    private mutating func put<T: Encodable>(_ value: T) throws {
        try writer.encode(value, codingPath: nextPath, sink: sink)
        count += 1
    }

    mutating func encode(_ value: Bool) throws { try put(value) }
    mutating func encode(_ value: String) throws { try put(value) }
    mutating func encode(_ value: Double) throws { try put(value) }
    mutating func encode(_ value: Float) throws { try put(value) }
    mutating func encode(_ value: Int) throws { try put(value) }
    mutating func encode(_ value: Int8) throws { try put(value) }
    mutating func encode(_ value: Int16) throws { try put(value) }
    mutating func encode(_ value: Int32) throws { try put(value) }
    mutating func encode(_ value: Int64) throws { try put(value) }
    mutating func encode(_ value: UInt) throws { try put(value) }
    mutating func encode(_ value: UInt8) throws { try put(value) }
    mutating func encode(_ value: UInt16) throws { try put(value) }
    mutating func encode(_ value: UInt32) throws { try put(value) }
    mutating func encode(_ value: UInt64) throws { try put(value) }

    mutating func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> {
        defer { count += 1 }
        return ObjectEncoder(writer: writer, codingPath: nextPath, identity: nil, sink: sink).container(keyedBy: keyType)
    }

    mutating func nestedUnkeyedContainer() -> any UnkeyedEncodingContainer {
        defer { count += 1 }
        return ObjectList(writer: writer, codingPath: nextPath, sink: sink)
    }

    mutating func superEncoder() -> any Encoder {
        defer { count += 1 }
        return ObjectEncoder(writer: writer, codingPath: nextPath, identity: nil, sink: sink)
    }
}

/// One value: a literal, or the value it encodes as.
private struct LiteralContainer: SingleValueEncodingContainer {
    let writer: GraphWriter
    let codingPath: [any CodingKey]
    let sink: (GraphObject) -> Void

    mutating func encodeNil() throws {}

    mutating func encode<T: Encodable>(_ value: T) throws {
        try writer.encode(value, codingPath: codingPath, sink: sink)
    }

    mutating func encode(_ value: String) throws { sink(.literal(Literal(value))) }
    mutating func encode(_ value: Bool) throws { sink(.literal(Literal(value ? "true" : "false", datatype: .xsdBoolean))) }
    mutating func encode(_ value: Double) throws { sink(.literal(Literal(Self.canonical(value), datatype: .xsdDouble))) }
    mutating func encode(_ value: Float) throws { sink(.literal(Literal(Self.canonical(value), datatype: Self.xsdFloat))) }
    mutating func encode(_ value: Int) throws { integer(value) }
    mutating func encode(_ value: Int8) throws { integer(value) }
    mutating func encode(_ value: Int16) throws { integer(value) }
    mutating func encode(_ value: Int32) throws { integer(value) }
    mutating func encode(_ value: Int64) throws { integer(value) }
    mutating func encode(_ value: UInt) throws { integer(value) }
    mutating func encode(_ value: UInt8) throws { integer(value) }
    mutating func encode(_ value: UInt16) throws { integer(value) }
    mutating func encode(_ value: UInt32) throws { integer(value) }
    mutating func encode(_ value: UInt64) throws { integer(value) }

    /// `xsd:float`, which no grammar of the formats fixes.
    static let xsdFloat: IRI = "http://www.w3.org/2001/XMLSchema#float"

    private func integer(_ value: some BinaryInteger) {
        sink(.literal(Literal("\(value)", datatype: .xsdInteger)))
    }

    /// The canonical representation of a double or float (XSD 1.1 Part 2
    /// §3.3.5.2, §3.3.4.2): `INF`, `-INF`, `NaN`, `0.0E0`, `-0.0E0`, or
    /// scientific notation with one non-zero digit before the point, at
    /// least one after it, and the shortest digits that read back as the
    /// value.
    static func canonical(_ value: some BinaryFloatingPoint & LosslessStringConvertible) -> String {
        if value.isNaN { return "NaN" }
        if value.isInfinite { return value < 0 ? "-INF" : "INF" }
        if value.isZero { return value.sign == .minus ? "-0.0E0" : "0.0E0" }
        var text = Substring(value.description)
        var sign = ""
        if text.hasPrefix("-") {
            sign = "-"
            text = text.dropFirst()
        }
        let parts = text.split(separator: "e")
        let mantissa = parts[0]
        let point = mantissa.firstIndex(of: ".").map { mantissa.distance(from: mantissa.startIndex, to: $0) } ?? mantissa.count
        var digits = Array(mantissa.filter { $0 != "." })
        var exponent = (parts.count > 1 ? Int(parts[1]) ?? 0 : 0) + point - 1
        while digits.first == "0" {
            digits.removeFirst()
            exponent -= 1
        }
        while digits.last == "0" { digits.removeLast() }
        let fraction = digits.count > 1 ? String(digits.dropFirst()) : "0"
        return "\(sign)\(digits[0]).\(fraction)E\(exponent)"
    }
}
