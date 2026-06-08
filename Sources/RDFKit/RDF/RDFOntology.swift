import Foundation

public extension RDF {
    /// The RDF standard ontology authored as Swift content.
    static var ontology: some Content {
        RDFOntology().content
    }
}

/// RDF standard ontology content authored with ontology declarations.
private struct RDFOntology: Ontology {
    var content: some Content {
        Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
        Alias("rdf", Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#"))
        Alias("rdfs", Namespace("http://www.w3.org/2000/01/rdf-schema#"))
        Alias("owl", Namespace("http://www.w3.org/2002/07/owl#"))

        Class("Alt") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Container.self)
            IsDefinedBy()
            Label("Alt")
            Comment("The class of containers of alternatives.")
        }
        Class("Bag") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Container.self)
            IsDefinedBy()
            Label("Bag")
            Comment("The class of unordered containers.")
        }
        Class("CompoundLiteral") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Resource.self)
            IsDefinedBy()
            SeeAlso(IRI("https://www.w3.org/TR/json-ld11/#the-rdf-compoundliteral-class-and-the-rdf-language-and-rdf-direction-properties"))
            Label("CompoundLiteral")
            Comment("A class representing a compound literal.")
        }
        Datatype("HTML") {
            Type(RDFS.Datatype.self)
            SubClassOf(RDFS.Literal.self)
            IsDefinedBy()
            SeeAlso(IRI("http://www.w3.org/TR/rdf11-concepts/#section-html"))
            Label("HTML")
            Comment("The datatype of RDF literals storing fragments of HTML content")
        }
        Datatype("JSON") {
            Type(RDFS.Datatype.self)
            SubClassOf(RDFS.Literal.self)
            IsDefinedBy()
            SeeAlso(IRI("https://www.w3.org/TR/rdf-concepts/#section-json"))
            Label("JSON")
            Comment("The datatype of RDF literals storing JSON content.")
        }
        Datatype("dirLangString") {
            Type(RDFS.Datatype.self)
            SubClassOf(RDFS.Literal.self)
            IsDefinedBy()
            Label("dirLangString")
            Comment("The datatype of directional language-tagged string values, which includes a language tag and a base direction (either 'ltr' or 'rtl')")
        }
        Datatype("langString") {
            Type(RDFS.Datatype.self)
            SubClassOf(RDFS.Literal.self)
            IsDefinedBy()
            SeeAlso(IRI("http://www.w3.org/TR/rdf11-concepts/#section-Graph-Literal"))
            Label("langString")
            Comment("The datatype of language-tagged string values")
        }
        Class("List") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Resource.self)
            IsDefinedBy()
            Label("List")
            Comment("The class of RDF Lists.")
        }
        Individual("nil") {
            Type(RDF.List.self)
            IsDefinedBy()
            Label("nil")
            Comment("The empty list, with no items in it. If the rest of a list is nil then the list has no more items in it.")
        }
        Datatype("PlainLiteral") {
            Type(RDFS.Datatype.self)
            SubClassOf(RDFS.Literal.self)
            IsDefinedBy()
            SeeAlso(IRI("http://www.w3.org/TR/rdf-plain-literal/"))
            Label("PlainLiteral")
            Comment("The class of plain (i.e., untyped) literal values, as used in RIF and OWL 2.  Will not be removed until no longer needed there.")
            OWLDeprecated()
        }
        Class("Property") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Resource.self)
            IsDefinedBy()
            Label("Property")
            Comment("The class of RDF properties.")
        }
        Class("PropositionForm") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Resource.self)
            IsDefinedBy()
            SeeAlso(IRI("https://www.w3.org/TR/rdf12-interop/"))
            Label("PropositionForm")
            Comment("The class of abstract, atomic proposition forms. Reserved for basic encoding of propositions.")
        }
        Class("Seq") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Container.self)
            IsDefinedBy()
            Label("Seq")
            Comment("The class of ordered containers.")
        }
        Class("Statement") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Resource.self)
            IsDefinedBy()
            Label("Statement")
            Comment("The class of RDF statements.")
        }
        Property("direction") {
            Type(RDF.Property.self)
            Domain(RDF.CompoundLiteral.self)
            IsDefinedBy()
            SeeAlso(IRI("https://www.w3.org/TR/json-ld11/#the-rdf-compoundliteral-class-and-the-rdf-language-and-rdf-direction-properties"))
            Label("direction")
            Comment("The base direction component of a CompoundLiteral.")
        }
        Property("first") {
            Type(RDF.Property.self)
            Domain(RDF.List.self)
            Range(RDFS.Resource.self)
            IsDefinedBy()
            Label("first")
            Comment("The first item in the subject RDF list.")
        }
        Property("language") {
            Type(RDF.Property.self)
            Domain(RDF.CompoundLiteral.self)
            IsDefinedBy()
            SeeAlso(IRI("https://www.w3.org/TR/json-ld11/#the-rdf-compoundliteral-class-and-the-rdf-language-and-rdf-direction-properties"))
            Label("language")
            Comment("The language component of a CompoundLiteral.")
        }
        Property("object") {
            Type(RDF.Property.self)
            Domain(RDF.Statement.self)
            Range(RDFS.Resource.self)
            IsDefinedBy()
            Label("object")
            Comment("The object of the subject RDF statement.")
        }
        Property("predicate") {
            Type(RDF.Property.self)
            Domain(RDF.Statement.self)
            Range(RDFS.Resource.self)
            IsDefinedBy()
            Label("predicate")
            Comment("The predicate of the subject RDF statement.")
        }
        Property("propositionFormObject") {
            Type(RDF.Property.self)
            Domain(RDF.PropositionForm.self)
            Range(RDFS.Resource.self)
            IsDefinedBy()
            SeeAlso(IRI("https://www.w3.org/TR/rdf12-interop/"))
            Label("propositionFormObject")
            Comment("The object component of a proposition form. Reserved for basic encoding of propositions.")
        }
        Property("propositionFormPredicate") {
            Type(RDF.Property.self)
            Domain(RDF.PropositionForm.self)
            Range(RDF.Property.self)
            IsDefinedBy()
            SeeAlso(IRI("https://www.w3.org/TR/rdf12-interop/"))
            Label("propositionFormPredicate")
            Comment("The predicate component of a proposition form. Reserved for basic encoding of propositions.")
        }
        Property("propositionFormSubject") {
            Type(RDF.Property.self)
            Domain(RDF.PropositionForm.self)
            Range(RDFS.Resource.self)
            IsDefinedBy()
            SeeAlso(IRI("https://www.w3.org/TR/rdf12-interop/"))
            Label("propositionFormSubject")
            Comment("The subject component of a proposition form. Reserved for basic encoding of propositions.")
        }
        Property("reifies") {
            Type(RDF.Property.self)
            Domain(RDFS.Resource.self)
            Range(RDFS.Proposition.self)
            IsDefinedBy()
            Label("reifies")
            Comment("The abstract proposition of a more concrete circumstance.")
        }
        Property("rest") {
            Type(RDF.Property.self)
            Domain(RDF.List.self)
            Range(RDF.List.self)
            IsDefinedBy()
            Label("rest")
            Comment("The rest of the subject RDF list after the first item.")
        }
        Property("subject") {
            Type(RDF.Property.self)
            Domain(RDF.Statement.self)
            Range(RDFS.Resource.self)
            IsDefinedBy()
            Label("subject")
            Comment("The subject of the subject RDF statement.")
        }
        Property("type") {
            Type(RDF.Property.self)
            Domain(RDFS.Resource.self)
            Range(RDFS.Class.self)
            IsDefinedBy()
            Label("type")
            Comment("The subject is an instance of a class.")
        }
        Property("value") {
            Type(RDF.Property.self)
            Domain(RDFS.Resource.self)
            Range(RDFS.Resource.self)
            IsDefinedBy()
            Label("value")
            Comment("Idiomatic property used for structured values.")
        }
        Datatype("XMLLiteral") {
            Type(RDFS.Datatype.self)
            SubClassOf(RDFS.Literal.self)
            IsDefinedBy()
            Label("XMLLiteral")
            Comment("The datatype of XML literal values.")
        }
        Individual("version-1.0") {
            Type(RDFS.Resource.self)
            IsDefinedBy()
            Label("1.0")
            Comment("Version 1.0")
        }
        Individual("version-1.1") {
            Type(RDFS.Resource.self)
            IsDefinedBy()
            Label("1.1")
            Comment("Version 1.1")
        }
        Individual("version-1.2") {
            Type(RDFS.Resource.self)
            IsDefinedBy()
            Label("1.2")
            Comment("Version 1.2.")
        }
        Individual("version-1.2-basic") {
            Type(RDFS.Resource.self)
            IsDefinedBy()
            Label("1.2-basic")
            Comment("Version 1.2-basic")
        }
    }
}
