import RDFCore

/// The XML Schema datatypes that RDF, RDFS and OWL use as ranges.
///
/// Only the datatypes the declared vocabularies reference, and those the
/// Turtle and N-Triples grammars give literals (RDF 1.2 Turtle §7.2), are
/// declared here.
@Ontology
public struct XSD: Ontology {
    public func content() -> Content {
        Namespace("http://www.w3.org/2001/XMLSchema#")

        Datatype("boolean") {
            Type(RDFS.Datatype)
            Label("boolean")
            Comment("The datatype of the truth values true and false.")
        }
        Datatype("decimal") {
            Type(RDFS.Datatype)
            Label("decimal")
            Comment("The datatype of decimal numbers of arbitrary precision.")
        }
        Datatype("double") {
            Type(RDFS.Datatype)
            Label("double")
            Comment("The datatype of IEEE double-precision 64-bit floating-point numbers.")
        }
        Datatype("integer") {
            Type(RDFS.Datatype)
            Label("integer")
            Comment("The datatype of integers.")
        }
        Datatype("string") {
            Type(RDFS.Datatype)
            Label("string")
            Comment("The datatype of character strings.")
        }
        Datatype("nonNegativeInteger") {
            Type(RDFS.Datatype)
            Label("nonNegativeInteger")
            Comment("The datatype of integers greater than or equal to zero.")
        }
    }
}
