import Foundation
import RDFCore

/// The RDF ontology.
public struct RDF: Ontology {
    public var content: Content {
        Prefix.rdf
        Prefix.rdfs
        Prefix.owl
        Prefix.dc

        Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#")

        Class("Alt") {
            Type(RDFSTerm.Class)
            SubClassOf(RDFSTerm.Container)
            Label("Alt")
            Comment("The class of containers of alternatives.")
        }
        Class("Bag") {
            Type(RDFSTerm.Class)
            SubClassOf(RDFSTerm.Container)
            Label("Bag")
            Comment("The class of unordered containers.")
        }
        Class("CompoundLiteral") {
            Type(RDFSTerm.Class)
            SubClassOf(RDFSTerm.Resource)
            SeeAlso(
                "https://www.w3.org/TR/json-ld11/#the-rdf-compoundliteral-class-and-the-rdf-language-and-rdf-direction-properties"
            )
            Label("CompoundLiteral")
            Comment("A class representing a compound literal.")
        }
        Datatype("HTML") {
            Type(RDFSTerm.Datatype)
            SubClassOf(RDFSTerm.Literal)
            SeeAlso("http://www.w3.org/TR/rdf11-concepts/#section-html")
            Label("HTML")
            Comment(
                "The datatype of RDF literals storing fragments of HTML content"
            )
        }
        Datatype("JSON") {
            Type(RDFSTerm.Datatype)
            SubClassOf(RDFSTerm.Literal)
            SeeAlso("https://www.w3.org/TR/rdf-concepts/#section-json")
            Label("JSON")
            Comment("The datatype of RDF literals storing JSON content.")
        }
        Datatype("dirLangString") {
            Type(RDFSTerm.Datatype)
            SubClassOf(RDFSTerm.Literal)
            Label("dirLangString")
            Comment(
                "The datatype of directional language-tagged string values, which includes a language tag and a base direction (either 'ltr' or 'rtl')"
            )
        }
        Datatype("langString") {
            Type(RDFSTerm.Datatype)
            SubClassOf(RDFSTerm.Literal)
            SeeAlso(
                "http://www.w3.org/TR/rdf11-concepts/#section-Graph-Literal"
            )
            Label("langString")
            Comment("The datatype of language-tagged string values")
        }
        Class("List") {
            Type(RDFSTerm.Class)
            SubClassOf(RDFSTerm.Resource)
            Label("List")
            Comment("The class of RDF Lists.")
        }
        Individual("nil") {
            Type(RDFTerm.List)
            Label("nil")
            Comment(
                "The empty list, with no items in it. If the rest of a list is nil then the list has no more items in it."
            )
        }

        Datatype("PlainLiteral") {
            Type(RDFSTerm.Datatype)
            SubClassOf(RDFSTerm.Literal)
            SeeAlso("http://www.w3.org/TR/rdf-plain-literal/")
            Label("PlainLiteral")
            Comment(
                "The class of plain (i.e., untyped) literal values, as used in RIF and OWL 2.  Will not be removed until no longer needed there."
            )
            OWLDeprecated()
        }
        Class("Property") {
            Type(RDFSTerm.Class)
            SubClassOf(RDFSTerm.Resource)
            Label("Property")
            Comment("The class of RDF properties.")
        }
        Class("PropositionForm") {
            Type(RDFSTerm.Class)
            SubClassOf(RDFSTerm.Resource)
            SeeAlso("https://www.w3.org/TR/rdf12-interop/")
            Label("PropositionForm")
            Comment(
                "The class of abstract, atomic proposition forms. Reserved for basic encoding of propositions."
            )
        }
        Class("Seq") {
            Type(RDFSTerm.Class)
            SubClassOf(RDFSTerm.Container)
            Label("Seq")
            Comment("The class of ordered containers.")
        }
        Class("Statement") {
            Type(RDFSTerm.Class)
            SubClassOf(RDFSTerm.Resource)
            Label("Statement")
            Comment("The class of RDF statements.")
        }
        Property("direction") {
            Type(RDFTerm.Property)
            Domain(RDFTerm.CompoundLiteral)
            SeeAlso(
                "https://www.w3.org/TR/json-ld11/#the-rdf-compoundliteral-class-and-the-rdf-language-and-rdf-direction-properties"
            )
            Label("direction")
            Comment("The base direction component of a CompoundLiteral.")
        }
        Property("first") {
            Type(RDFTerm.Property)
            Domain(RDFTerm.List)
            Range(RDFSTerm.Resource)
            Label("first")
            Comment("The first item in the subject RDF list.")
        }
        Property("language") {
            Type(RDFTerm.Property)
            Domain(RDFTerm.CompoundLiteral)
            SeeAlso(
                "https://www.w3.org/TR/json-ld11/#the-rdf-compoundliteral-class-and-the-rdf-language-and-rdf-direction-properties"
            )
            Label("language")
            Comment("The language component of a CompoundLiteral.")
        }
        Property("object") {
            Type(RDFTerm.Property)
            Domain(RDFTerm.Statement)
            Range(RDFSTerm.Resource)
            Label("object")
            Comment("The object of the subject RDF statement.")
        }
        Property("predicate") {
            Type(RDFTerm.Property)
            Domain(RDFTerm.Statement)
            Range(RDFSTerm.Resource)
            Label("predicate")
            Comment("The predicate of the subject RDF statement.")
        }
        Property("propositionFormObject") {
            Type(RDFTerm.Property)
            Domain(RDFTerm.PropositionForm)
            Range(RDFSTerm.Resource)
            SeeAlso("https://www.w3.org/TR/rdf12-interop/")
            Label("propositionFormObject")
            Comment(
                "The object component of a proposition form. Reserved for basic encoding of propositions."
            )
        }
        Property("propositionFormPredicate") {
            Type(RDFTerm.Property)
            Domain(RDFTerm.PropositionForm)
            Range(RDFTerm.Property)
            SeeAlso("https://www.w3.org/TR/rdf12-interop/")
            Label("propositionFormPredicate")
            Comment(
                "The predicate component of a proposition form. Reserved for basic encoding of propositions."
            )
        }
        Property("propositionFormSubject") {
            Type(RDFTerm.Property)
            Domain(RDFTerm.PropositionForm)
            Range(RDFSTerm.Resource)
            SeeAlso("https://www.w3.org/TR/rdf12-interop/")
            Label("propositionFormSubject")
            Comment(
                "The subject component of a proposition form. Reserved for basic encoding of propositions."
            )
        }
        Property("reifies") {
            Type(RDFTerm.Property)
            Domain(RDFSTerm.Resource)
            Range(RDFSTerm.Proposition)
            Label("reifies")
            Comment("The abstract proposition of a more concrete circumstance.")
        }
        Property("rest") {
            Type(RDFTerm.Property)
            Domain(RDFTerm.List)
            Range(RDFTerm.List)
            Label("rest")
            Comment("The rest of the subject RDF list after the first item.")
        }
        Property("subject") {
            Type(RDFTerm.Property)
            Domain(RDFTerm.Statement)
            Range(RDFSTerm.Resource)
            Label("subject")
            Comment("The subject of the subject RDF statement.")
        }
        Property("type") {
            Type(RDFTerm.Property)
            Domain(RDFSTerm.Resource)
            Range(RDFSTerm.Class)
            Label("type")
            Comment("The subject is an instance of a class.")
        }
        Property("value") {
            Type(RDFTerm.Property)
            Domain(RDFSTerm.Resource)
            Range(RDFSTerm.Resource)
            Label("value")
            Comment("Idiomatic property used for structured values.")
        }
        Datatype("XMLLiteral") {
            Type(RDFSTerm.Datatype)
            SubClassOf(RDFSTerm.Literal)
            Label("XMLLiteral")
            Comment("The datatype of XML literal values.")
        }
        Individual("version-1.0") {
            Type(RDFSTerm.Resource)
            Label("1.0")
            Comment("Version 1.0")
        }
        Individual("version-1.1") {
            Type(RDFSTerm.Resource)
            Label("1.1")
            Comment("Version 1.1")
        }
        Individual("version-1.2") {
            Type(RDFSTerm.Resource)
            Label("1.2")
            Comment("Version 1.2.")
        }
        Individual("version-1.2-basic") {
            Type(RDFSTerm.Resource)
            Label("1.2-basic")
            Comment("Version 1.2-basic")
        }
    }
}
