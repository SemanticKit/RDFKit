/// Terms that RDFCore already provides, and the RDF, RDFS and OWL terms whose
/// meaning changes what the macro generates.
///
/// RDF, RDFS and OWL describe themselves: `rdfs:label` is declared with
/// `Property("label")` and written in content as `Label(...)`. When an
/// ontology declares one of the terms RDFCore provides, the macro does not
/// generate a second Swift type for the same term. It aliases the RDFCore
/// type, so one term has one Swift type.
enum BootstrapTerm {
    /// The RDFCore type for a term, and whether that type is generic over a term.
    static func form(namespace: String, name: String) -> (type: String, isGeneric: Bool)? {
        switch (namespace, name) {
        case (rdfs, "Resource"): ("Resource", false)
        case (rdfkit, "Namespace"): ("Namespace", false)
        case (rdfkit, "Prefix"): ("Prefix", false)
        case (rdf, "type"): (typeForm, true)
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

    /// The RDFCore form of `rdf:type`.
    static let typeForm = "Type"

    /// Whether a qualified spelling names `rdfs:Literal`, the class of
    /// literal values. It and its subclasses are value types.
    static func isLiteral(_ spelling: String) -> Bool {
        unqualified(spelling) == "RDFS.Literal"
    }

    /// Whether a qualified spelling names `rdfs:Resource`, the root of every
    /// class, which RDFCore provides as ``Resource`` with no requirements.
    static func isResource(_ spelling: String) -> Bool {
        let term = unqualified(spelling)
        return term == "RDFS.Resource" || term == "RDFCore.Resource"
    }

    /// Whether a qualified spelling of another ontology's term names a
    /// datatype or literal class of XSD, RDFS or RDF, whose values are
    /// literals.
    static func isDatatype(_ spelling: String) -> Bool {
        let term = unqualified(spelling)
        return term.hasPrefix("XSD.") || isLiteral(term) || rdfDatatypes.contains(term)
    }

    private static let rdfDatatypes: Set<String> = [
        "RDF.CompoundLiteral", "RDF.HTML", "RDF.JSON", "RDF.PlainLiteral",
        "RDF.XMLLiteral", "RDF.dirLangString", "RDF.langString",
    ]

    /// Whether a qualified spelling names `owl:Thing`, the class of every
    /// individual.
    static func isThing(_ spelling: String) -> Bool {
        unqualified(spelling) == "OWL.Thing"
    }

    /// Whether a qualified spelling names `owl:Nothing`, the class with no
    /// individuals, which therefore has no individual type.
    static func isNothing(_ spelling: String) -> Bool {
        unqualified(spelling) == "OWL.Nothing"
    }

    /// Whether a qualified spelling names `owl:FunctionalProperty`. A
    /// property typed with it has at most one value.
    static func isFunctionalProperty(_ spelling: String) -> Bool {
        unqualified(spelling) == "OWL.FunctionalProperty"
    }

    /// A spelling without its module: `RDFKit.OWL.FunctionalProperty` is
    /// `OWL.FunctionalProperty`. A term is an ontology's nested type, so only
    /// its last two components name it.
    private static func unqualified(_ spelling: String) -> String {
        let components = spelling.split(separator: ".")
        guard components.count > 2 else { return spelling }
        return components.suffix(2).joined(separator: ".")
    }

    private static let rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    private static let rdfs = "http://www.w3.org/2000/01/rdf-schema#"
    private static let owl = "http://www.w3.org/2002/07/owl#"
    private static let rdfkit = "http://semantickit.io/o/2026/06/rdfkit#"
}
