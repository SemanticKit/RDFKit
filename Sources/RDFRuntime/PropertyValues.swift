import RDFCore

/// The property values of a ``Resource``.
///
/// A generated resource is described by the triples its document states
/// with it as subject. Resources refer to each other, cycles included
/// (`:alice foaf:knows :bob . :bob foaf:knows :alice .`), so the description
/// is read the first time a value is asked for, when every resource it
/// names exists. The values are kept in an ``IndividualStorage`` from then on.
public final class PropertyValues: Sendable {
    /// A property value: a ``Resource`` or an RDF ``Literal``.
    public typealias Value = any Encodable & Sendable

    /// A property and one of its values.
    public typealias Statement = (property: any Resource, value: Value)

    private enum State: Sendable {
        case described(@Sendable () -> [Statement])
        case values([Statement])
    }

    private let storage: IndividualStorage<State>

    /// Creates the property values a description gives.
    public init(_ description: @escaping @Sendable () -> [Statement]) {
        storage = IndividualStorage(.described(description))
    }

    /// Every property and value, in the order the document gives them.
    public var all: [Statement] {
        storage.withLock { state in Self.statements(&state) }
    }

    /// The values of one property.
    public func values(of property: any Resource) -> [Value] {
        all.filter { $0.property === property }.map(\.value)
    }

    /// Replaces the values of one property.
    public func replace(_ property: any Resource, with values: [Value]) {
        storage.withLock { state in
            let others = Self.statements(&state).filter { $0.property !== property }
            state = .values(others + values.map { (property: property, value: $0) })
        }
    }

    private static func statements(_ state: inout State) -> [Statement] {
        switch state {
        case .values(let statements):
            return statements
        case .described(let description):
            let statements = description()
            state = .values(statements)
            return statements
        }
    }
}
