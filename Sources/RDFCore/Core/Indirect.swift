/// Stores a value out of line, so a generated type can hold a property whose
/// range is the type itself (`rdf:rest` on `RDF.List`) or a type that holds
/// it back.
///
/// The `@Ontology` macro applies it only to stored properties that would
/// otherwise make a generated struct recursive. The property is still typed by
/// its range.
@propertyWrapper
public struct Indirect<Value: Sendable>: Sendable {
    private final class Storage: Sendable {
        let value: Value
        init(_ value: Value) { self.value = value }
    }

    private var storage: Storage

    public init(wrappedValue: Value) {
        self.storage = Storage(wrappedValue)
    }

    public var wrappedValue: Value {
        get { storage.value }
        set { storage = Storage(newValue) }
    }
}
