/// What a module states about a resource that a module it builds on
/// declares, such as FOAF's `owl:Thing rdfs:label "Thing"`.
///
/// The resource keeps its one declaration; the addition refers to it.
public protocol Addition: Description {
    /// The resource the triples are about.
    var resource: Value { get }
}
