# The @Ontology Macro

## What It Does

`@Ontology` reads an ontology's DSL content from its `func content()` and generates the Swift model of the ontology inside the ontology struct. RDF, RDFS and OWL model a graph of individuals: class membership is multiple and open, identity is shared, the graph has cycles, and properties have many values unless they are functional. The generated model has the same shape:

| DSL | Generated |
|---|---|
| `Class("Animal")` | `protocol Animal`, and the individual type `final class AnimalIndividual: Animal` |
| `Property("hasHabitat") { Domain(X); Range(Y) }` | a requirement `var hasHabitat: RDFCore.PropertyValues<any Y> { get }` on protocol `X`, and the term type `struct hasHabitat` |
| `Type(OWL.FunctionalProperty)` on a property | the requirement holds at most one value: `var hasDiet: RDFCore.PropertyValue<any Diet> { get }` |
| `SubClassOf(X)` | the class protocol refines `X` |
| `Individual("carnivore") { Type(X) }` | `static let carnivore: any X`, the one instance of a final class that conforms to `X` |
| `Datatype("HTML")`, `rdfs:Literal` and its subclasses | a value type (`struct`) that stores the literal and conforms to `RDFCore.LiteralValue` |
| `Label`, `Comment` | DocC on the generated declaration, and the term's static `metadata` |
| a term RDFCore provides (`rdfs:label`, `rdfs:domain`, `rdfs:Resource`, ...) | a type alias of the RDFCore type |

## Example

```swift
@Ontology
public struct Fauna: Ontology {
    public func content() -> Content {
        Namespace("https://fauna.example.org/ontology#")

        Class("Animal") {
            Type(RDFS.Class)
            Comment("The class of all animals.")
        }
        Class("Predator") {
            SubClassOf(Fauna.Animal)
        }
        Class("Habitat")
        Class("Diet")

        Individual("carnivore") {
            Type(Fauna.Diet)
        }

        Property("hasHabitat") {
            Domain(Fauna.Animal)
            Range(Fauna.Habitat)
        }
        Property("inhabitedBy") {
            Domain(Fauna.Habitat)
            Range(Fauna.Animal)
        }
        Property("hasDiet") {
            Type(OWL.FunctionalProperty)
            Domain(Fauna.Animal)
            Range(Fauna.Diet)
        }
        Property("preysOn") {
            Domain(Fauna.Predator)
            Range(Fauna.Animal)
        }
    }
}
```

The macro generates, among others:

```swift
// Inside struct Fauna:
/// The class of all animals.
public protocol Animal: RDFCore.Resource {
    var hasHabitat: RDFCore.PropertyValues<any Fauna.Habitat> { get }
    var hasDiet: RDFCore.PropertyValue<any Fauna.Diet> { get }
}

public protocol Predator: Fauna.Animal {
    var preysOn: RDFCore.PropertyValues<any Fauna.Animal> { get }
}

/// An individual of ``Fauna/Predator``.
public final class PredatorIndividual: Fauna.Predator {
    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(
        id: "https://fauna.example.org/ontology#Predator", name: "Predator")

    public let hasHabitat: RDFCore.PropertyValues<any Fauna.Habitat>
    public let hasDiet: RDFCore.PropertyValue<any Fauna.Diet>
    public let preysOn: RDFCore.PropertyValues<any Fauna.Animal>

    public init(in graph: RDFCore.IndividualGraph, hasHabitat: [any Fauna.Habitat] = [],
                hasDiet: (any Fauna.Diet)? = nil, preysOn: [any Fauna.Animal] = []) {
        self.hasHabitat = RDFCore.PropertyValues<any Fauna.Habitat>(hasHabitat)
        self.hasDiet = RDFCore.PropertyValue<any Fauna.Diet>(hasDiet)
        self.preysOn = RDFCore.PropertyValues<any Fauna.Animal>(preysOn)
        graph.insert(self, properties: [self.hasHabitat, self.hasDiet, self.preysOn])
    }
}

public static let carnivore: any Fauna.Diet = _carnivoreIndividual()

public struct hasHabitat: RDFCore.Entity {
    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(
        id: "https://fauna.example.org/ontology#hasHabitat", name: "hasHabitat")
    public typealias Domain = any Fauna.Animal
    public typealias Range = any Fauna.Habitat
}
```

Code that uses the model reads as ordinary Swift:

```swift
let graph = IndividualGraph()
let savanna = Fauna.HabitatIndividual(in: graph)
let lion = Fauna.PredatorIndividual(in: graph, hasHabitat: [savanna], hasDiet: Fauna.carnivore)
let zebra = Fauna.AnimalIndividual(in: graph, hasHabitat: [savanna])
savanna.inhabitedBy.append(contentsOf: [lion, zebra])
lion.preysOn.append(zebra)

lion.preysOn.first === savanna.inhabitedBy.last   // true: the same zebra
```

## Classes Are Protocols

A class is a set of individuals, and an individual can be in several classes. A Swift protocol says the same: a type conforms to as many protocols as it needs. The class protocol's requirements are the properties whose `Domain` is the class, so anything that is an `Animal` has `hasHabitat`. `SubClassOf(X)` becomes refinement, so a `Predator` is an `Animal`, and a class with two superclasses refines both. A class with no superclass refines `RDFCore.Resource` (`rdfs:Resource`), which is `AnyObject` and `Entity`.

## Individuals Are Objects

