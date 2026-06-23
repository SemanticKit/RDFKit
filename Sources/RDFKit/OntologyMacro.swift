import RDFCore

/// A macro that reads ontology DSL content and generates Entity-conforming types.
///
/// Attach this to an ontology struct to generate entity structs with Metadata.
///
///     @Ontology
///     public struct Fauna: Ontology {
///         public var content: Content {
///             Namespace("https://fauna.example.org/ontology#")
///             Class("Animal") {
///                 Type(RDFS.Class)
///                 Label("Animal")
///                 Comment("The class of all animals.")
///             }
///         }
///     }
@attached(member, names: arbitrary)
public macro Ontology() = #externalMacro(module: "RDFKitMacros", type: "OntologyMacro")
