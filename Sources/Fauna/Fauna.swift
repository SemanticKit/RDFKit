import RDFCore
import RDFKit

/// An animal kingdom ontology.
///
/// `@Ontology` generates a protocol for every class: `Fauna.Animal`,
/// `Fauna.Predator` and `Fauna.Prey` (both refine `Fauna.Animal`),
/// `Fauna.Mesopredator` (refines both), `Fauna.Habitat` (refines another
/// ontology's class, `OWL.Thing`) and `Fauna.Diet`. Each class also gets an
/// individual type, such as `Fauna.PredatorIndividual`. The named diets are
/// individuals: `Fauna.carnivore`, `Fauna.herbivore` and `Fauna.omnivore`,
/// and so is `Fauna.faunaOntology`, an individual of `OWL.Ontology`.
///
/// `Fauna.Kilograms` is a datatype: a value type that stores the literal.
///
/// Properties are many-valued unless they are functional: an animal has
/// any number of habitats and common names, and at most one diet, one
/// scientific name and one average mass. `hasHabitat` and `inhabitedBy` link
/// animals and habitats both ways, so the graph of individuals has cycles.
/// Individuals are created in an `RDFCore.IndividualGraph`, which owns their
/// values and lives as long as any of them.
@Ontology
public struct Fauna: Ontology {
    public func content() -> Content {
        Namespace("https://fauna.example.org/ontology#")

        Class("Animal") {
            Type(RDFS.Class)
            Label("Animal")
            Comment("The class of all animals.")
        }

        Class("Predator") {
            Type(RDFS.Class)
            SubClassOf(Fauna.Animal)
            Label("Predator")
            Comment("An animal that hunts other animals.")
        }

        Class("Prey") {
            Type(RDFS.Class)
            SubClassOf(Fauna.Animal)
            Label("Prey")
            Comment("An animal that other animals hunt.")
        }

        Class("Mesopredator") {
            Type(RDFS.Class)
            SubClassOf(Fauna.Predator)
            SubClassOf(Fauna.Prey)
            Label("Mesopredator")
            Comment("A predator that is itself hunted by larger predators.")
        }

        Class("Habitat") {
            Type(RDFS.Class)
            SubClassOf(OWL.Thing)
            Label("Habitat")
            Comment("The class of natural habitats.")
        }

        Class("Diet") {
            Type(RDFS.Class)
            Label("Diet")
            Comment("The class of dietary classifications.")
        }

        Datatype("Kilograms") {
            Type(RDFS.Datatype)
            Label("kilograms")
            Comment("A mass in kilograms, written as a decimal number.")
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

        Individual("faunaOntology") {
            Type(OWL.Ontology)
            Label("Fauna ontology")
            Comment("This ontology, as an individual of owl:Ontology.")
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
            Range(RDFS.Literal)
            Label("common name")
            Comment("A common name of an animal.")
        }

        Property("scientificName") {
            Type(OWL.DatatypeProperty)
            Type(OWL.FunctionalProperty)
            Domain(Fauna.Animal)
            Range(RDFS.Literal)
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

        Property("averageMass") {
            Type(OWL.DatatypeProperty)
            Type(OWL.FunctionalProperty)
            Domain(Fauna.Animal)
            Range(Fauna.Kilograms)
            Label("average mass")
            Comment("The average mass of an adult animal.")
        }
    }
}
