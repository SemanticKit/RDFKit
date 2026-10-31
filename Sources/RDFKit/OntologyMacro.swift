import RDFCore

/// A macro that reads ontology DSL content and generates Entity-conforming types.
///
/// Attach this to an ontology struct to generate entity structs with Metadata.
///
///     @Ontology
///     public struct FOAF: Ontology {
///         public var content: Content {
///             Namespace("http://xmlns.com/foaf/0.1/")
///             Class("Person") {
///                 Type(RDFS.Class)
///                 Label("Person")
///                 Comment("A person.")
///             }
///         }
///     }
@attached(member, names: arbitrary)
public macro Ontology() = #externalMacro(module: "RDFKitMacros", type: "OntologyMacro")
