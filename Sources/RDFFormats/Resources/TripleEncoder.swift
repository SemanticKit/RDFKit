import IRIKit
import RDFCore
import RDFRuntime

/// Encodes resources as the triples that describe them, through their
/// `Encodable` conformance.
///
/// Each resource given is the subject of the triples its property values
/// make. A resource in object position is written as its IRI; a blank node is
/// written as a blank node and described too, once, since nothing outside the
/// graph can name it (RDF 1.2 Concepts §3.5: "Blank nodes are disjoint from
/// IRIs and literals").
struct TripleEncoder {
    /// The triples describing the resources and the blank nodes they reach.
    func encode(_ resources: [any RDFRuntime.Resource]) throws -> Graph {
        let graph = EncodedGraph()
        for resource in resources {
            try graph.describe(resource)
        }
        while let blank = graph.undescribed.popLast() {
            try graph.describe(blank)
        }
        if let error = graph.error { throw error }
        return graph.triples
    }
}

/// The graph a ``TripleEncoder`` run writes.
final class EncodedGraph {
    var triples: Graph = []
    var undescribed: [any RDFRuntime.Resource] = []
    var error: (any Error)?
    private var described: Set<ObjectIdentifier> = []
    private var blankNodes: [ObjectIdentifier: BlankNode] = [:]

    func describe(_ resource: any RDFRuntime.Resource) throws {
        guard described.insert(ObjectIdentifier(resource)).inserted else { return }
        try resource.encode(to: ResourceEncoder(graph: self, subject: subject(resource)))
    }

    func subject(_ resource: any RDFRuntime.Resource) -> SubjectTerm {
        if let iri = type(of: resource).iri { return .iri(iri) }
        let id = ObjectIdentifier(resource)
        if let node = blankNodes[id] { return .blankNode(node) }
        let node = try! BlankNode("b\(blankNodes.count)")  // never empty
        blankNodes[id] = node
        return .blankNode(node)
    }

    func object(_ resource: any RDFRuntime.Resource) -> ObjectTerm {
        let term = subject(resource)
        if case .blankNode = term, !described.contains(ObjectIdentifier(resource)) {
            undescribed.append(resource)
        }
        return term.object
    }
}

/// The encoder a resource writes its property values to.
struct ResourceEncoder: Encoder {
    let graph: EncodedGraph
    let subject: SubjectTerm
    var codingPath: [any CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any] { [:] }

    func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        KeyedEncodingContainer(PropertyContainer(graph: graph, subject: subject, codingPath: codingPath))
    }

    func unkeyedContainer() -> any UnkeyedEncodingContainer {
        graph.error = graph.error ?? Self.notADescription(codingPath)
        return RejectingEncoder(graph: graph, codingPath: codingPath).unkeyedContainer()
    }

    func singleValueContainer() -> any SingleValueEncodingContainer {
        graph.error = graph.error ?? Self.notADescription(codingPath)
        return RejectingEncoder(graph: graph, codingPath: codingPath).singleValueContainer()
    }

    static func notADescription(_ codingPath: [any CodingKey]) -> EncodingError {
        EncodingError.invalidValue((), EncodingError.Context(
            codingPath: codingPath,
            debugDescription: "A resource is described by property values keyed by property IRIs."
        ))
    }
}

/// The key a ``ResourceEncoder`` reads a property IRI from.
struct PropertyKey: CodingKey {
    let stringValue: String
    init?(stringValue: String) { self.stringValue = stringValue }
    var intValue: Int? { nil }
    init?(intValue: Int) { nil }
}

