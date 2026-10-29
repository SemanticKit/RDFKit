import RDFCore

/// Generates the Swift model of the terms declared in an ontology's content.
///
/// Attach it to an ``Ontology`` struct and write the content in
/// `func content() -> Content`. Annotations that relate a term to another
/// term take the related type as their argument. The file must import
/// `RDFCore`, whose DSL forms the generated code uses.
///
///     import RDFCore
///     import RDFKit
///
///     @Ontology
///     public struct Fauna: Ontology {
///         public func content() -> Content {
///             Namespace("https://fauna.example.org/ontology#")
///             Class("Animal") {
///                 Type(RDFS.Class)
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
/// This generates:
///
/// - `Fauna.Animal` and `Fauna.Habitat`, protocols for the classes. A
///   class's requirements are the properties with it as `Domain`, typed by
///   their `Range`: `Fauna.Animal` requires
///   `hasHabitat: RDFCore.PropertyValues<any Fauna.Habitat>`. Properties are
///   many-valued; one typed `OWL.FunctionalProperty` has at most one value
///   (`RDFCore.PropertyValue<any Fauna.Habitat>`). Every change to a
///   property's values is atomic. `SubClassOf(Fauna.Animal)`
///   makes a class protocol refine `Fauna.Animal`, so one individual can
///   belong to several classes. A class with no superclass refines
///   `RDFS.Resource`, so every individual has `label` and `comment`.
///   `SubClassOf` can name another ontology's class, such as `OWL.Thing`.
/// - `Fauna.AnimalProperties`, the values of the class's properties, which an
///   individual keeps in its `individualProperties`; `@ClassProtocol`
///   implements the class's properties on them. A property whose `Domain` is
///   another ontology's class becomes a member of every individual of that
///   class through `Fauna.Extending`: RDFS declares `rdfs:domain` for
///   `RDF.Property`, so every `RDF.Property` has `domain`.
/// - `Fauna.AnimalIndividual` and `Fauna.HabitatIndividual`, final classes
///   whose instances are individuals. An individual is a reference, and its
///   identity is the object. It is created in an `RDFCore.IndividualGraph`,
///   which keeps it alive and, when released, frees the cycles among its
///   individuals:
///
///       let graph = IndividualGraph()
///       let savanna = Fauna.HabitatIndividual(in: graph)
///       let lion = Fauna.AnimalIndividual(in: graph, hasHabitat: [savanna])
///       savanna.inhabitedBy.append(lion)
///
/// - a static constant for each `Individual("name")`, `Fauna.name`.
/// - value types for datatypes and literal classes, which store the literal.
/// - the property term type `Fauna.hasHabitat`, which names its `Domain`
///   and `Range` as type aliases.
///
/// RDF, RDFS and OWL are declared with this macro too. The annotations every
/// `content()` is written with are their property terms: `Label("Animal")` is
/// built as `RDFS.label("Animal")` and `Domain(Fauna.Animal)` as
/// `RDFS.domain<Fauna.Animal>()`, both generated from RDFS.swift.
///
/// Terms refer to each other as types. Each term's IRI is computed from the
/// namespace during expansion and kept in its static `metadata`, for the
/// boundary only.
///
/// `@Ontology` also attaches ``OntologyContent()`` to `content()`. That body
/// macro owns the authored body, so `Domain(Fauna.Animal)` is read as syntax
/// and `content()` returns the same declarations built from the generated
/// types.
@attached(member, names: arbitrary)
@attached(memberAttribute)
public macro Ontology() = #externalMacro(module: "RDFKitMacros", type: "OntologyMacro")
