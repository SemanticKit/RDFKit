import IRIKit
import RDFCore

/// Encodes descriptions as the graph of the triples they state, through
/// their `Encodable` conformance, as `JSONEncoder` encodes values as JSON.
///
/// Each description writes the triples about one subject: an individual
/// (a ``RDFCore/Resource``, declared in the DSL or translated from RDF), a
/// class, or the resource an ``RDFCore/Addition`` refers to. Its values are
/// typed Swift values; this is where they become RDF terms. A resource in
/// object position is written as the IRI its declared key gives (its
/// declared name in its vocabulary's namespace); one no declaration names is
/// a blank node, which is described too, once, since nothing outside the graph can
/// name it (RDF 1.2 Concepts §3.5: "Blank nodes are disjoint from IRIs and
/// literals").
///
///     let graph = try GraphEncoder().encode([alice, bob])
///
/// The format encoders, ``NTriplesEncoder``, ``TurtleEncoder`` and
/// ``RDFXMLEncoder``, write the graph it gives.
public struct GraphEncoder: Sendable {
    /// Creates a graph encoder.
    public init() {}

    /// The triples of the descriptions and of the blank nodes they reach.
    ///
    /// - Throws: `EncodingError` when a description writes something other
    ///   than resources, classes and literals keyed by property IRIs.
    public func encode(_ descriptions: [any Description]) throws -> Graph {
        let graph = EncodedGraph()
        for description in descriptions {
            try graph.describe(description)
        }
        while let blank = graph.undescribed.popLast() {
            try graph.describe(blank)
        }
        if let error = graph.error { throw error }
        return graph.triples
    }

    /// The triples of one description and of the blank nodes it reaches.
    public func encode(_ description: some Description) throws -> Graph {
        try encode([description])
    }
}

/// The graph a ``GraphEncoder`` run writes.
final class EncodedGraph {
    var triples = Graph()
    var undescribed: [any Description] = []
    var error: (any Error)?
    private var described: Set<ObjectIdentifier> = []
    private var blankNodes: [ObjectIdentifier: BlankNode] = [:]

    func describe(_ description: any Description) throws {
        let subject: SubjectTerm
        if let individual = description as? any Resource {
            guard described.insert(ObjectIdentifier(individual)).inserted else { return }
            subject = try term(type(of: individual).key, ObjectIdentifier(individual))
        } else if let description = description as? ClassDescription {
            guard described.insert(ObjectIdentifier(description.class)).inserted else { return }
            subject = try term(description.class.classKey, ObjectIdentifier(description.class))
        } else if let term = description as? any PropertyTerm {
            // A property's term type describes the property.
            subject = try self.term(type(of: term).key)
        } else if let addition = description as? any Addition {
            switch addition.resource {
            case .individual(let individual): subject = try term(type(of: individual).key, ObjectIdentifier(individual))
            case .class(let type): subject = try term(type.classKey, ObjectIdentifier(type))
            case .property(let property): subject = try term(property.key)
            case .literal(let literal):
                throw EncodingError.invalidValue(literal, EncodingError.Context(
                    codingPath: [],
                    debugDescription: "A subject is an IRI or a blank node (RDF 1.2 Concepts §3.1), not a literal."
                ))
            }
        } else {
            throw EncodingError.invalidValue(description, EncodingError.Context(
                codingPath: [],
                debugDescription: "A description is an individual, a class description, a declared term or an addition."
            ))
        }
        try description.encode(to: ResourceEncoder(graph: self, subject: subject))
    }

    /// The IRI a declared key gives, derived here, at the boundary.
    private func term(_ key: TermKey) throws -> SubjectTerm {
        do {
            return .iri(try IRI(validating: key.stringValue))
        } catch {
            throw EncodingError.invalidValue(key, EncodingError.Context(
                codingPath: [],
                debugDescription: "A declared name in its vocabulary's namespace is an IRI (RDF 1.2 Concepts §3.2).",
                underlyingError: error
            ))
        }
    }

    /// The IRI of a declared resource, or the blank node of a resource no
    /// declaration names.
    ///
    /// - Throws: `EncodingError.invalidValue` when the declared key does not
    ///   give an IRI. A declared resource is never written as a blank node.
    private func term(_ key: TermKey?, _ identity: ObjectIdentifier) throws -> SubjectTerm {
        if let key { return try term(key) }
        if let node = blankNodes[identity] { return .blankNode(node) }
        let node = try! BlankNode("b\(blankNodes.count)")  // never empty
        blankNodes[identity] = node
        return .blankNode(node)
    }

    /// A value in object position. A blank node it reaches is described too.
    ///
    /// - Throws: `EncodingError.invalidValue` when a declared key does not
    ///   give an IRI.
    func object(_ value: Value) throws -> ObjectTerm {
        switch value {
        case .literal(let literal):
            return .literal(literal)
        case .individual(let individual):
            let identity = ObjectIdentifier(individual)
            let key = type(of: individual).key
            if key == nil, !described.contains(identity) { undescribed.append(individual) }
            return try term(key, identity).object
        case .class(let type):
            let identity = ObjectIdentifier(type)
            if type.classKey == nil, !described.contains(identity) { undescribed.append(ClassDescription(type)) }
            return try term(type.classKey, identity).object
        case .property(let property):
            return try term(property.key).object
        }
    }
}

/// The encoder a description writes its property values to.
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
        if let value = value as? Value {
            object = try graph.object(value)
        } else if let resource = value as? any Resource {
            object = try graph.object(.individual(resource))
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
