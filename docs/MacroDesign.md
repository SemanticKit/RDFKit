# The @Ontology Macro

## What It Does

`@Ontology` reads an ontology's DSL content from its `var body: some Content` and generates the Swift model of the ontology inside the ontology struct. RDF, RDFS and OWL model a graph of individuals: class membership is multiple and open, identity is shared, the graph has cycles, and properties have many values unless they are functional. The generated model has the same shape:

| DSL | Generated |
|---|---|
| `Class("Animal")` | `protocol Animal`, and the individual type `final class AnimalIndividual: Animal` |
| `Property("hasHabitat") { Domain(X); Range(Y) }` | a requirement `var hasHabitat: [any Y] { get set }` on protocol `X`, and the term type `struct hasHabitat` |
| `Type(OWL.FunctionalProperty)` on a property | the requirement holds at most one value: `var hasDiet: (any Diet)? { get set }` |
| `SubClassOf(X)` | the class protocol refines `X` |
| `Individual("carnivore") { Type(X) }` | `static let carnivore: any X`, the one instance of a final class that conforms to `X` |
| `Datatype("HTML")`, `rdfs:Literal` and its subclasses | a value type (`struct`) |
| `Label`, `Comment` | DocC on the generated declaration, and the term's static `metadata` |
| a term RDFCore provides (`rdfs:label`, `rdfs:domain`, `rdfs:Resource`, ...) | a type alias of the RDFCore type |

## Example

```swift
@Ontology
public struct Fauna: Ontology {
    public var body: some Content {
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
    var hasHabitat: [any Fauna.Habitat] { get set }
    var hasDiet: (any Fauna.Diet)? { get set }
}

public protocol Predator: Fauna.Animal {
    var preysOn: [any Fauna.Animal] { get set }
}

/// An individual of ``Fauna/Predator``.
public final class PredatorIndividual: Fauna.Predator {
    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(
        id: "https://fauna.example.org/ontology#Predator", name: "Predator")

    private struct Values: Sendable {
        var hasHabitat: [any Fauna.Habitat]
        var hasDiet: (any Fauna.Diet)?
        var preysOn: [any Fauna.Animal]
    }

    private let storage: RDFCore.IndividualStorage<Values>

    public init(hasHabitat: [any Fauna.Habitat] = [], hasDiet: (any Fauna.Diet)? = nil, preysOn: [any Fauna.Animal] = []) {
        storage = RDFCore.IndividualStorage(Values(hasHabitat: hasHabitat, hasDiet: hasDiet, preysOn: preysOn))
    }

    public var hasHabitat: [any Fauna.Habitat] {
        get { storage.withLock { $0.hasHabitat } }
        set { storage.withLock { $0.hasHabitat = newValue } }
    }
    // hasDiet and preysOn likewise
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
let savanna = Fauna.HabitatIndividual()
let lion = Fauna.PredatorIndividual(hasHabitat: [savanna], hasDiet: Fauna.carnivore)
let zebra = Fauna.AnimalIndividual(hasHabitat: [savanna])
savanna.inhabitedBy = [lion, zebra]
lion.preysOn = [zebra]

lion.preysOn[0] === savanna.inhabitedBy[1]   // true: the same zebra
```

## Classes Are Protocols

A class is a set of individuals, and an individual can be in several classes. A Swift protocol says the same: a type conforms to as many protocols as it needs. The class protocol's requirements are the properties whose `Domain` is the class, so anything that is an `Animal` has `hasHabitat`. `SubClassOf(X)` becomes refinement, so a `Predator` is an `Animal`, and a class with two superclasses refines both. A class with no superclass refines `RDFCore.Resource` (`rdfs:Resource`), which is `AnyObject` and `Entity`.

## Individuals Are Objects

An individual is an instance of a final class. Its identity inside the runtime is the object itself: the zebra a lion preys on is the zebra that lives in the savanna, not a copy of it, so a graph with cycles is built with ordinary references. No IRI or name stands in for an individual.

