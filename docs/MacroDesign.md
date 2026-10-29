# The @Ontology Macro

## What It Does

`@Ontology` reads an ontology's DSL content from its `func content()` and generates the Swift model of the ontology inside the ontology struct. RDF, RDFS and OWL model a graph of individuals: class membership is multiple and open, identity is shared, the graph has cycles, and properties have many values unless they are functional. The generated model has the same shape:

| DSL | Generated |
|---|---|
| `Class("Animal")` | `protocol Animal`, the default implementation of its requirements for stored individuals, and the individual type `final class AnimalIndividual: Animal` |
| `Property("hasHabitat") { Domain(X); Range(Y) }` | a requirement `var hasHabitat: RDFCore.PropertyValues<any Y> { get }` on protocol `X`, and the term type `struct hasHabitat` |
| `Type(OWL.FunctionalProperty)` on a property | the requirement holds at most one value: `var hasDiet: RDFCore.PropertyValue<any Diet> { get }` |
| `SubClassOf(X)` | the class protocol refines `X`, which may be another ontology's class; a class with no superclass refines `RDFS.Resource` |
| `Property("p") { Domain(RDF.Property) }`, a domain of another ontology | a member `p` of every individual in that domain, through the ontology's extension point `Extending` |
| `Individual("carnivore") { Type(X) }` | `static let carnivore: any X`, the one instance of a final class that conforms to `X`; `Type` may name several classes, of any ontology |
| `Datatype("HTML")`, `rdfs:Literal` and its subclasses | a value type (`struct`) that stores the literal and conforms to `RDFCore.LiteralValue` |
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
@StoredRequirements
public protocol Animal: RDFS.Resource {
    var hasHabitat: RDFCore.PropertyValues<any Fauna.Habitat> { get }
    var hasDiet: RDFCore.PropertyValue<any Fauna.Diet> { get }
}

@StoredRequirements
public protocol Predator: Fauna.Animal {
    var preysOn: RDFCore.PropertyValues<any Fauna.Animal> { get }
}

/// An individual of ``Fauna/Predator``.
public final class PredatorIndividual: Fauna.Predator, RDFCore.StoredIndividual {
    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(
        id: "https://fauna.example.org/ontology#Predator", name: "Predator")

    /// This individual's place in its graph, which stores its property values.
    public let membership: RDFCore.Membership

    private init(membership: RDFCore.Membership) {
        self.membership = membership
    }

    public convenience init(in graph: RDFCore.IndividualGraph, hasHabitat: [any Fauna.Habitat] = [],
                            hasDiet: (any Fauna.Diet)? = nil, preysOn: [any Fauna.Animal] = []) {
        self.init(membership: RDFCore.Membership(in: graph) { PredatorIndividual(membership: $0) })
        graph.insert(self)
        self.hasHabitat.append(contentsOf: hasHabitat)
        self.hasDiet.replace(with: hasDiet)
        self.preysOn.append(contentsOf: preysOn)
    }
}

public static let carnivore: any Fauna.Diet = _carnivoreIndividual()

public struct hasHabitat: RDFCore.Entity {
    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(
        id: "https://fauna.example.org/ontology#hasHabitat", name: "hasHabitat")
    public typealias Domain = any Fauna.Animal
    public typealias Range = any Fauna.Habitat
}

