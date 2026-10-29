/// Terms that RDFCore already provides as DSL forms.
///
/// RDF, RDFS and OWL describe themselves: `rdfs:Class` is declared with
/// `Class(...)`, `rdfs:label` with `Label(...)`. When an ontology declares one
/// of these terms, the macro does not generate a second Swift type for the same
/// term. It aliases the RDFCore form, so one term has one Swift type.
enum BootstrapTerm {
    /// The RDFCore form for a term, and whether that form is generic over a term.
    static func form(namespace: String, name: String) -> (type: String, isGeneric: Bool)? {
        switch (namespace, name) {
        case (rdfs, "Class"): ("Class", false)
        case (rdf, "Property"): ("Property", false)
        case (rdfs, "Datatype"): ("Datatype", false)
        case (owl, "NamedIndividual"): ("Individual", false)
        case (rdfkit, "Namespace"): ("Namespace", false)
        case (rdfkit, "Prefix"): ("Prefix", false)
        case (rdf, "type"): ("Type", true)
        case (rdfs, "domain"): ("Domain", true)
        case (rdfs, "range"): ("Range", true)
        case (rdfs, "subClassOf"): ("SubClassOf", true)
        case (rdfs, "subPropertyOf"): ("SubPropertyOf", true)
        case (rdfs, "label"): ("Label", false)
        case (rdfs, "comment"): ("Comment", false)
        case (rdfs, "seeAlso"): ("SeeAlso", false)
        case (owl, "deprecated"): ("Deprecated", false)
        default: nil
        }
    }

    /// The Swift value type that stores a literal of a datatype range.
    ///
    /// A property whose range is a literal datatype is stored as the Swift
    /// value type for that datatype. Every other range is stored as its own
    /// generated type.
    static func literalValueType(forRange spelling: String) -> String? {
        switch spelling {
        case "RDFS.Literal": "String"
        case "XSD.nonNegativeInteger": "UInt"
        default: nil
        }
    }

    /// DSL declaration forms. A generated term with one of these names shadows
    /// the RDFCore form inside its ontology, so it is generated as a
    /// declaration form itself (for example `OWL.Class`).
    static let declarationForms: Set<String> = ["Class", "Property", "Datatype", "Individual"]

    private static let rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    private static let rdfs = "http://www.w3.org/2000/01/rdf-schema#"
    private static let owl = "http://www.w3.org/2002/07/owl#"
    private static let rdfkit = "http://semantickit.io/o/2026/06/rdfkit#"
}