Each class protocol gets an individual type named after the class, `AnimalIndividual`, that conforms to the protocol and stores every requirement of the class and its superclasses. A named individual declared with `Individual("carnivore")` becomes a static constant of the ontology, the one instance of a private final class that conforms to all of its classes, so `Fauna.carnivore` is the same object wherever it is used.

The macro knows the requirements of the classes the ontology itself declares. A class that refines another ontology's class (other than `rdfs:Resource`) is generated as a protocol only, as is `owl:Nothing`, which has no individuals, and a named individual of such a class is reported as an error at its `Type(...)` annotation.

Individuals are `Sendable` as checked by the compiler: the property values of an individual live in one `RDFCore.IndividualStorage`, a mutex, and each read and each write of a property takes the lock.

## Properties Are Many-Valued

A property has any number of values unless it is functional, so its requirement is an array of its range: `[any Fauna.Habitat]`, `[String]`. A property typed `OWL.FunctionalProperty`, or a subproperty of one, has at most one value and its requirement is optional: `(any Fauna.Diet)?`, `String?`.

Values are typed by the property's `Range`. A class range is the class protocol, `any Fauna.Habitat`. A literal range is a Swift value type: `RDFS.Literal` is `String`, `XSD.nonNegativeInteger` is `UInt`. A property without a `Range` holds `any RDFCore.Resource`.

## Datatypes Are Values

Literals have no identity, so `Datatype(...)` declarations, `rdfs:Literal` and the classes that are subclasses of it become structs. A functional property of a value type cannot range over the value type itself, because the struct would contain itself; the macro reports that at the property.

## Terms Refer to Each Other as Types

Related terms are written with their type as the argument: `Domain(Fauna.Animal)`, `Type(RDFS.Class)`. The macro reads them as syntax. Each term's IRI is computed during expansion from the namespace and the local name, and emitted as a literal in the term's static `metadata`. It is read only at the boundary: serialization, translation into SPARQL or SHACL, dereferencing. Generated code never builds an identity at runtime.

## Owning var body

`@Ontology` attaches the body macro `@OntologyContent` to `var body`, so authors write only `@Ontology` on the type, as in SwiftUI. Swift cannot evaluate `Domain(Fauna.Animal)` as an expression, so the body macro owns the body and returns the same statements with:

- each term annotation written as the annotation type for that term: `Domain(Fauna.Animal)` becomes `Domain<Fauna.Animal>()`;
- each declaration form qualified by its module: `Class("Animal")` becomes `RDFCore.Class("Animal")`, because an ontology may declare a term with the same name (`RDFS.Class`, `RDF.Property`).

Which annotations relate terms is read from how they are written, not from a list of annotation names. An annotation whose only argument is a type path (`Fauna.Animal`, or the bare name of a term the ontology declares) relates the declared term to that type. Annotations that carry text take a string literal, which the macro reads at compile time for DocC.

Each returned statement is preceded by `#sourceLocation(file:line:)` for the line it was authored on, so the compiler reports an error in the content (an unknown type in `Type(RDFS.Clas)`) at the authored line. A body macro on a computed property is given a getter built outside the authored file, so `@Ontology` attaches it as `@OntologyContent(file:line:)` with the file and line of the opening brace of `var body`, and the line of each statement is counted from there.

`@Ontology` reports, with a fix-it, an ontology that writes its content as a `content()` function (the fix-it rewrites it as `var body: some Content` with the same statements) and an ontology with no `var body` (the fix-it adds an empty one). The macros also report at the authored annotation:

- `Domain<Fauna.Animal>()` and `Domain(Fauna.Animal.self)`, with a fix-it to `Domain(Fauna.Animal)`;
- a related term written as a term of this ontology that it does not declare (`Fauna.Habitatt`);
- a class whose individual type name is taken by a declared term;
- a named individual of a class whose requirements the macro cannot see;
- a functional property that would make a value type contain itself.

## Testing

`Tests/RDFKitMacrosTests` pins the member expansion, the `var body` rewrite, the `#sourceLocation` lines and the diagnostics with `SwiftSyntaxMacrosGenericTestSupport`. `Tests/FaunaTests` uses the generated Fauna model as ordinary Swift.
