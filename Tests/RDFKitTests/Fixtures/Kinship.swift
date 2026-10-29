import RDFCore
import RDFKit

/// A family ontology built on OWL: its classes refine `OWL.Thing` and OWL's
/// property characteristics, which another ontology declares, and it names
/// OWL classes and properties as individuals.
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

        Class("FamilyRelation") {
            Type(OWL.Class)
            SubClassOf(OWL.TransitiveProperty)
            SubClassOf(OWL.SymmetricProperty)
            Label("family relation")
            Comment("A relation between people that is both transitive and symmetric.")
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

        Individual("relativeOf") {
            Type(OWL.TransitiveProperty)
            Type(OWL.SymmetricProperty)
            Label("relative of")
            Comment("Kinship between two people, named as an individual of two OWL classes.")
        }
    }
}
