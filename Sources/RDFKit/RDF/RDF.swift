import RDFCore

/// The RDF Concepts vocabulary (RDF), as rdf.ttl publishes it.
@Ontology
public struct RDF: Ontology {
    public var body: some Content {
        Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#")

        Class("Property") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Resource)
            Label("Property")
            Comment("The class of RDF properties.")
        }

        Class("List") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Resource)
            Label("List")
            Comment("The class of RDF Lists.")
        }

        Class("Statement") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Resource)
            Label("Statement")
            Comment("The class of RDF statements.")
        }

        Class("CompoundLiteral") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Resource)
            Label("CompoundLiteral")
            Comment("A class representing a compound literal.")
        }

        Property("first") {
            Type(RDF.Property)
            Domain(RDF.List)
            Range(RDFS.Resource)
            Label("first")
            Comment("The first item in the subject RDF list.")
        }

        Property("rest") {
            Type(RDF.Property)
            Domain(RDF.List)
            Range(RDF.List)
            Label("rest")
            Comment("The rest of the subject RDF list after the first item.")
        }

        Property("type") {
            Type(RDF.Property)
            Domain(RDFS.Resource)
            Range(RDFS.Class)
            Label("type")
            Comment("The subject is an instance of a class.")
        }

        Datatype("HTML") {
            Type(RDFS.Datatype)
            SubClassOf(RDFS.Literal)
            Label("HTML")
            Comment("The datatype of RDF literals storing fragments of HTML content")
        }

        Datatype("langString") {
            Type(RDFS.Datatype)
            SubClassOf(RDFS.Literal)
            Label("langString")
            Comment("The datatype of language-tagged string values")
        }

        Datatype("dirLangString") {
            Type(RDFS.Datatype)
            SubClassOf(RDFS.Literal)
            Label("dirLangString")
            Comment("The datatype of directional language-tagged string values, which includes a language tag and a base direction (either 'ltr' or 'rtl')")
        }

        Datatype("XMLLiteral") {
            Type(RDFS.Datatype)
            SubClassOf(RDFS.Literal)
            Label("XMLLiteral")
            Comment("The datatype of XML literal values.")
        }
    }
}
