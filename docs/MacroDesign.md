# The @Ontology Macro

## What It Does

`@Ontology` reads an ontology's DSL content from its `func content()` and generates the Swift model of the ontology inside the ontology struct. RDF, RDFS and OWL model a graph of individuals: class membership is multiple and open, identity is shared, the graph has cycles, and properties have many values unless they are functional. The generated model has the same shape:

| DSL | Generated |
|---|---|
| `Class("Animal")` | `protocol Animal`, and the individual type `final class AnimalIndividual: Animal` |
| `Property("hasHabitat") { Domain(X); Range(Y) }` | a requirement `var hasHabitat: [any Y] { get set }` on protocol `X`, and the term type `struct hasHabitat` |
| `Type(OWL.FunctionalProperty)` on a property | the requirement holds at most one value: `var hasDiet: (any Diet)? { get set }` |
| `SubClassOf(X)` | the class protocol refines `X`, which may be another ontology's class; a class with no superclass refines `RDFS.Resource` |
| `Individual("carnivore") { Type(X) }` | `static let carnivore: any X`, the one instance of a final class that conforms to `X` |
| `Datatype("HTML")`, `rdfs:Literal` and its subclasses | a value type (`struct`) |
| `Label`, `Comment` | DocC on the generated declaration, and the term's static `metadata` |
| the properties the DSL is written with (`rdfs:label`, `rdfs:domain`, `rdf:type`, ...) | annotation types (`RDFS.label`, `RDFS.domain<Term>`), which `content()` is built from |
| RDFKit's `Namespace` and `Prefix` | type aliases of the RDFCore values content is written with |

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
@ClassProtocol
public protocol Animal: RDFS.Resource {
    var hasHabitat: [any Fauna.Habitat] { get set }
    var hasDiet: (any Fauna.Diet)? { get set }

    func _withFauna_AnimalValues<Result: Sendable>(_ body: (inout Fauna.AnimalValues) -> Result) -> Result
    func _withRDFS_ResourceValues<Result: Sendable>(_ body: (inout RDFS.ResourceValues) -> Result) -> Result
}

/// The stored property values of an individual of ``Fauna/Animal``.
public struct AnimalValues: Sendable {
    var hasHabitat: [any Fauna.Habitat] = []
    var hasDiet: (any Fauna.Diet)? = nil
    var _RDFS_Resource = RDFS.ResourceValues()
    public init() {}
}

@ClassProtocol
public protocol Predator: Fauna.Animal {
    var preysOn: [any Fauna.Animal] { get set }

    func _withFauna_PredatorValues<Result: Sendable>(_ body: (inout Fauna.PredatorValues) -> Result) -> Result
    func _withFauna_AnimalValues<Result: Sendable>(_ body: (inout Fauna.AnimalValues) -> Result) -> Result
    func _withRDFS_ResourceValues<Result: Sendable>(_ body: (inout RDFS.ResourceValues) -> Result) -> Result
}

public struct PredatorValues: Sendable {
    var preysOn: [any Fauna.Animal] = []
    var _Fauna_Animal = Fauna.AnimalValues()
    var _RDFS_Resource = RDFS.ResourceValues()
    public init() {}
}

/// An individual of ``Fauna/Predator``.
public final class PredatorIndividual: Fauna.Predator {
    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(
        id: "https://fauna.example.org/ontology#Predator", name: "Predator")

    private let storage: RDFCore.IndividualStorage<Fauna.PredatorValues>

    public init(hasHabitat: [any Fauna.Habitat] = [], hasDiet: (any Fauna.Diet)? = nil, preysOn: [any Fauna.Animal] = []) {
        var values = Fauna.PredatorValues()
        values._Fauna_Animal.hasHabitat = hasHabitat
        values._Fauna_Animal.hasDiet = hasDiet
        values.preysOn = preysOn
        storage = RDFCore.IndividualStorage(values)
    }

    public func _withFauna_PredatorValues<Result: Sendable>(_ body: (inout Fauna.PredatorValues) -> Result) -> Result {
        storage.withLock(body)
    }
}

public static let carnivore: any Fauna.Diet = _carnivoreIndividual()

public struct hasHabitat: RDFCore.Entity {
    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(
        id: "https://fauna.example.org/ontology#hasHabitat", name: "hasHabitat")
    public typealias Domain = any Fauna.Animal
    public typealias Range = any Fauna.Habitat
}

// At file scope, from @ClassProtocol:
extension Fauna.Animal {
    public var hasHabitat: [any Fauna.Habitat] {
        get { _withFauna_AnimalValues { $0.hasHabitat } }
        set { _withFauna_AnimalValues { $0.hasHabitat = newValue } }
    }
    // hasDiet likewise
    public func _withRDFS_ResourceValues<Result: Sendable>(_ body: (inout RDFS.ResourceValues) -> Result) -> Result {
        _withFauna_AnimalValues { body(&$0._RDFS_Resource) }
    }
}

