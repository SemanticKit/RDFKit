import OWL
import RDF
import RDFCore
import RDFKit
import XSD

/// An animal kingdom ontology.
///
/// `@Ontology` generates a protocol for every class: `Fauna.Animal`,
/// `Fauna.Predator` and `Fauna.Prey` (both refine `Fauna.Animal`),
/// `Fauna.Mesopredator` (refines both), `Fauna.Habitat` and `Fauna.Diet`.
/// Each class also gets the Swift class of its members, such as
/// `Fauna.PredatorIndividual`, whose stored properties are the properties
/// whose domain is the class or one of its superclasses, typed by their
/// ranges. The named diets are individuals of `Fauna.Diet`: `carnivore`,
/// `herbivore` and `omnivore`.
///
/// Properties are many-valued unless they are functional: an animal has
/// any number of habitats and common names, and at most one diet and one
/// scientific name. `hasHabitat` and `inhabitedBy` link animals and habitats
/// both ways, so the graph of individuals has cycles.
@Ontology
public struct Fauna: Ontology {
    public var body: some Content {
        Namespace("https://fauna.example.org/ontology#")

        Class("Animal") {
            Type(RDF.Class)
            Label("Animal")
            Comment("The class of all animals.")
        }

        Class("Predator") {
            Type(RDF.Class)
            SubClassOf(Fauna.Animal)
            Label("Predator")
            Comment("An animal that hunts other animals.")
        }

        Class("Prey") {
            Type(RDF.Class)
            SubClassOf(Fauna.Animal)
            Label("Prey")
            Comment("An animal that other animals hunt.")
        }

        Class("Mesopredator") {
            Type(RDF.Class)
            SubClassOf(Fauna.Predator)
            SubClassOf(Fauna.Prey)
            Label("Mesopredator")
            Comment("A predator that is itself hunted by larger predators.")
        }

        Class("Habitat") {
            Type(RDF.Class)
            Label("Habitat")
            Comment("The class of natural habitats.")
        }

        Class("Diet") {
            Type(RDF.Class)
            Label("Diet")
            Comment("The class of dietary classifications.")
        }

        Individual("carnivore") {
            Type(Fauna.Diet)
            Label("carnivore")
            Comment("A diet of other animals.")
        }

        Individual("herbivore") {
            Type(Fauna.Diet)
            Label("herbivore")
            Comment("A diet of plants.")
        }

        Individual("omnivore") {
            Type(Fauna.Diet)
            Label("omnivore")
            Comment("A diet of plants and animals.")
        }

        Property("hasHabitat") {
            Type(OWL.ObjectProperty)
            Domain(Fauna.Animal)
            Range(Fauna.Habitat)
            Label("has habitat")
            Comment("A natural habitat of an animal.")
        }

        Property("inhabitedBy") {
            Type(OWL.ObjectProperty)
            Domain(Fauna.Habitat)
            Range(Fauna.Animal)
            Label("inhabited by")
            Comment("An animal that lives in a habitat.")
        }

        Property("hasDiet") {
            Type(OWL.ObjectProperty)
            Type(OWL.FunctionalProperty)
            Domain(Fauna.Animal)
            Range(Fauna.Diet)
            Label("has diet")
            Comment("The dietary classification of an animal.")
        }

        Property("preysOn") {
            Type(OWL.ObjectProperty)
            Domain(Fauna.Predator)
            Range(Fauna.Animal)
            Label("preys on")
            Comment("""
                An animal this predator hunts for food.
                Its range is "Animal", so a predator can prey on another predator.
                """)
        }

        Property("commonName") {
            Type(OWL.DatatypeProperty)
            Domain(Fauna.Animal)
            Range(RDF.Literal)
            Label("common name")
            Comment("A common name of an animal.")
        }

        Property("scientificName") {
            Type(OWL.DatatypeProperty)
            Type(OWL.FunctionalProperty)
            Domain(Fauna.Animal)
            Range(RDF.Literal)
            Label("scientific name")
            Comment("The binomial nomenclature of an animal.")
        }

        Property("averageLifespan") {
            Type(OWL.DatatypeProperty)
            Type(OWL.FunctionalProperty)
            Domain(Fauna.Animal)
            Range(XSD.nonNegativeInteger)
            Label("average lifespan")
            Comment("The average lifespan of an animal, in years.")
        }
    }
}
