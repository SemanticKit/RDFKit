import RDFCore

/// Generates the Swift model of the terms declared in an ontology's content.
///
/// Attach it to an ``Ontology`` struct and write the content in
/// `var body: some Content`, as a SwiftUI view's `body` is `some View`.
/// Annotations that relate a term to another term take the related type as
/// their argument. The generated code uses `RDFCore`, `IRIKit` and the
/// translated RDF vocabulary, `RDF`, so the file imports them. A property
/// whose `Range` is an XSD datatype holds that datatype's Swift value type
/// (`Range(XSD.gYear)` gives `[XSD.gYear]`), and `Deprecated()` writes
/// `owl:deprecated` with the `xsd:boolean` value `true`, so a file that uses
/// them imports `XSD`, and `OWL` for `Deprecated()`, too:
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
/// - DocC from each `Comment`, and `@available(*, deprecated)` on the
///   declarations of a term marked `Deprecated()`, whose description states
///   `owl:deprecated true`.
///
/// Terms refer to each other as types. Each term's IRI is computed from the
/// namespace during expansion, for the boundary only.
///
/// The DSL declares vocabulary, not data. A named individual comes from RDF
/// that `RDFTranslatorPlugin` translates, as a module-level value (`alice`),
/// never a member of the ontology type.
///
/// `@Ontology` also attaches ``OntologyContent()`` to `var body`. That body
/// macro owns the authored body, so `Domain(Fauna.Animal)` is read as syntax.
@attached(member, names: arbitrary)
@attached(memberAttribute)
public macro Ontology() = #externalMacro(module: "RDFKitMacros", type: "OntologyMacro")
