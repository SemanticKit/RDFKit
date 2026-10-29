import Synchronization

/// The values of the properties of one individual.
///
/// An individual belongs to any number of classes, from any number of
/// ontologies, and each ontology declares properties for its classes. The
/// values of each class's properties live in one ``PropertySet``, and an
/// individual keeps one instance of every set it uses here, created the first
/// time it is read. Each set is found by its type, so a property is stored
/// once however many of the individual's classes have it: an individual of
/// both `OWL.TransitiveProperty` and `OWL.SymmetricProperty` has one
/// `rdfs:domain`.
///
/// The generated property accessors read the sets through the subscript, by
/// the key path of the property inside its set:
///
///     individualProperties[\Fauna.AnimalProperties.hasHabitat]
public final class IndividualProperties: PropertyStorage {
    private let sets = Mutex<[any PropertySet]>([])

    /// Creates the properties of an individual with no values.
    public init() {}

    /// The storage of one property: the property at `property` inside the
    /// individual's set of that type, which is created on first use.
    public subscript<Set: PropertySet, Value>(_ property: KeyPath<Set, Value>) -> Value {
        let set: Set = propertySet()
        return set[keyPath: property]
    }

    private func propertySet<Set: PropertySet>() -> Set {
        sets.withLock { sets in
            for case let existing as Set in sets {
                return existing
            }
            let created = Set()
            sets.append(created)
            return created
        }
    }

    /// Removes every value of every property. ``IndividualGraph`` calls it
    /// when it is released, which breaks every cycle among its individuals.
    public func removeAll() {
        // Remove the values outside the lock: releasing an individual can
        // release others, which must not run while this lock is held.
        let sets = sets.withLock { $0 }
        for set in sets {
            set.removeAll()
        }
    }
}
