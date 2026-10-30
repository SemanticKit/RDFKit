import RDFCore
import XSD

// What an individual's properties hold, read through its `Encodable`
// conformance as an encoder reads it: the datatype values of its
// XSD-ranged properties and the literals it keeps as literals. The tests
// read the fixtures' individuals this way, so they reach every datatype's
// Swift type through the properties that range over it, with no table of
// types or IRIs.

/// The values and literals one individual encodes, by property key.
final class EncodedValues {
    /// The datatype values, in the order the individual writes them.
    private(set) var values: [(property: String, value: any DatatypeValue)] = []

    /// The literals, kept or of a literal-ranged property.
    private(set) var literals: [(property: String, literal: Literal)] = []

    /// What `individual` encodes.
    init(of individual: any Encodable) throws {
        try individual.encode(to: Collector(values: self))
    }

    func record(_ value: some Encodable, for property: String) {
        if let value = value as? any DatatypeValue {
            values.append((property, value))
        } else if case .literal(let literal)? = value as? RDFCore.Value {
            literals.append((property, literal))
        } else if let literal = value as? Literal {
            literals.append((property, literal))
        }
    }

    /// The datatype values.
    var datatypeValues: [any DatatypeValue] { values.map(\.value) }

    /// The literals of the property with `key`.
    func literals(of key: TermKey) -> [Literal] {
        literals.filter { $0.property == PropertyKey(key).stringValue }.map(\.literal)
    }

    /// The literals of every property but the one with `key`.
    func literals(besides key: TermKey) -> [Literal] {
        literals.filter { $0.property != PropertyKey(key).stringValue }.map(\.literal)
    }

    private struct Collector: Encoder {
        let values: EncodedValues
        var codingPath: [any CodingKey] { [] }
        var userInfo: [CodingUserInfoKey: Any] { [:] }

        func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
            KeyedEncodingContainer(Container<Key>(values: values))
        }

        func unkeyedContainer() -> any UnkeyedEncodingContainer {
            preconditionFailure("An individual writes its values keyed by property.")
        }

        func singleValueContainer() -> any SingleValueEncodingContainer {
            preconditionFailure("An individual writes its values keyed by property.")
        }
    }

    private struct Container<Key: CodingKey>: KeyedEncodingContainerProtocol {
        let values: EncodedValues
        var codingPath: [any CodingKey] { [] }

        mutating func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
            values.record(value, for: key.stringValue)
        }

        mutating func encodeNil(forKey key: Key) throws {}
        mutating func encode(_ value: Bool, forKey key: Key) throws {}
        mutating func encode(_ value: String, forKey key: Key) throws {}
        mutating func encode(_ value: Double, forKey key: Key) throws {}
        mutating func encode(_ value: Float, forKey key: Key) throws {}
        mutating func encode(_ value: Int, forKey key: Key) throws {}
        mutating func encode(_ value: Int8, forKey key: Key) throws {}
        mutating func encode(_ value: Int16, forKey key: Key) throws {}
        mutating func encode(_ value: Int32, forKey key: Key) throws {}
        mutating func encode(_ value: Int64, forKey key: Key) throws {}
        mutating func encode(_ value: UInt, forKey key: Key) throws {}
        mutating func encode(_ value: UInt8, forKey key: Key) throws {}
        mutating func encode(_ value: UInt16, forKey key: Key) throws {}
        mutating func encode(_ value: UInt32, forKey key: Key) throws {}
        mutating func encode(_ value: UInt64, forKey key: Key) throws {}

        mutating func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
            KeyedEncodingContainer(Container<NestedKey>(values: values))
        }

        mutating func nestedUnkeyedContainer(forKey key: Key) -> any UnkeyedEncodingContainer {
            preconditionFailure("An individual writes its values keyed by property.")
        }

        mutating func superEncoder() -> any Encoder { Collector(values: values) }
        mutating func superEncoder(forKey key: Key) -> any Encoder { Collector(values: values) }
    }
}

extension DatatypeValue {
    /// Whether `other` is a value of this value's type, equal to it.
    func isEqual(to other: any DatatypeValue) -> Bool {
        (other as? Self) == self
    }

    /// The value of `lexicalForm` in this value's datatype.
    static func value(of lexicalForm: String) throws -> any DatatypeValue {
        try Self(lexicalForm: lexicalForm)
    }
}

extension XSD.DerivedDatatype {
    /// The declared name of the datatype this one is derived from.
    static var baseName: String { Base.datatype.name }
}

/// The declared name of the base of `datatype`, `nil` for a primitive.
func baseName(of datatype: any DatatypeValue.Type) -> String? {
    (datatype as? any XSD.DerivedDatatype.Type)?.baseName
}

extension RDFCore.Value {
    /// The literal, when the value is one.
    var literalValue: Literal? {
        if case .literal(let literal) = self { return literal }
        return nil
    }
}
