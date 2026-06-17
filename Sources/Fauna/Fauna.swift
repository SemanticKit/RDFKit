import Foundation
import RDFKit
import IRIKit

/// An animal kingdom ontology.
@Vocabulary
public struct Fauna: Ontology {
    public var content: Content {
        Namespace("https://fauna.example.org/ontology#")

        Class("Animal") {
            Type(RDFS.Class)
            Label("Animal")
            Comment("The class of all animals.")
        }

        Class("Habitat") {
            Type(RDFS.Class)
            Label("Habitat")
            Comment("The class of natural habitats.")
        }

        Class("Diet") {
            Type(RDFS.Class)
            Label("Diet")
            Comment("The class of dietary classifications.")
        }

        Property("hasHabitat") {
            Type(OWL.ObjectProperty)
            Domain(Fauna.Animal)
            Range(Fauna.Habitat)
            Label("has habitat")
            Comment("The natural habitat of an animal.")
        }

        Property("hasDiet") {
            Type(OWL.ObjectProperty)
            Domain(Fauna.Animal)
            Range(Fauna.Diet)
            Label("has diet")
            Comment("The dietary classification of an animal.")
        }

        Property("commonName") {
            Type(RDF.Property)
            Domain(Fauna.Animal)
            Range(RDFS.Literal)
            Label("common name")
            Comment("The common name of an animal.")
        }

        Property("scientificName") {
            Type(RDF.Property)
            Domain(Fauna.Animal)
            Range(RDFS.Literal)
            Label("scientific name")
            Comment("The binomial nomenclature of an animal.")
        }
    }
}
