/// An individual whose property values its ``Membership`` stores.
///
/// Every individual type the `@Ontology` macro generates conforms: the
/// individual types of classes (`Fauna.PredatorIndividual`), which are
/// created in an ``IndividualGraph``, and the types of named individuals
/// (`Fauna.carnivore`), which belong to no graph.
///
/// Each class protocol the macro generates has a default implementation of
/// its requirements for stored individuals, so a type that conforms to
/// several class protocols, from this ontology or from others, has every
/// requirement of every one of them without declaring any.
public protocol StoredIndividual: Resource {
    /// The individual's place in its graph, which stores its property values.
    var membership: Membership { get }
}