extension Fauna.Predator {
    // preysOn on _withFauna_PredatorValues, and the accessors of
    // Fauna.Animal and RDFS.Resource on their slots in PredatorValues
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

A class is a set of individuals, and an individual can be in several classes. A Swift protocol says the same: a type conforms to as many protocols as it needs. The class protocol's requirements are the properties whose `Domain` is the class, so anything that is an `Animal` has `hasHabitat`. `SubClassOf(X)` becomes refinement, so a `Predator` is an `Animal`, and a class with two superclasses refines both. A class with no superclass refines `RDFS.Resource`, the class of everything, which the macro generates from RDFS.swift as `AnyObject` and `Entity`. Its requirements are the RDFS properties with `rdfs:Resource` as domain, so every individual has `label`, `comment`, `seeAlso`, `isDefinedBy` and `member`.

## Values Live in Slots

Each class protocol `Q.N` comes with a values struct `Q.NValues`: the class's own properties, plus one slot (`_Q_A`) holding the values of each class it refines. The slots are every local ancestor and every class of another ontology that the class or a local ancestor refines directly; a foreign class keeps its own ancestors inside its values. The protocol requires an accessor for its own values (`_withQ_NValues`) and one for each slot.

`@ClassProtocol`, an extension macro the generated protocol carries, implements the class's properties on its own accessor, and each ancestor's accessor on that ancestor's slot. An individual type only implements its own class's accessor. This is what lets a class refine another ontology's class without the macro seeing that class's properties: `OWL.Class` refines `RDFS.Class`, `OWL.ClassValues` keeps an `_RDFS_Class` slot, and RDFS's own extension implements `subClassOf` on it.

When several classes on an individual's path implement the same accessor, Swift uses the one from the most refined protocol, so every path reaches one slot: a `Mesopredator` stores `commonName`, declared on `Animal`, once, though it is both a `Predator` and a `Prey`. A named individual of several classes implements every accessor itself. A property with several local domains is stored by the class that refines them all.

## Individuals Are Objects

An individual is an instance of a final class. Its identity inside the runtime is the object itself: the zebra a lion preys on is the zebra that lives in the savanna, not a copy of it, so a graph with cycles is built with ordinary references. No IRI or name stands in for an individual.

Each class protocol gets an individual type named after the class, `AnimalIndividual`, that conforms to the protocol and keeps the class's values. Its initializer takes the properties of the class and its local superclasses; the properties of another ontology's classes are set on the individual afterwards (`individual.sameAs = [...]`). A named individual declared with `Individual("carnivore")` becomes a static constant of the ontology, the one instance of a private final class that conforms to all of its classes, so `Fauna.carnivore` is the same object wherever it is used.

A named individual can belong to another ontology's class: `Individual("Mammal") { Type(OWL.Class) }` is an `any OWL.Class`. `owl:Nothing` and its subclasses have no individuals, so they get no individual type, and a named individual of one is reported as an error at its `Type(...)` annotation.

Individuals are `Sendable` as checked by the compiler: the property values of an individual live in one `RDFCore.IndividualStorage`, a mutex, and each read and each write of a property takes the lock.

## Properties Are Many-Valued

A property has any number of values unless it is functional, so its requirement is an array of its range: `[any Fauna.Habitat]`, `[String]`. A property typed `OWL.FunctionalProperty`, or a subproperty of one, has at most one value and its requirement is optional: `(any Fauna.Diet)?`, `String?`.

Values are typed by the property's `Range`. A class range is the class protocol, `any Fauna.Habitat`. A literal range is a Swift value type: `RDFS.Literal` is `String`, `XSD.nonNegativeInteger` is `UInt`. A property without a `Range` holds `any RDFS.Resource`.

## Datatypes Are Values

Literals have no identity, so `Datatype(...)` declarations, `rdfs:Literal` and the classes that are subclasses of it become structs. A functional property of a value type cannot range over the value type itself, because the struct would contain itself; the macro reports that at the property.

## Terms Refer to Each Other as Types

Related terms are written with their type as the argument: `Domain(Fauna.Animal)`, `Type(RDFS.Class)`. The macro reads them as syntax. Each term's IRI is computed during expansion from the namespace and the local name, and emitted as a literal in the term's static `metadata`. It is read only at the boundary: serialization, translation into SPARQL or SHACL, dereferencing. Generated code never builds an identity at runtime.

## The content() Body

`@Ontology` attaches the body macro `@OntologyContent` to `func content()`. Swift cannot evaluate `Domain(Fauna.Animal)` as an expression, so the body macro owns the body and returns the same statements with:

- each annotation written as the property term it stands for, which the macro generates from RDF.swift, RDFS.swift and OWL.swift: `Label("Animal")` becomes `RDFS.label("Animal")`, and `Domain(Fauna.Animal)` becomes `RDFS.domain<Fauna.Animal>()`;
- each declaration form qualified by its module: `Class("Animal")` becomes `RDFCore.Class("Animal")`, because an ontology may declare a term with the same name (`RDFS.Class`, `RDF.Property`).

Which annotations relate terms is read from how they are written, not from a list of annotation names. An annotation whose only argument is a type path (`Fauna.Animal`, or the bare name of a term the ontology declares) relates the declared term to that type. Annotations that carry text take a string literal, which the macro reads at compile time for DocC.

Each returned statement is preceded by `#sourceLocation(file:line:)` for the line it was authored on, so the compiler reports an error in the content (an unknown type in `Type(RDFS.Clas)`) at the authored line. The macros also report at the authored annotation:

- `Domain<Fauna.Animal>()` and `Domain(Fauna.Animal.self)`, with a fix-it to `Domain(Fauna.Animal)`;
- a related term written as a term of this ontology that it does not declare (`Fauna.Habitatt`);
- a class whose individual type or values type name is taken by a declared term;
- a named individual of `owl:Nothing` or of something that is not a class protocol;
- a functional property that would make a value type contain itself.

## Testing

`Tests/RDFKitMacrosTests` pins the member expansion, the `@ClassProtocol` extensions, the `content()` rewrite, the `#sourceLocation` lines and the diagnostics with `SwiftSyntaxMacrosGenericTestSupport`. `Tests/FaunaTests` uses the generated Fauna model as ordinary Swift, and `Tests/RDFKitTests` does the same with the generated RDF, RDFS, OWL and XSD vocabularies.
