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
///                 Type(RDFS.Class)
///                 Label("Person")
///                 Comment("A person.")
///             }
///         }
///     }
@attached(member, names: arbitrary)
@attached(memberAttribute)
public macro Ontology() = #externalMacro(module: "RDFKitMacros", type: "OntologyMacro")

/// Owns an ontology's authored `var body`, so its declarations are read as
/// syntax: `Type(RDFS.Class)` and `Class(...)` as written.
///
/// `@Ontology` attaches it to `var body`; it is not written by hand.
@attached(body)
public macro OntologyBody() = #externalMacro(module: "RDFKitMacros", type: "OntologyBodyMacro")
