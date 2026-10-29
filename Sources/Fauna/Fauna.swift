import RDFCore
import RDFKit

/// An animal kingdom ontology.
///
/// `@Ontology` generates `Fauna.Animal`, `Fauna.Habitat` and `Fauna.Diet` from
/// this content. `Animal` stores `hasHabitat` as a `Fauna.Habitat` and
/// `hasDiet` as a `Fauna.Diet`, the ranges of those properties. `preysOn`
/// ranges over `Fauna.Animal` itself, so it is stored as an optional
/// `Fauna.Animal?` and a food chain ends where it is `nil`.
@Ontology
public struct Fauna: Ontology {
    public var content: Content {
        Namespace("https://fauna.example.org/ontology#")

        Class("Animal") {
            Type<RDFS.Class>()
            Label("Animal")
            Comment("The class of all animals.")
        }

        Class("Habitat") {
            Type<RDFS.Class>()
            Label("Habitat")
            Comment("The class of natural habitats.")
        }

        Class("Diet") {
            Type<RDFS.Class>()
            Label("Diet")
            Comment("The class of dietary classifications.")
        }

        Property("hasHabitat") {
            Type<OWL.ObjectProperty>()
            Domain<Fauna.Animal>()
            Range<Fauna.Habitat>()
            Label("has habitat")
            Comment("The natural habitat of an animal.")
        }

        Property("hasDiet") {
            Type<OWL.ObjectProperty>()
            Domain<Fauna.Animal>()
            Range<Fauna.Diet>()
            Label("has diet")
            Comment("The dietary classification of an animal.")
        }

        Property("preysOn") {
            Type<OWL.ObjectProperty>()
            Domain<Fauna.Animal>()
            Range<Fauna.Animal>()
            Label("preys on")
            Comment("""
                An animal this animal hunts for food.
                Its range is "Animal", the property's own domain.
                """)
        }

        Property("commonName") {
            Type<RDF.Property>()
            Domain<Fauna.Animal>()
            Range<RDFS.Literal>()
            Label("common name")
            Comment("The common name of an animal.")
        }

        Property("scientificName") {
            Type<RDF.Property>()
            Domain<Fauna.Animal>()
            Range<RDFS.Literal>()
            Label("scientific name")
            Comment("The binomial nomenclature of an animal.")
        }
    }
}
