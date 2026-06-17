import RDFCore

/// A macro that reads the ontology content tree and generates typed term structs.
///
/// Attach this to an ontology struct to have the compiler generate `{Name}Term`
/// structs and static properties from the DSL content declarations.
///
///     @Vocabulary
///     public struct OWL: Ontology {
///         public var content: Content {
///             Namespace("http://www.w3.org/2002/07/owl#")
///             Class("Thing") {
///                 Type(OWLTerm.Class)
///                 Label("Thing")
///                 Comment("The class of OWL individuals.")
///             }
///         }
///     }
///
/// This generates:
/// - `OWL.ThingTerm` — a struct conforming to `OntologyTerm`, `TypedTerm`, `LabeledTerm`, `CommentedTerm`
/// - `OWL.Thing` — a static property returning an instance of `ThingTerm`
@attached(member, names: arbitrary)
public macro Vocabulary() = #externalMacro(module: "RDFKitMacros", type: "VocabularyMacro")
