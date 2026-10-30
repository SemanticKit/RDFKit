import IRIKit
import RDFCore

/// Decodes the individuals a graph describes, as `JSONDecoder` decodes
/// values from JSON: the counterpart of ``GraphEncoder``.
///
/// The decoder is told the Swift classes it may make, as
/// `NSKeyedUnarchiver` is told the classes it may unarchive. A node of the
/// graph that the graph states is a member of the classes one of them is
/// written with (its ``RDFCore/PropertyValueStoring/classes``, as `rdf:type`)
/// becomes an instance of it; of several, the one whose classes the graph
/// states most of, then the first. Each individual's values are read
/// through its Swift class's `Decodable` property value types, keyed by
/// their properties, and an object becomes the Swift value it denotes: the
/// individual already decoded for its node, one of the named individuals
/// the decoder is given, a class or property the decoder knows, a literal,
/// or a new member of the class the property's range gives.
///
/// IRIs stay at this boundary. The individuals hold none: the decoder
/// records, in the ``DocumentContext`` it is given, the IRI of each node it
/// makes an individual for, and a ``GraphEncoder`` given that context writes
/// them back with the same IRIs.
///
///     let context = DocumentContext()
///     let people = try GraphDecoder(classes: [FOAF.PersonIndividual.self])
///         .decode((any FOAF.Person).self, from: graph, context: context)
public struct GraphDecoder: Sendable {
    /// The Swift classes the decoder may make individuals of.
    public let classes: [any DecodableResource.Type]

    /// The properties the decoder knows, for objects that name a property.
    public let properties: [any PropertyTerm.Type]

    /// The named individuals a document may name, which decode to
    /// themselves.
    public let individuals: [any Resource]

    /// Creates a graph decoder that may make individuals of `classes`, and
    /// knows `properties` and the named `individuals`.
    public init(
        classes: [any DecodableResource.Type],
        properties: [any PropertyTerm.Type] = [],
        individuals: [any Resource] = []
    ) {
        self.classes = classes
        self.properties = properties
        self.individuals = individuals
    }

    /// The individuals the graph states are members of a class the decoder
    /// may make, decoded with their values, that are `Member`s, in the order
    /// the graph first names them.
    ///
    /// - Throws: `DecodingError` when a value is not of the Swift type of its
    ///   property's values.
    public func decode<Member>(_ type: Member.Type, from graph: Graph, context: DocumentContext) throws -> [Member] {
        let run = DecodingRun(decoder: self, graph: graph, context: context)
        var members: [Member] = []
        var seen: Set<SubjectTerm> = []
        for triple in graph where seen.insert(triple.subject).inserted {
            guard run.stated(triple.subject) != nil else { continue }
            if let member = try run.individual(for: triple.subject, as: nil) as? Member {
                members.append(member)
            }
        }
        try run.decodeValues()
        return members
    }

    /// The individuals for the nodes `nodes` name, each decoded as a member of
    /// `type`, the class the caller states they are members of, as
    /// `JSONDecoder` decodes the type it is given. A node `context` already
    /// has an individual of `type` for is that individual.
    ///
    /// - Throws: `DecodingError` when a value is not of the Swift type of its
    ///   property's values.
    public func decode<Member: DecodableResource>(_ type: Member.Type, for nodes: [IRI], from graph: Graph, context: DocumentContext) throws -> [Member] {
        let run = DecodingRun(decoder: self, graph: graph, context: context)
        let members = try nodes.map { iri in
            guard let member = try run.individual(for: .iri(iri), as: type, stating: false) as? Member else {
                throw DecodingError.typeMismatch(Member.self, DecodingError.Context(
                    codingPath: [],
                    debugDescription: "<\(iri)> is a named individual of another class."
                ))
            }
            return member
        }
        try run.decodeValues()
        return members
    }
}

/// One decoding of one graph: the individual made for each node so far.
final class DecodingRun {
    let decoder: GraphDecoder
    let graph: Graph
    let context: DocumentContext

    /// The triples of each subject, in graph order.
    private var statements: [SubjectTerm: [Graph.Element]] = [:]