An individual is an instance of a final class. Its identity inside the runtime is the object itself: the zebra a lion preys on is the zebra that lives in the savanna, not a copy of it, so a graph with cycles is built with ordinary references. No IRI or name stands in for an individual.

Each class protocol gets an individual type named after the class, `AnimalIndividual`, that conforms to the protocol and stores every requirement of the class and its superclasses. A named individual declared with `Individual("carnivore")` becomes a static constant of the ontology, the one instance of a private final class that conforms to all of its classes, so `Fauna.carnivore` is the same object wherever it is used.

The macro knows the requirements of the classes the ontology itself declares. A class that refines another ontology's class (other than `rdfs:Resource`) is generated as a protocol only, as is `owl:Nothing`, which has no individuals, and a named individual of such a class is reported as an error at its `Type(...)` annotation.

Individuals are `Sendable` as checked by the compiler. Each property of an individual is a `let` holding an `RDFCore.PropertyValues` or `RDFCore.PropertyValue`, which guard the values with a mutex. Every method holds the lock for the whole change, so a read-modify-write such as `savanna.inhabitedBy.append(zebra)` is atomic and concurrent appends from many tasks all land; `update { values in ... }` does any other change in one step. Reads (`values`, `first`, `count`, iteration) see one snapshot.

## Individuals Live in a Graph

Properties link individuals in cycles (`hasHabitat` and `inhabitedBy`, `owl:sameAs`), and a cycle of strong references never frees itself. So each individual type is created in an `RDFCore.IndividualGraph`: `Fauna.PredatorIndividual(in: graph)`. The graph owns the lifetime of its individuals. It keeps them alive while it lives, lists them in `individuals`, and when it is released it removes every property value of every individual in it. That breaks every cycle, and the individuals are freed once nothing else holds them. An individual still held after its graph is gone keeps its identity but has no values. Named individuals such as `Fauna.carnivore` are static constants and belong to no graph.

## Properties Are Many-Valued

A property has any number of values unless it is functional, so its requirement is a collection of its range, `RDFCore.PropertyValues<any Fauna.Habitat>`, which is a `Sequence` and takes `append`, `replace(with:)` and `removeAll(where:)`. A property typed `OWL.FunctionalProperty`, or a subproperty of one, has at most one value and its requirement is `RDFCore.PropertyValue<any Fauna.Diet>`, whose `value` is optional. An individual type's initializer takes the values as an array or an optional.

Values are typed by the property's `Range`. A class range is the class protocol, `any Fauna.Habitat`. A literal range is the datatype's value type: `RDFS.Literal`, `XSD.nonNegativeInteger`, `Fauna.Kilograms`. A property without a `Range` holds `any RDFCore.Resource`.

## Datatypes Are Values

Literals have no identity, so `Datatype(...)` declarations, `rdfs:Literal` and the classes that are subclasses of it become structs. Each struct is the datatype, and an instance stores one literal of it: the lexical form, and the language tag and base direction RDF allows on strings (`RDFCore.LiteralValue`). `Fauna.Kilograms("190.5")` is a literal whose datatype is `Fauna.Kilograms`, and string literals convert, so `scientificName: "Panthera leo"` stores an `RDFS.Literal`. Two literals are equal when their lexical forms, language tags and directions are. A functional property of a value type cannot range over the value type itself, because the struct would contain itself; the macro reports that at the property.

## Terms Refer to Each Other as Types

Related terms are written with their type as the argument: `Domain(Fauna.Animal)`, `Type(RDFS.Class)`. The macro reads them as syntax. Each term's IRI is computed during expansion from the namespace and the local name, and emitted as a literal in the term's static `metadata`. It is read only at the boundary: serialization, translation into SPARQL or SHACL, dereferencing. Generated code never builds an identity at runtime.

## The content() Body

`@Ontology` attaches the body macro `@OntologyContent` to `func content()`. Swift cannot evaluate `Domain(Fauna.Animal)` as an expression, so the body macro owns the body and returns the same statements with:

- each term annotation written as the annotation type for that term: `Domain(Fauna.Animal)` becomes `Domain<Fauna.Animal>()`;
- each declaration form qualified by its module: `Class("Animal")` becomes `RDFCore.Class("Animal")`, because an ontology may declare a term with the same name (`RDFS.Class`, `RDF.Property`).

Which annotations relate terms is read from how they are written, not from a list of annotation names. An annotation whose only argument is a type path (`Fauna.Animal`, or the bare name of a term the ontology declares) relates the declared term to that type. Annotations that carry text take a string literal, which the macro reads at compile time for DocC.

Each returned statement is preceded by `#sourceLocation(file:line:)` for the line it was authored on, so the compiler reports an error in the content (an unknown type in `Type(RDFS.Clas)`) at the authored line. The macros also report at the authored annotation:

- `Domain<Fauna.Animal>()` and `Domain(Fauna.Animal.self)`, with a fix-it to `Domain(Fauna.Animal)`;
- a related term written as a term of this ontology that it does not declare (`Fauna.Habitatt`);
- a class whose individual type name is taken by a declared term;
- a named individual of a class whose requirements the macro cannot see;
- a functional property that would make a value type contain itself.

## Testing

`Tests/RDFKitMacrosTests` pins the member expansion, the `content()` rewrite, the `#sourceLocation` lines and the diagnostics with `SwiftSyntaxMacrosGenericTestSupport`. `Tests/FaunaTests` uses the generated Fauna model as ordinary Swift.
