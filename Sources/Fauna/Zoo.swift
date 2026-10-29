import RDFCore
import RDFKit

/// A zoo ontology whose class refines a class of ``Fauna``.
///
/// `Zoo.Resident` refines `Fauna.Animal`, and both ontologies declare a
/// property named `commonName` with the same range. They are two properties:
/// `Zoo.commonName` is the name a zoo gives a resident, `Fauna.commonName` a
/// common name of the animal. Each keeps its own values, whichever way a
/// resident is read.
@Ontology
public struct Zoo: Ontology {
    public func content() -> Content {
        Namespace("https://zoo.example.org/ontology#")

        Class("Resident") {
            Type(RDFS.Class)
            SubClassOf(Fauna.Animal)
            Label("Resident")
            Comment("An animal living in a zoo.")
        }

        Property("commonName") {
            Type(OWL.DatatypeProperty)
            Domain(Zoo.Resident)
            Range(RDFS.Literal)
            Label("common name")
            Comment("The name the zoo gives a resident.")
        }
    }
}