    /// The individual made for each node of this graph, blank nodes included.
    private var made: [SubjectTerm: any Resource] = [:]

    /// The individuals made whose values are still to be read. They are
    /// read one after another, not as each is reached, so a long chain of
    /// references, such as an `rdf:List` of hundreds of members, does not
    /// nest one decoding inside the next.
    private var pending: [(individual: any DecodableResource, node: SubjectTerm)] = []

    init(decoder: GraphDecoder, graph: Graph, context: DocumentContext) {
        self.decoder = decoder
        self.graph = graph
        self.context = context
        for triple in graph {
            statements[triple.subject, default: []].append(triple)
        }
    }

    /// The triples the graph states about `node`.
    func statements(about node: SubjectTerm) -> [Graph.Element] {
        statements[node] ?? []
    }

    /// The class the decoder may make whose classes the graph states `node`
    /// is a member of.
    func stated(_ node: SubjectTerm) -> (any DecodableResource.Type)? {
        let statements = self.statements(about: node)
        var best: (type: any DecodableResource.Type, count: Int)?
        for candidate in decoder.classes {
            guard let key = candidate.typeProperty, let property = IRI(key), !candidate.classes.isEmpty else { continue }
            let stated = candidate.classes.allSatisfy { member in
                guard let iri = IRI(of: member) else { return false }
                return statements.contains { $0.predicate == property && $0.object == .iri(iri) }
            }
            if stated, candidate.classes.count > (best?.count ?? 0) {
                best = (candidate, candidate.classes.count)
            }
        }
        return best?.type
    }

    /// The individual for `node`: the one already made for it, the named
    /// individual it names, the one the context has for its IRI, or a new
    /// member of the class the graph states, else of `default`, which the
    /// context records for its IRI.
    ///
    /// With `stating` false, a new individual is a member of `default`
    /// whatever the graph states.
    func individual(for node: SubjectTerm, as default: (any DecodableResource.Type)?, stating: Bool = true) throws -> any Resource {
        if let individual = made[node] { return individual }
        if case .iri(let iri) = node, let named = decoder.individuals.first(where: { IRI(of: $0) == iri }) {
            made[node] = named
            return named
        }
        // An earlier decoding with this context made the individual the
        // IRI names, and read its values then.
        if case .iri(let iri) = node, let decoded = context.individual(for: iri) {
            made[node] = decoded
            return decoded
        }
        guard let type = (stating ? stated(node) : nil) ?? `default` else {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: [],
                debugDescription: "\(node) is a member of no class the decoder may make."
            ))
        }
        let individual = type.init()
        if case .iri(let iri) = node {
            let recorded = context.individual(for: iri) { individual }
            made[node] = recorded
            guard recorded === individual else { return recorded }
        } else {
            made[node] = individual
        }
        pending.append((individual, node))
        return individual
    }

    /// Reads the values of every individual made, and of those their values
    /// reach.
    func decodeValues() throws {
        while !pending.isEmpty {
            let (individual, node) = pending.removeFirst()
            try individual.decodeValues(from: NodeDecoder(run: self, node: node))
        }
    }

    /// The class the decoder knows that `object` names.
    func `class`(_ object: ObjectTerm) -> (any ResourceClass.Type)? {
        guard case .iri(let iri) = object else { return nil }
        for candidate in decoder.classes {
            if let type = candidate as? any ResourceClass.Type, IRI(of: type) == iri { return type }
        }
        return nil
    }

    /// The property the decoder knows that `object` names.
    func property(_ object: ObjectTerm) -> (any PropertyTerm.Type)? {
        guard case .iri(let iri) = object else { return nil }
        return decoder.properties.first { IRI(of: $0) == iri }
    }
}

/// The decoder of one node's property values.
struct NodeDecoder: Decoder {
    let run: DecodingRun
    let node: SubjectTerm
    var codingPath: [any CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any] { [:] }

