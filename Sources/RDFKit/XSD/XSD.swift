import RDFCore

/// The XML Schema datatypes that RDF, RDFS and OWL use as ranges.
///
/// Only the datatypes the declared vocabularies reference are declared here.
@Ontology
public struct XSD: Ontology {
    public func content() -> Content {
        Namespace("http://www.w3.org/2001/XMLSchema#")

        Datatype("nonNegativeInteger") {
            Type(RDFS.Datatype)
            Label("nonNegativeInteger")
            Comment("The datatype of integers greater than or equal to zero.")
        }
    }
}
