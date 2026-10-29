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

    /// Whether a qualified spelling names `rdfs:Resource`.
    static func isResource(_ spelling: String) -> Bool {
        spelling == resource
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
}
