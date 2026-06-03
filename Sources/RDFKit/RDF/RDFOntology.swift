import Foundation

public extension RDF {
    /// The RDF vocabulary expressed as Turtle-like Swift ontology DSL content.
    static var ontology: some Content {
        RDFOntology().content
    }
}

/// RDF vocabulary content authored in the ontology declaration DSL.
private struct RDFOntology: Ontology {
    var content: some Content {
        Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
        Alias("rdf", RDF.self)
        Alias("rdfs", RDFS.self)
        Alias("owl", OWL.self)

        Class("Alt") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Container.self)
            Label("Alt")
            Comment("The class of containers of alternatives.")
        }
        Class("Bag") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Container.self)
            Label("Bag")
        }
        Class("CompoundLiteral") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Resource.self)
        }
        Datatype("HTML") {
            Type(RDFS.Datatype.self)
            SubClassOf(RDFS.Literal.self)
            Label("HTML")
        }
        Datatype("JSON") {
            Type(RDFS.Datatype.self)
            SubClassOf(RDFS.Literal.self)
            Label("JSON")
        }
        Datatype("dirLangString") {
            Type(RDFS.Datatype.self)
            SubClassOf(RDFS.Literal.self)
        }
        Datatype("langString") {
            Type(RDFS.Datatype.self)
            SubClassOf(RDFS.Literal.self)
            Label("langString")
        }
        Class("List") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Resource.self)
        }
        Individual("nil") {
            Type(RDF.List.self)
            Label("nil")
        }
        Datatype("PlainLiteral") {
            Type(RDFS.Datatype.self)
            SubClassOf(RDFS.Literal.self)
            OWLDeprecated()
        }
        Class("Property") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Resource.self)
        }
        Class("PropositionForm") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Resource.self)
        }
        Class("Seq") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Container.self)
        }
        Class("Statement") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Resource.self)
        }
        Property("direction") {
            Type(RDF.Property.self)
            Domain(RDF.CompoundLiteral.self)
        }
        Property("first") {
            Type(RDF.Property.self)
            Domain(RDF.List.self)
            Range(RDFS.Resource.self)
        }
        Property("language") {
            Type(RDF.Property.self)
            Domain(RDF.CompoundLiteral.self)
        }
        Property("object") {
            Type(RDF.Property.self)
            Domain(RDF.Statement.self)
            Range(RDFS.Resource.self)
        }
        Property("predicate") {
            Type(RDF.Property.self)
            Domain(RDF.Statement.self)
            Range(RDFS.Resource.self)
        }
        Property("propositionFormObject") {
            Type(RDF.Property.self)
            Domain(RDF.PropositionForm.self)
            Range(RDFS.Resource.self)
        }
        Property("propositionFormPredicate") {
            Type(RDF.Property.self)
            Domain(RDF.PropositionForm.self)
            Range(RDF.Property.self)
        }
        Property("propositionFormSubject") {
            Type(RDF.Property.self)
            Domain(RDF.PropositionForm.self)
            Range(RDFS.Resource.self)
        }
        Property("reifies") {
            Type(RDF.Property.self)
            Domain(RDFS.Resource.self)
            Range(RDFS.Proposition.self)
        }
        Property("rest") {
            Type(RDF.Property.self)
            Domain(RDF.List.self)
            Range(RDF.List.self)
        }
        Property("subject") {
            Type(RDF.Property.self)
            Domain(RDF.Statement.self)
            Range(RDFS.Resource.self)
        }
        Property("type") {
            Type(RDF.Property.self)
            Domain(RDFS.Resource.self)
            Range(RDFS.Class.self)
            Label("type")
            Comment("The subject is an instance of a class.")
        }
        Property("value") {
            Type(RDF.Property.self)
            Domain(RDFS.Resource.self)
            Range(RDFS.Resource.self)
        }
        Datatype("XMLLiteral") {
            Type(RDFS.Datatype.self)
            SubClassOf(RDFS.Literal.self)
        }
        Individual("version-1.0") {
            Type(RDFS.Resource.self)
            Label("1.0")
        }
        Individual("version-1.1") {
            Type(RDFS.Resource.self)
            Label("1.1")
        }
        Individual("version-1.2") {
            Type(RDFS.Resource.self)
            Label("1.2")
        }
        Individual("version-1.2-basic") {
            Type(RDFS.Resource.self)
            Label("1.2-basic")
        }
    }
}
