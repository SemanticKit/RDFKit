# The @Ontology Macro

## What It Does

`@Ontology` reads an ontology's DSL content from its `var body: some Content` and generates the Swift model of the ontology inside the ontology struct. It generates the same Swift that `RDFTranslatorPlugin` writes for the same vocabulary written in RDF, on the same runtime in RDFCore, so a class declared in the DSL and a class translated from RDF are the same kind of thing, and their individuals are the same kind of `Resource`.

| DSL | Generated |
|---|---|
| `Class("Animal")` | `protocol Animal`, the storing protocol `AnimalStoring`, and `final class AnimalIndividual`, whose instances are the class's members |
| `Datatype("Code")` | the same, with `Member = RDFCore.Literal`: its members are literals |
| `Property("hasHabitat") { Domain(X); Range(Y) }` | a requirement `var hasHabitat: [Y-member] { get set }` on protocol `X`, the term type `struct hasHabitat`, the value type `hasHabitatValue` and the storing protocol `hasHabitatStoring` |
| `SubClassOf(X)` | the class protocol refines `X`, and its storing protocol refines `X`'s |
| `Type`, `SubClassOf`, `Label`, `Comment`, `SeeAlso`, `Deprecated` on a class | the triples the class's `encodeDescription(to:)` writes |
| `Label`, `Comment` | DocC on the generated declaration |
| `Deprecated()` | `@available(*, deprecated)` on the generated declaration |
| `Individual("rex")` | an error: a named individual is a module-level value (see below) |

## Example

```swift
import IRIKit
import RDF
import RDFCore
import RDFKit

@Ontology
public struct Fauna: Ontology {
    public var body: some Content {
        Namespace("https://fauna.example.org/ontology#")

        Class("Animal") {
            Type(RDF.Class)
            Comment("The class of all animals.")
        }
        Class("Predator") {
            SubClassOf(Fauna.Animal)
        }
        Class("Habitat")

        Property("hasHabitat") {
            Domain(Fauna.Animal)
            Range(Fauna.Habitat)
        }
        Property("preysOn") {
            Domain(Fauna.Predator)
            Range(Fauna.Animal)
        }
        Property("name") {
            Domain(Fauna.Animal)
            Range(RDF.Literal)
        }
    }
}
```

The macro generates, among others:

```swift
// Inside struct Fauna:
/// The class of all animals.
public protocol Animal: RDF.Resource {
    var hasHabitat: [any Fauna.Habitat] { get set }
    var name: [RDF.LiteralIndividual.Member] { get set }
}

public protocol AnimalStoring: Fauna.Animal, Fauna.hasHabitatStoring, Fauna.nameStoring, RDF.ResourceStoring {}

public final class AnimalIndividual: Fauna.AnimalStoring, RDFCore.ResourceClass {
    public static let iri: IRIKit.IRI? = "https://fauna.example.org/ontology#Animal"
    public typealias Member = any Fauna.Animal
    public let iri: IRIKit.IRI?
    public let storage = RDFCore.IndividualStorage()
    public init(iri: IRIKit.IRI? = nil) { self.iri = iri }
    public func encode(to encoder: any Encoder) throws { /* rdf:type, then the stored values */ }
    public static func encodeDescription(to encoder: any Encoder) throws { /* rdf:type rdfs:Class, rdfs:comment */ }
}
```

Code that uses the model reads as ordinary Swift:

```swift
let savanna = Fauna.HabitatIndividual()
let lion = Fauna.PredatorIndividual(iri: "https://fauna.example.org/lion")
let zebra = Fauna.AnimalIndividual()
lion.hasHabitat = [savanna]
lion.preysOn = [zebra]
lion.name = ["Lion"]

let document = try TurtleEncoder().encode([lion])
```

## Classes Are Protocols

A class is a set of individuals, and an individual can be in several classes. A Swift protocol says the same: a type conforms to as many protocols as it needs. The class protocol's requirements are the properties whose `Domain` is the class, so anything that is an `Animal` has `hasHabitat`. `SubClassOf(X)` becomes refinement, so a `Predator` is an `Animal`, and a class with two superclasses refines both. A class with no superclass refines `RDF.Resource`, the protocol of `rdfs:Resource` translated from rdfs.ttl, because every resource is one (RDF 1.2 Semantics, rdfs4); so every individual has `rdfs:label` and the other properties of `rdfs:Resource`.

A class of another module is named by its type, and refined the same way: `SubClassOf(FOAF.Person)` makes the protocol refine `FOAF.Person` and the storing protocol refine `FOAF.PersonStoring`, which `RDFTranslatorPlugin` generated from FOAF's RDF.

