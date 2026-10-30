/// Terms that RDFCore already provides, and the RDF, RDFS and OWL terms whose
/// meaning changes what the macro generates.
///
/// RDF, RDFS and OWL describe themselves: `rdfs:label` is declared with
/// `Property("label")` and written in content as `Label(...)`. When an
/// ontology declares one of the terms RDFCore provides, the macro does not
/// generate a second Swift type for the same term. It aliases the RDFCore
/// type, so one term has one Swift type. The terms that relate one term to
/// another (`rdf:type`, `rdfs:domain`, `rdfs:range`, `rdfs:subClassOf`,
/// `rdfs:subPropertyOf`) have no RDFCore type: the macro writes them as
/// Swift declarations, and their own declarations are property term types.
enum BootstrapTerm {
    /// The RDFCore type for a term.
    static func form(namespace: String, name: String) -> String? {
        switch (namespace, name) {
        case (rdfs, "Resource"): "Resource"
        case (rdfkit, "Namespace"): "Namespace"
        case (rdfkit, "Prefix"): "Prefix"
        case (rdfs, "label"): "Label"
        case (rdfs, "comment"): "Comment"
        case (rdfs, "seeAlso"): "SeeAlso"
        case (owl, "deprecated"): "Deprecated"
        default: nil
        }
    }

    /// The Swift value type that stores a literal of a literal range, by the
    /// range's qualified spelling.
    ///
    /// A property whose range is one of these is stored as the Swift value
    /// type. Every other range is stored as its own generated type.
    static func literalValueType(forRange spelling: String) -> String? {
        switch spelling {
        case "RDFS.Literal": "String"
        case "XSD.nonNegativeInteger": "UInt"
        default: nil
        }
    }

    /// Whether a qualified spelling names `rdfs:Literal`, the class of
    /// literal values. It and its subclasses are value types.
    static func isLiteral(_ spelling: String) -> Bool {
        spelling == "RDFS.Literal"
    }

    /// Whether a qualified spelling names `rdfs:Resource`, the root of every
    /// class, which RDFCore provides as ``Resource`` with no requirements.
    static func isResource(_ spelling: String) -> Bool {
        spelling == "RDFS.Resource" || spelling == "RDFCore.Resource"
    }

    /// Whether a qualified spelling names `owl:Nothing`, the class with no
    /// individuals, which therefore has no individual type.
    static func isNothing(_ spelling: String) -> Bool {
        spelling == "OWL.Nothing"
    }

    /// Whether a qualified spelling names `owl:FunctionalProperty`. A
    /// property typed with it has at most one value.
    static func isFunctionalProperty(_ spelling: String) -> Bool {
        spelling == "OWL.FunctionalProperty"
    }

    private static let rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    private static let rdfs = "http://www.w3.org/2000/01/rdf-schema#"
    private static let owl = "http://www.w3.org/2002/07/owl#"
    private static let rdfkit = "http://semantickit.io/o/2026/06/rdfkit#"
}
