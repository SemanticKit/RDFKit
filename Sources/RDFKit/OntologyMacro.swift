/// Generates the Swift types an ontology's body declares.
///
/// Each class becomes a protocol nested in the ontology, and its
/// `SubClassOf` classes become the protocols it inherits:
///
///     @Ontology
///     public struct FOAF: Ontology {
///         public var body: some Content {
///             Namespace("http://xmlns.com/foaf/0.1/")
///             Class("Person") {
///                 Type(RDFS.Class.self)
///                 Label("Person")
///                 Comment("A person.")
///             }
///         }
///     }
@attached(member, names: arbitrary)
public macro Ontology() = #externalMacro(module: "RDFKitMacros", type: "OntologyMacro")
