/// The RDF, RDFS and OWL terms whose meaning changes what the macro
/// generates, by their qualified Swift spelling.
///
/// RDF, RDFS and OWL describe themselves: `rdfs:label` is declared in
/// RDFS.swift with `Property("label")`, and every ontology's content is
/// written with it as `Label(...)`. The macro generates `RDFS.label` from that
/// declaration as an annotation type, and the content body macro writes each
/// `Label(...)` as `RDFS.label(...)`. Every key here is the Swift type a
/// declaration generates, the spelling every other ontology uses to name the
/// term. No IRI is involved.
enum BootstrapTerm {
    /// `rdfs:Resource`, the class of everything: the class protocol that a
    /// class with no superclass refines.
    static let resource = "RDFS.Resource"

    /// The extension points of RDF, RDFS and OWL, which `rdfs:Resource`, the
    /// class of everything, refines. Each ontology declares properties for
    /// the others' classes (RDFS declares `rdfs:domain` for `rdf:Property`,
    /// OWL declares `owl:equivalentClass` for `rdfs:Class`), and they become
    /// members of every individual in their domain through these protocols.
    /// RDF, RDFS and OWL always generate their extension point, empty or
    /// not, so this list never names a protocol that does not exist. Any
    /// other ontology's extension point reaches its own classes and named
    /// individuals, not `rdfs:Resource`, because no class of another
    /// ontology can refine it.
    static let extensionPoints = ["RDF.Extending", "RDFS.Extending", "OWL.Extending"]

    /// How a property the DSL is written with is written in content.
    enum AnnotationForm: Equatable {
        /// Carries text: `Label("Animal")`.
        case text
        /// Carries the address of a document readers dereference:
        /// `SeeAlso("https://www.w3.org/TR/rdf12-schema/")`.
        case document
        /// Carries nothing: `Deprecated()`.
        case flag
        /// Relates the declared term to another term, given as its type:
        /// `Domain(Fauna.Animal)`.
        case term
    }

    /// The annotation form of a property term, by its qualified spelling.
    static func annotationForm(of spelling: String) -> AnnotationForm? {
        switch spelling {
        case "RDFS.label", "RDFS.comment": .text
        case "RDFS.seeAlso": .document
        case "OWL.deprecated": .flag
        case "RDF.type", "RDFS.domain", "RDFS.range", "RDFS.subClassOf", "RDFS.subPropertyOf": .term
        default: nil
        }
    }

    /// The property term an annotation written in content stands for:
    /// `Label` is `RDFS.label`.
    static func term(writtenAs form: String) -> String? {
        switch form {
        case "Label": "RDFS.label"
        case "Comment": "RDFS.comment"
        case "SeeAlso": "RDFS.seeAlso"
        case "Deprecated": "OWL.deprecated"
        case "Type": "RDF.type"
        case "Domain": "RDFS.domain"
        case "Range": "RDFS.range"
        case "SubClassOf": "RDFS.subClassOf"
        case "SubPropertyOf": "RDFS.subPropertyOf"
        default: nil
        }
    }

    /// The RDFCore type for a term of RDFKit's own vocabulary, by the term's
    /// qualified spelling, and whether that type is generic over a term.
    /// RDFKit declares `Namespace` and `Prefix`, which content is written
    /// with and RDFCore provides as values.
    static func form(of spelling: String) -> (type: String, isGeneric: Bool)? {
        switch spelling {
        case "RDFKit.Namespace": ("Namespace", false)
        case "RDFKit.Prefix": ("Prefix", false)
        default: nil
        }
    }

    /// Whether a qualified spelling names `rdfs:Literal`, the class of
    /// literal values. It and its subclasses are value types.
    static func isLiteral(_ spelling: String) -> Bool {
        unqualified(spelling) == "RDFS.Literal"
    }

    /// Whether a qualified spelling names `rdfs:Resource`.
    static func isResource(_ spelling: String) -> Bool {
        unqualified(spelling) == resource
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

    /// Whether a qualified spelling names `rdf:type`. Class membership is
    /// the Swift type of an individual, the protocols its type conforms to,
    /// so `rdf:type` is never stored as a property value.
    static func isType(_ spelling: String) -> Bool {
        unqualified(spelling) == "RDF.type"
    }

    /// A spelling without its module: `RDFKit.OWL.FunctionalProperty` is
    /// `OWL.FunctionalProperty`. A term is an ontology's nested type, so only
    /// its last two components name it.
    static func unqualified(_ spelling: String) -> String {
        let components = spelling.split(separator: ".")
        guard components.count > 2 else { return spelling }
        return components.suffix(2).joined(separator: ".")
    }
}