## Individuals Are Objects

An individual is an instance of a final class. Its identity inside the runtime is the object itself: the zebra a lion preys on is the zebra, not a copy of it, so a graph with cycles is built with ordinary references. Its IRI, or none for a blank node, is read only when an encoder writes it.

Its property values are typed Swift values in one `RDFCore.IndividualStorage`, the storage translated individuals use too. For each stored property `@Ontology` generates `hasHabitatValue`, an `RDFCore.PropertyValue` that holds the values and writes them keyed by the property, and `hasHabitatStoring`, which `@IndividualStoring` gives accessors that read and change the value in the storage under its lock, holding it for the whole of a change in place. A class's storing protocol refines the storing protocols of its properties and of its superclasses, whichever module declares them, so a property is one property, supplied once: through a chain of superclasses across ontologies, through two classes that share a superclass, and for a property with two domains whose subject is in both. An individual of several classes, in any module, is a Swift class that conforms to the storing protocol of each.

Individuals are `Sendable` as checked by the compiler: `IndividualStorage` is a mutex, and each read and each write of a property takes the lock.

A named individual, `Individual("rex")`, is a module-level value, as `RDFTranslatorPlugin` writes `alice`: never a static member of the ontology type. A macro attached at module scope cannot declare names it chooses there ("'peer' macros are not allowed to introduce arbitrary names at global scope"), so `@Ontology` reports `Individual` as an error. A named individual comes from RDF data that the plugin translates, or is declared in Swift as an instance of its class.

## Properties Are Many-Valued

A property has any number of values, so its requirement is an array of its range's members, as the translator types it: `[any Fauna.Habitat]` for a class of this ontology, `[RDFCore.Literal]` for a datatype of it, and `[X.YIndividual.Member]` for a class `X.Y` of another module, which the compiler resolves through that class's generated Swift class: `Range(RDF.Literal)` is `[RDFCore.Literal]`, `Range(FOAF.Person)` is `[any FOAF.Person]`. A property without a `Range` holds `[RDFCore.Value]`. No table of spellings or IRIs decides a type.

## Terms Refer to Each Other as Types

Related terms are written with their type as the argument: `Domain(Fauna.Animal)`, `Type(RDF.Class)`. The macro reads them as syntax. Each term's IRI is computed during expansion from the namespace and the local name, and emitted as a literal. It is read only at the boundary: serialization, translation into SPARQL or SHACL, dereferencing. Generated code never builds an identity at runtime.

## Owning var body

`@Ontology` attaches the body macro `@OntologyContent` to `var body`, so authors write only `@Ontology` on the type, as in SwiftUI. Swift cannot evaluate `Domain(Fauna.Animal)` as an expression, so the body macro owns the body and returns the statements that are values:

- each term annotation left out, because `@Ontology` writes it as the Swift declaration it describes; its lines stay blank, so the statements after it keep their authored lines;
- each DSL form qualified by its module: `Class("Animal")` becomes `RDFCore.Class("Animal")` and `Label("Animal")` becomes `RDFCore.Label("Animal")`, because an ontology may declare a term with the same name (`RDF.Class`, `RDFKit.Prefix`).

Which annotations relate terms is read from how they are written, not from a list of annotation names. An annotation whose only argument is a type path (`Fauna.Animal`, or the bare name of a term the ontology declares) relates the declared term to that type. Annotations that carry text take a string literal, which the macro reads at compile time for DocC.

Each returned statement is preceded by `#sourceLocation(file:line:)` for the line it was authored on, so the compiler reports an error in the content at the authored line. A body macro on a computed property is given a getter built outside the authored file, so `@Ontology` attaches `@OntologyContent(file:line:)` with the file and line of the opening brace of `var body`, and the body macro counts each statement's line from it.

`@Ontology` reports content written as a `content()` function as an error, with a fix-it that writes the same statements in `var body: some Content`, and reports an ontology with no `var body`.

The macros also report at the authored declaration:

- a term annotation written with a generic argument or a `.self` argument, with a fix-it to `Domain(Fauna.Animal)`;
- a related term written as a term of this ontology that it does not declare (`Fauna.Habitatt`);
- a class whose generated type names are taken by a declared term;
- a named individual.

## Testing

`Tests/RDFKitMacrosTests` pins the member expansion, the `var body` rewrite, the `#sourceLocation` lines and the diagnostics with `SwiftSyntaxMacrosGenericTestSupport`. `Tests/RDFKitTests` uses generated models as ordinary Swift, with classes refining translated FOAF classes, and encodes their individuals with translated ones through every format.
