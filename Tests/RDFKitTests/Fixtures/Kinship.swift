import RDFCore
import RDFKit

/// A family ontology built on OWL: its classes refine `OWL.Thing`, which
/// another ontology declares, and it names one OWL class as an individual.
@Ontology
struct Kinship: Ontology {
    func content() -> Content {
        Namespace("https://kinship.example.org/ontology#")

        Class("Person") {
            Type(OWL.Class)
            SubClassOf(OWL.Thing)
            Label("Person")
        }

        Class("Parent") {
            Type(OWL.Class)
            SubClassOf(Kinship.Person)
            Label("Parent")
        }

        Property("hasChild") {
            Type(OWL.ObjectProperty)
            Domain(Kinship.Parent)
            Range(Kinship.Person)
            Label("has child")
        }

        Property("name") {
            Type(OWL.DatatypeProperty)
            Type(OWL.FunctionalProperty)
            Domain(Kinship.Person)
            Range(RDFS.Literal)
            Label("name")
        }

        Individual("Mammal") {
            Type(OWL.Class)
            Label("Mammal")
            Comment("The class of mammals, named as an individual of owl:Class.")
        }
    }
}