/// Writes one triple for each value: the subject, the property its key
/// names, and the value as an object.
struct PropertyContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
    let graph: EncodedGraph
    let subject: SubjectTerm
    var codingPath: [any CodingKey]

    mutating func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
        let predicate: IRI
        do {
            predicate = try IRI(validating: key.stringValue)
        } catch {
            throw EncodingError.invalidValue(value, EncodingError.Context(
                codingPath: codingPath + [key],
                debugDescription: "A predicate is an IRI (RDF 1.2 Concepts §3.1).",
                underlyingError: error
            ))
        }
        let object: ObjectTerm
        if let resource = value as? any RDFRuntime.Resource {
            object = graph.object(resource)
        } else if let literal = value as? Literal {
            object = .literal(literal)
        } else {
            throw EncodingError.invalidValue(value, EncodingError.Context(
                codingPath: codingPath + [key],
                debugDescription: "An object is a resource or a literal (RDF 1.2 Concepts §3.1)."
            ))
        }
        graph.triples.insert(Graph.Element(subject: subject, predicate: predicate, object: object))
    }

    mutating func encodeNil(forKey key: Key) throws {
        throw EncodingError.invalidValue(Optional<Literal>.none as Any, EncodingError.Context(
            codingPath: codingPath + [key],
            debugDescription: "An RDF graph states only the values a property has."
        ))
    }

    mutating func encode(_ value: Bool, forKey key: Key) throws { try encode(Unrepresented(value), forKey: key) }
    mutating func encode(_ value: String, forKey key: Key) throws { try encode(Unrepresented(value), forKey: key) }
    mutating func encode(_ value: Double, forKey key: Key) throws { try encode(Unrepresented(value), forKey: key) }
    mutating func encode(_ value: Float, forKey key: Key) throws { try encode(Unrepresented(value), forKey: key) }
    mutating func encode(_ value: Int, forKey key: Key) throws { try encode(Unrepresented(value), forKey: key) }
    mutating func encode(_ value: Int8, forKey key: Key) throws { try encode(Unrepresented(value), forKey: key) }
    mutating func encode(_ value: Int16, forKey key: Key) throws { try encode(Unrepresented(value), forKey: key) }
    mutating func encode(_ value: Int32, forKey key: Key) throws { try encode(Unrepresented(value), forKey: key) }
    mutating func encode(_ value: Int64, forKey key: Key) throws { try encode(Unrepresented(value), forKey: key) }
    mutating func encode(_ value: UInt, forKey key: Key) throws { try encode(Unrepresented(value), forKey: key) }
    mutating func encode(_ value: UInt8, forKey key: Key) throws { try encode(Unrepresented(value), forKey: key) }
    mutating func encode(_ value: UInt16, forKey key: Key) throws { try encode(Unrepresented(value), forKey: key) }
    mutating func encode(_ value: UInt32, forKey key: Key) throws { try encode(Unrepresented(value), forKey: key) }
    mutating func encode(_ value: UInt64, forKey key: Key) throws { try encode(Unrepresented(value), forKey: key) }

    mutating func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
        graph.error = graph.error ?? ResourceEncoder.notADescription(codingPath + [key])
        return RejectingEncoder(graph: graph, codingPath: codingPath + [key]).container(keyedBy: keyType)
    }

    mutating func nestedUnkeyedContainer(forKey key: Key) -> any UnkeyedEncodingContainer {
        graph.error = graph.error ?? ResourceEncoder.notADescription(codingPath + [key])
        return RejectingEncoder(graph: graph, codingPath: codingPath + [key]).unkeyedContainer()
    }

    /// The same subject: a superclass's values describe the same resource.
    mutating func superEncoder() -> any Encoder {
        ResourceEncoder(graph: graph, subject: subject, codingPath: codingPath)
    }

    mutating func superEncoder(forKey key: Key) -> any Encoder {
        graph.error = graph.error ?? ResourceEncoder.notADescription(codingPath + [key])
        return RejectingEncoder(graph: graph, codingPath: codingPath + [key])
    }
}

/// A Swift value that is neither a resource nor a literal, which this
/// encoder does not map to RDF.
private struct Unrepresented<Value: Encodable>: Encodable {
    let value: Value
    init(_ value: Value) { self.value = value }
    func encode(to encoder: any Encoder) throws { try value.encode(to: encoder) }
}

/// The encoder and containers returned where a description has no place
/// for them. Every value written to them is an error.
struct RejectingEncoder: Encoder {
    let graph: EncodedGraph
    var codingPath: [any CodingKey]
    var userInfo: [CodingUserInfoKey: Any] { [:] }

    func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        KeyedEncodingContainer(RejectingContainer<Key>(graph: graph, codingPath: codingPath))
    }

    func unkeyedContainer() -> any UnkeyedEncodingContainer {
        RejectingContainer<PropertyKey>(graph: graph, codingPath: codingPath)
    }

    func singleValueContainer() -> any SingleValueEncodingContainer {
        RejectingContainer<PropertyKey>(graph: graph, codingPath: codingPath)
    }
}

struct RejectingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol, UnkeyedEncodingContainer, SingleValueEncodingContainer {
    let graph: EncodedGraph
    var codingPath: [any CodingKey]
    var count: Int { 0 }

    private func reject() -> EncodingError {
        ResourceEncoder.notADescription(codingPath)
    }

    private var encoder: RejectingEncoder { RejectingEncoder(graph: graph, codingPath: codingPath) }

    mutating func encode<T: Encodable>(_ value: T, forKey key: Key) throws { throw reject() }
    mutating func encodeNil(forKey key: Key) throws { throw reject() }
    mutating func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
        encoder.container(keyedBy: keyType)
    }
    mutating func nestedUnkeyedContainer(forKey key: Key) -> any UnkeyedEncodingContainer { self }
    mutating func superEncoder(forKey key: Key) -> any Encoder { encoder }

    mutating func encode<T: Encodable>(_ value: T) throws { throw reject() }
    mutating func encodeNil() throws { throw reject() }
    mutating func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> {
        encoder.container(keyedBy: keyType)
    }
    mutating func nestedUnkeyedContainer() -> any UnkeyedEncodingContainer { self }
    mutating func superEncoder() -> any Encoder { encoder }
}
