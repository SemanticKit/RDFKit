/// The stored values of one property of one individual.
///
/// ``ValueStore`` is the one conformance. An ``IndividualGraph`` empties the
/// stores of its individuals when it is released, which breaks every cycle
/// among them.
protocol PropertyStorage: AnyObject, Sendable {
    /// Removes every value.
    func removeAll()
}
