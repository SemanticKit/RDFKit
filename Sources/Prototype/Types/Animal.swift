import Synchronization

// MARK: - Example: Fauna.Animal

/// An example of the protocol the macro generates for `Class("Animal")`.
///
/// Its requirements are the properties with `Animal` as domain, typed by
/// their range: `hasHabitat` holds ``Habitat`` individuals, not IRIs.
/// Properties are many-valued; the functional ones (`hasDiet`,
/// `scientificName`) have at most one value.
public protocol Animal: AnyObject, Sendable {
    var hasHabitat: [any Habitat] { get set }
    var hasDiet: (any Diet)? { get set }
    var commonName: [String] { get set }
    var scientificName: String? { get set }
}

/// An example of the individual type the macro generates for
/// `Class("Animal")`: a final class whose instances are animals. Its
/// identity is the object; its values are guarded by a mutex.
public final class AnimalIndividual: Animal {
    private struct Values: Sendable {
        var hasHabitat: [any Habitat]
        var hasDiet: (any Diet)?
        var commonName: [String]
        var scientificName: String?
    }

    private let storage: Mutex<Values>

    public init(
        hasHabitat: [any Habitat] = [],
        hasDiet: (any Diet)? = nil,
        commonName: [String] = [],
        scientificName: String? = nil
    ) {
        storage = Mutex(Values(hasHabitat: hasHabitat, hasDiet: hasDiet, commonName: commonName, scientificName: scientificName))
    }

    public var hasHabitat: [any Habitat] {
        get { storage.withLock { $0.hasHabitat } }
        set { storage.withLock { $0.hasHabitat = newValue } }
    }

    public var hasDiet: (any Diet)? {
        get { storage.withLock { $0.hasDiet } }
        set { storage.withLock { $0.hasDiet = newValue } }
    }

    public var commonName: [String] {
        get { storage.withLock { $0.commonName } }
        set { storage.withLock { $0.commonName = newValue } }
    }

    public var scientificName: String? {
        get { storage.withLock { $0.scientificName } }
        set { storage.withLock { $0.scientificName = newValue } }
    }
}


// MARK: Generated Type Metadata

extension AnimalIndividual: Entity {
    public static let metadata: any ContentMetadata = Class.ClassMetadata(
        id: "https://fauna.example.org/ontology#Animal",
        name: "Animal",
        label: "Animal",
        comment: "The class of all animals."
    )
}
