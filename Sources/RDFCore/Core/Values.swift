/// The values of a many-valued property (D5), typed by its range.
///
/// An RDF graph is a set of triples (RDF 1.2 Concepts, RDF Graphs), so a
/// property's values are a set: inserting a value already present changes
/// nothing. Two individuals are the same value when they are the same object
/// (D3); two literals when their Swift values are equal (D6).
///
///     alice.knows.insert(bob)
///     alice.knows.contains { $0 === bob }
///
/// The range is usually a class's protocol, `any FOAF.Person`, which is not
/// `Hashable`, so the values are kept in order of insertion rather than
/// hashed.
public struct Values<Element> {
    private var elements: [Element]

    public init() {
        elements = []
    }

    public init<S: Sequence>(_ values: S) where S.Element == Element {
        elements = []
        for value in values { insert(value) }
    }

    /// Whether two values are the same value: the same object, or equal
    /// values of the same type.
    static func isSame(_ first: Element, _ second: Element) -> Bool {
        let first = first as Any
        let second = second as Any
        if type(of: first) is AnyClass {
            return type(of: second) is AnyClass && (first as AnyObject) === (second as AnyObject)
        }
        guard let first = first as? any Equatable else { return false }
        return isEqual(first, second)
    }

    private static func isEqual<T: Equatable>(_ first: T, _ second: Any) -> Bool {
        (second as? T) == first
    }

    private func index(of value: Element) -> Int? {
        elements.firstIndex { Self.isSame($0, value) }
    }
}

extension Values: RandomAccessCollection {
    public var startIndex: Int { elements.startIndex }
    public var endIndex: Int { elements.endIndex }
    public var isEmpty: Bool { elements.isEmpty }
    public subscript(position: Int) -> Element { elements[position] }
}

extension Values: SetAlgebra {
    public static func == (lhs: Values, rhs: Values) -> Bool {
        lhs.count == rhs.count && lhs.allSatisfy(rhs.contains)
    }

    public func contains(_ member: Element) -> Bool {
        index(of: member) != nil
    }

    @discardableResult
    public mutating func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element) {
        if let index = index(of: newMember) { return (false, elements[index]) }
        elements.append(newMember)
        return (true, newMember)
    }

    @discardableResult
    public mutating func remove(_ member: Element) -> Element? {
        guard let index = index(of: member) else { return nil }
        return elements.remove(at: index)
    }

    @discardableResult
    public mutating func update(with newMember: Element) -> Element? {
        guard let index = index(of: newMember) else {
            elements.append(newMember)
            return nil
        }
        defer { elements[index] = newMember }
        return elements[index]
    }

    public func union(_ other: Values) -> Values {
        var result = self
        result.formUnion(other)
        return result
    }

    public func intersection(_ other: Values) -> Values {
        Values(filter(other.contains))
    }

    public func symmetricDifference(_ other: Values) -> Values {
        Values(filter { !other.contains($0) } + other.filter { !contains($0) })
    }

    public mutating func formUnion(_ other: Values) {
        for value in other { insert(value) }
    }

    public mutating func formIntersection(_ other: Values) {
        self = intersection(other)
    }

    public mutating func formSymmetricDifference(_ other: Values) {
        self = symmetricDifference(other)
    }
}

extension Values: ExpressibleByArrayLiteral {
    public init(arrayLiteral values: Element...) {
        self.init(values)
    }
}

extension Values: Sendable where Element: Sendable {}

extension Values {
    /// The values of a functional property: its one value, or none
    /// (D5).
    public init(_ value: Element?) {
        self.init()
        if let value { insert(value) }
    }
}

extension Values: Encodable {
    /// Writes the values as a sequence, each as it encodes itself. The range
    /// of a property is a class's protocol, `any FOAF.Person`, which a Swift
    /// existential does not make `Encodable`, so each value is asked for its
    /// own conformance: the class generated for an individual and every
    /// literal's Swift type have one.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.unkeyedContainer()
        for value in self {
            guard let value = value as? any Encodable else {
                throw EncodingError.invalidValue(value, EncodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "\(type(of: value)) does not say how it encodes"
                ))
            }
            try container.encode(value)
        }
    }
}