// At file scope, from @StoredRequirements on each class protocol:
extension Fauna.Animal where Self: RDFCore.StoredIndividual {
    public var hasHabitat: RDFCore.PropertyValues<any Fauna.Habitat> {
        RDFCore.PropertyValues(\Self.hasHabitat, of: membership)
    }
    public var hasDiet: RDFCore.PropertyValue<any Fauna.Diet> {
        RDFCore.PropertyValue(\Self.hasDiet, of: membership)
    }
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

A class is a set of individuals, and an individual can be in several classes. A Swift protocol says the same: a type conforms to as many protocols as it needs. The class protocol's requirements are the properties whose `Domain` is the class, so anything that is an `Animal` has `hasHabitat`. `SubClassOf(X)` becomes refinement, so a `Predator` is an `Animal`, and a class with two superclasses refines both. A class with no superclass refines `RDFS.Resource`, the class of everything, which the macro generates from the `rdfs:Resource` declaration in RDFS.swift. It refines `RDFCore.Resource`, the runtime's protocol for an individual object (`AnyObject` and `Entity`), and its requirements are the RDFS properties with `rdfs:Resource` as domain, so every individual has `label`, `comment`, `seeAlso`, `isDefinedBy` and `member`.

## Individuals Are Objects

An individual is an instance of a final class. Its identity inside the runtime is the object itself: the zebra a lion preys on is the zebra that lives in the savanna, not a copy of it, so a graph with cycles is built with ordinary references. No IRI or name stands in for an individual.

Each class protocol gets an individual type named after the class, `AnimalIndividual`, that conforms to the protocol and to `RDFCore.StoredIndividual`. A named individual declared with `Individual("carnivore")` becomes a static constant of the ontology, the one instance of a private final class that conforms to all of its classes, so `Fauna.carnivore` is the same object wherever it is used. `owl:Nothing` and its subclasses have no individuals, so they get no individual type.

An individual type stores only its `RDFCore.Membership`. `@Ontology` attaches `@StoredRequirements` to every class protocol it generates, and that extension macro implements each requirement of the protocol for `StoredIndividual`: the values live in the membership under the requirement's own key path (`\Self.hasHabitat`). The key is the requirement itself, a type-level identity, not a name: a property inherited along two paths (a `Mesopredator` is a predator and a prey, both animals) has one store. Because the implementations come with the protocol, an individual type has the requirements of every class it conforms to, declared in its own ontology or in another: `Fauna.Habitat` refines `OWL.Thing`, so `Fauna.HabitatIndividual` has `sameAs`; `OWL.ClassIndividual` has `subClassOf` from `RDFS.Class`; and `Individual("faunaOntology") { Type(OWL.Ontology) }` is a named individual of OWL's class. Each requirement has one implementation, on the protocol that declares it, so an individual of several classes of other ontologies that share ancestors compiles and stores each inherited property once: `Individual("relativeOf") { Type(OWL.TransitiveProperty); Type(OWL.SymmetricProperty) }` and a class that refines both have one `rdfs:domain`, though both classes refine `RDF.Property` and `RDFS.Resource`. A property with several local domains is required again by a class that refines them all, and a named individual of several of them implements it itself, so its implementation is never ambiguous. The individual type's initializer takes the values of the properties its own ontology declares; inherited properties of other ontologies' classes start empty and are set through their views.

Individuals are `Sendable` as checked by the compiler, with no `@unchecked`. Each property is read through an `RDFCore.PropertyValues` or `RDFCore.PropertyValue` view, and the store behind it guards the values with a mutex. Every method holds the lock for the whole change, so a read-modify-write such as `savanna.inhabitedBy.append(zebra)` is atomic and concurrent appends from many tasks all land; `update { values in ... }` does any other change in one step. Reads (`values`, `first`, `count`, iteration) see one snapshot. A property cannot be named `membership`, which every individual type uses; the macro reports it at the declaration.

## Individuals Live in a Graph

Properties link individuals in cycles (`hasHabitat` and `inhabitedBy`, `owl:sameAs`), and a cycle of strong references never frees itself. So each individual type is created in an `RDFCore.IndividualGraph`: `Fauna.PredatorIndividual(in: graph)`. The graph owns what its individuals store, and every individual holds its graph:

- A store keeps an individual of its graph as the graph's node for it, not as the object. Values link nodes, so the objects never hold each other, and an individual object is freed as soon as nothing outside the graph holds it. Reading the value again gives back the same object while anything holds it, and otherwise a new object of the same type on the same node, with the same values.
- An individual, and any property view of one (`let names = lion.commonName`), holds its graph. So the graph and everything in it stay alive while anything holds one of its individuals: a function can build a graph, return one individual and drop the graph, and the individual keeps its values and everything they link to.
- Once nothing holds the graph or any of its individuals, the graph is released, empties every store, and so breaks every cycle among its nodes. Everything is freed together.

A value links individuals of one graph; storing an individual of another graph stops the program. Named individuals such as `Fauna.carnivore` are static constants, belong to no graph and can be stored in any graph. Their own values are fixed: changing them stops the program, so nothing one graph asserts reaches another.

## Properties for Other Ontologies' Classes

An ontology can declare a property for another ontology's class: RDFS declares `rdfs:domain`, `rdfs:range` and `rdfs:subPropertyOf` for `rdf:Property`, RDF declares `rdf:value` for `rdfs:Resource`, and OWL declares `owl:equivalentClass` for `rdfs:Class` and `owl:versionInfo` for `rdfs:Resource`. The property cannot be a requirement of `RDF.Property`, and Swift lets a macro extend only the declaration it is attached to. So the ontology generates its extension point, `Q.Extending`. It requires the individual's membership, and it has a type alias for each such property that gives the property's domain and value view:

```swift
@StoredRequirements
public protocol Extending: RDFCore.Resource {
    var membership: RDFCore.Membership { get }
    typealias _domain = (any RDF.Property, RDFCore.PropertyValues<any RDFS.Class>)
}
```

`@StoredRequirements` makes each one a member of the extension point wherever the individual is in the domain. The member is stored under its own key path, like a requirement:

```swift
extension RDFS.Extending where Self: RDF.Property {
    public var domain: RDFCore.PropertyValues<any RDFS.Class> {
        RDFCore.PropertyValues(\Self.domain, of: membership)
    }
}
```

Every class the ontology declares without a local superclass refines its extension point. `RDFS.Resource`, the class of everything, refines the extension points of RDF, RDFS and OWL. So every `RDF.Property` has `domain` and `range`, every `rdfs:Class` has `equivalentClass`, and every resource has `rdf:value` and `owl:versionInfo`, on the individual and on an existential such as `any RDF.Property`. An ontology outside RDFKit gives these members to the individuals of its own classes that are in the domain, because no class of another ontology refines its extension point. The macro reports a declared term named `Extending` in an ontology that generates one.

## Properties Are Many-Valued

A property has any number of values unless it is functional, so its requirement is a collection of its range, `RDFCore.PropertyValues<any Fauna.Habitat>`, which is a `Sequence` and takes `append`, `replace(with:)` and `removeAll(where:)`. A property typed `OWL.FunctionalProperty`, or a subproperty of one, has at most one value and its requirement is `RDFCore.PropertyValue<any Fauna.Diet>`, whose `value` is optional. An individual type's initializer takes the values as an array or an optional.

Values are typed by the property's `Range`. A class range is the class protocol, `any Fauna.Habitat`. A literal range is the datatype's value type: `RDFS.Literal`, `XSD.nonNegativeInteger`, `Fauna.Kilograms`. A property without a `Range` holds `any RDFS.Resource`.

## Datatypes Are Values

Literals have no identity, so `Datatype(...)` declarations, `rdfs:Literal` and the classes that are subclasses of it become structs. Each struct is the datatype, and an instance stores one literal of it: the lexical form, and the language tag and base direction RDF allows on strings (`RDFCore.LiteralValue`). `Fauna.Kilograms("190.5")` is a literal whose datatype is `Fauna.Kilograms`, and string literals convert, so `scientificName: "Panthera leo"` stores an `RDFS.Literal`. Two literals are equal when their lexical forms, language tags and directions are. A functional property of a value type cannot range over the value type itself, because the struct would contain itself; the macro reports that at the property.

## Terms Refer to Each Other as Types

Related terms are written with their type as the argument: `Domain(Fauna.Animal)`, `Type(RDFS.Class)`. The macro reads them as syntax. Each term's IRI is computed during expansion from the namespace and the local name, and emitted as a literal in the term's static `metadata`. It is read only at the boundary: serialization, translation into SPARQL or SHACL, dereferencing. Generated code never builds an identity at runtime.

## The content() Body

`@Ontology` attaches the body macro `@OntologyContent` to `func content()`. Swift cannot evaluate `Domain(Fauna.Animal)` as an expression, so the body macro owns the body and returns the same statements with:

- each annotation written as the property term it stands for, which the macro generates from RDF.swift, RDFS.swift and OWL.swift: `Label("Animal")` becomes `RDFS.label("Animal")`, and `Domain(Fauna.Animal)` becomes `RDFS.domain<Fauna.Animal>()`;
- each declaration form qualified by its module: `Class("Animal")` becomes `RDFCore.Class("Animal")`, because an ontology may declare a term with the same name (`RDFS.Class`, `RDF.Property`).

The rewritten annotations and the generated declarations name the vocabularies by their type names (`RDFS.label`, `RDFS.Resource`, `OWL.Extending`), as they are spelled inside RDFKit, which declares a type named `RDFKit` and so cannot be named by its module. An ontology that uses the macro therefore must not declare, or import from another module, its own types named `RDF`, `RDFS` or `OWL`, and must not declare terms with those names.

Which annotations relate terms is read from how they are written, not from a list of annotation names. An annotation whose only argument is a type path (`Fauna.Animal`, or the bare name of a term the ontology declares) relates the declared term to that type. Annotations that carry text take a string literal, which the macro reads at compile time for DocC.

Each returned statement is preceded by `#sourceLocation(file:line:)` for the line it was authored on, so the compiler reports an error in the content (an unknown type in `Type(RDFS.Clas)`) at the authored line. The macros also report at the authored annotation:

- `Domain<Fauna.Animal>()` and `Domain(Fauna.Animal.self)`, with a fix-it to `Domain(Fauna.Animal)`;
- a related term written as a term of this ontology that it does not declare (`Fauna.Habitatt`);
- a term declared twice, at the second declaration, and two local names that become the same Swift identifier (`version-1` and `version_1`);
- a class whose individual type name is taken by a declared term, and a declared term named `Extending` in an ontology that generates its extension point;
- a named individual of `owl:Nothing`, of a datatype, or of a class written without its ontology;
- a property named `membership` with a class as its domain, local or of another ontology;
- a functional property that would make a value type contain itself.

## Testing

`Tests/RDFKitMacrosTests` pins the member expansion, the `@StoredRequirements` extensions, the extension point, the `content()` rewrite, the `#sourceLocation` lines and the diagnostics with `SwiftSyntaxMacrosGenericTestSupport`. `Tests/FaunaTests` uses the generated Fauna model as ordinary Swift, and `Tests/RDFKitTests` does the same with the generated RDF, RDFS, OWL and XSD vocabularies.