    func container<Key: CodingKey>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        KeyedDecodingContainer(NodeContainer<Key>(run: run, statements: run.statements(about: node), codingPath: codingPath))
    }

    func unkeyedContainer() throws -> any UnkeyedDecodingContainer {
        throw Self.notADescription(codingPath)
    }

    func singleValueContainer() throws -> any SingleValueDecodingContainer {
        throw Self.notADescription(codingPath)
    }

    static func notADescription(_ codingPath: [any CodingKey]) -> DecodingError {
        DecodingError.typeMismatch(Value.self, DecodingError.Context(
            codingPath: codingPath,
            debugDescription: "A resource is described by property values keyed by property IRIs."
        ))
    }
}

/// The values of one node, keyed by their properties' IRIs.
struct NodeContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    let run: DecodingRun
    let statements: [Graph.Element]
    var codingPath: [any CodingKey]

    var allKeys: [Key] {
        var keys: [Key] = []
        var seen: Set<IRI> = []
        for triple in statements where seen.insert(triple.predicate).inserted {
            if let key = Key(stringValue: triple.predicate.rawValue) { keys.append(key) }
        }
        return keys
    }

    func contains(_ key: Key) -> Bool {
        !objects(key).isEmpty
    }

    private func objects(_ key: Key) -> [ObjectTerm] {
        guard let predicate = try? IRI(validating: key.stringValue) else { return [] }
        return statements.filter { $0.predicate == predicate }.map(\.object)
    }

    /// The decoder of the objects of one property.
    func superDecoder(forKey key: Key) throws -> any Decoder {
        ObjectsDecoder(run: run, objects: objects(key), codingPath: codingPath + [key])
    }

    func superDecoder() throws -> any Decoder {
        throw NodeDecoder.notADescription(codingPath)
    }

    func decodeNil(forKey key: Key) throws -> Bool { objects(key).isEmpty }

    func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
        throw NodeDecoder.notADescription(codingPath + [key])
    }

    func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
        throw NodeDecoder.notADescription(codingPath + [key])
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> any UnkeyedDecodingContainer {
        throw NodeDecoder.notADescription(codingPath + [key])
    }
}

/// The objects of one property of one node, which become the Swift values
/// they denote.
struct ObjectsDecoder: PropertyObjectsDecoder {
    let run: DecodingRun
    let objects: [ObjectTerm]
    var codingPath: [any CodingKey]
    var userInfo: [CodingUserInfoKey: Any] { [:] }

    func container<Key: CodingKey>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        throw NodeDecoder.notADescription(codingPath)
    }

    func unkeyedContainer() throws -> any UnkeyedDecodingContainer {
        throw NodeDecoder.notADescription(codingPath)
    }

    func singleValueContainer() throws -> any SingleValueDecodingContainer {
        throw NodeDecoder.notADescription(codingPath)
    }

    func values(_ class: (any DecodableResource.Type)?) throws -> [Value] {
        try objects.map { try value(of: $0, as: `class`) }
    }

    /// The Swift value `object` denotes. The components of a triple term are
    /// the values they denote; the range of the property does not apply to
    /// them, so a node in one is a value only when the graph or the decoder
    /// gives it a class.
    private func value(of object: ObjectTerm, as class: (any DecodableResource.Type)?) throws -> Value {
        switch object {
        case .literal(let literal):
            return .literal(literal)
        case .tripleTerm(let triple):
            guard let predicate = run.property(.iri(triple.predicate)) else {
                throw mismatch(Value.self, "The predicate of a triple term names no property the decoder knows.")
            }
            return .tripleTerm(
                subject: try value(of: triple.subject.object, as: nil),
                predicate: predicate,
                object: try value(of: triple.object, as: nil)
            )
        case .iri(let iri):
            if let type = run.class(object) { return .class(type) }
            if let property = run.property(object) { return .property(property) }
            return .individual(try run.individual(for: .iri(iri), as: `class`))
        case .blankNode(let node):
            return .individual(try run.individual(for: .blankNode(node), as: `class`))
        }
    }

    private func mismatch(_ type: Any.Type, _ description: String) -> DecodingError {
        DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: description))
    }
}
