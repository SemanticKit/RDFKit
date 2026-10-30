import RDFCore

/// Generates the Swift model of the terms declared in an ontology's content.
///
/// Attach it to an ``Ontology`` struct and write the content in
/// `var body: some Content`, as a SwiftUI view's `body` is `some View`.
/// Annotations that relate a term to another term take the related type as
/// their argument. The generated code uses `RDFCore`, `IRIKit` and the
/// translated RDF vocabulary, `RDF`, so the file imports them:
///
///     import IRIKit
///     import RDF
///     import RDFCore
///     import RDFKit
///
///     @Ontology
///     public struct Fauna: Ontology {
///         public var body: some Content {
///             Namespace("https://fauna.example.org/ontology#")
///             Class("Animal") {
///                 Type(RDF.Class)
///                 Comment("The class of all animals.")
///             }
///             Class("Habitat")
///             Property("hasHabitat") {
///                 Domain(Fauna.Animal)
///                 Range(Fauna.Habitat)
///             }
///         }
///     }
///
/// This generates the Swift `RDFTranslatorPlugin` writes for the same
/// vocabulary in RDF, on the same runtime:
///
/// - `Fauna.Animal` and `Fauna.Habitat`, protocols for the classes. A
///   class's requirements are the properties with it as `Domain`, typed by
///   their `Range`: `Fauna.Animal` requires `hasHabitat: [any Fauna.Habitat]`.
///   `SubClassOf(Fauna.Animal)` makes a class protocol refine
///   `Fauna.Animal`, so one individual can belong to several classes; a
///   class with no superclass refines `RDF.Resource`.
/// - `Fauna.AnimalIndividual` and `Fauna.HabitatIndividual`, final classes
///   whose instances are the members of the classes, keeping their property
///   values in an ``RDFCore/IndividualStorage``. An individual is a
///   reference, and its identity is the object:
///
///       let savanna = Fauna.HabitatIndividual()
///       let lion = Fauna.AnimalIndividual()
///       lion.hasHabitat = [savanna]
///
/// - the property term type `Fauna.hasHabitat`, and the value type and
///   storing protocol that keep its values on an individual.
/// - for `Individual("tweety") { Type(Fauna.Animal) }`, the named individual
///   (`owl:NamedIndividual`, OWL 2 Structural Specification §5.6): the one
///   instance of a final class of its own, `Fauna.tweetyIndividual`, which
///   conforms to the storing protocol of each class its `Type` gives
///   (ClassAssertion, §9.6.1), so it is a `Fauna.Animal`. The
///   ontology member `tweety` gives that instance.
/// - DocC from each `Label` and `Comment`, and `@available(*, deprecated)` on
///   the declarations of a term marked `Deprecated()`.
///
/// Statements about one term may be split over several declarations of it
/// with the same form, as an RDF graph is a set of triples: they generate
/// one term with everything each declaration states.
///
/// Terms refer to each other as types. No generated type stores an IRI:
/// each carries its declared name in the ontology, and an encoder derives
/// the IRI from it and the `Namespace` when the term leaves the runtime.
///
/// The DSL is for authored ontologies. W3C vocabularies (`rdf`, `rdfs`,
/// `owl`, `shacl`, ...) and their individuals come from translating their
/// published Turtle with `RDFTranslatorPlugin`, and data such as a profile
/// document is decoded or translated, never written as an `@Ontology`.
///
/// `@Ontology` also attaches ``OntologyContent()`` to `var body`. That body
/// macro owns the authored body, so `Domain(Fauna.Animal)` is read as syntax.
@attached(member, names: arbitrary)
@attached(memberAttribute)
public macro Ontology() = #externalMacro(module: "RDFKitMacros", type: "OntologyMacro")
