/// The value of a functional property of an individual.
///
/// An `owl:FunctionalProperty` has at most one value, so the `@Ontology`
/// macro exposes it as a `PropertyValue` of its range: `lion.hasDiet` is a
/// `PropertyValue<any Fauna.Diet>`.
///
/// It is a view on the value the individual's ``Membership`` stores, and it
/// holds the individual's graph, so it keeps working after the individual
/// itself is released. Each change holds a lock for the whole change; use
/// ``update(_:)`` to read and change the value in one step.
///
/// The value of a named individual is fixed; changing it stops the program.
public struct PropertyValue<Value: Sendable>: Sendable {
    private let store: ValueStore<Value>
    private let graph: IndividualGraph?

    /// The value of the requirement `key` names, stored in `membership`.
    ///
    /// The default implementations of class protocol requirements call it:
    /// `RDFCore.PropertyValue(\Self.hasDiet, of: membership)`.
    public init<Root>(_ key: any KeyPath<Root, PropertyValue<Value>> & Sendable, of membership: Membership) {
        store = membership.store(for: key)
        graph = membership.graph
    }

    /// The value of a functional property term for `subject`.
    ///
    /// The static subscript the `@Ontology` macro generates on the term
    /// calls it, after its parameter has checked the term's domain:
    /// `RDFCore.PropertyValue(Self(), of: subject)`.
    public init<Term: PropertyTerm>(_ term: Term, of subject: any Resource) where Term.Range == Value {
        let membership = Membership.of(subject)
        store = membership.store(for: term)
        graph = membership.graph
    }

    /// The value, if the property has one.
    public var value: Value? { store.values(in: graph).first }

    /// Sets the value, or removes it with `nil`.
    public func replace(with value: Value?) {
        store.replace(with: value.map { [$0] } ?? [])
    }

    /// Removes the value.
    public func removeAll() {
        store.replace(with: [])
    }

    /// Reads and changes the value in one atomic step.
    public func update<Result: Sendable>(_ body: (inout Value?) -> Result) -> Result {
        store.update(in: graph) { values in
            var value = values.first
            let result = body(&value)
            values = value.map { [$0] } ?? []
            return result
        }
    }
}
