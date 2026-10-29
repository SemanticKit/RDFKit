import RDFCore

/// Generates one Swift type per term declared in an ontology's content.
///
/// Attach it to an ``Ontology`` struct. The file must import `RDFCore`, whose
/// DSL forms the generated code uses.
///
///     import RDFCore
///     import RDFKit
///
///     @Ontology
///     public struct Fauna: Ontology {
///         public var content: Content {
///             Namespace("https://fauna.example.org/ontology#")
///             Class("Animal") {
///                 Type<RDFS.Class>()
///                 Comment("The class of all animals.")
///             }
///             Class("Habitat")
///             Property("hasHabitat") {
///                 Domain<Fauna.Animal>()
///                 Range<Fauna.Habitat>()
///             }
///         }
///     }
///
/// This generates `Fauna.Animal`, `Fauna.Habitat` and the property term
/// `Fauna.hasHabitat`. `Fauna.Animal` has a stored property
/// `hasHabitat: Fauna.Habitat`, typed by the property's range, and an
/// initializer `init(habitat:)`. Terms refer to each other as types; each
/// type's IRI is computed from the namespace during expansion and kept in its
/// static `metadata`, for the boundary only.
@attached(member, names: arbitrary)
public macro Ontology() = #externalMacro(module: "RDFKitMacros", type: "OntologyMacro")
