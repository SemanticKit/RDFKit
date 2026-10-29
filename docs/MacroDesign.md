# The @Ontology Macro

## What It Does

`@Ontology` reads an ontology's DSL content from its `func content()` and generates the Swift model of the ontology inside the ontology struct. RDF, RDFS and OWL model a graph of individuals: class membership is multiple and open, identity is shared, the graph has cycles, and properties have many values unless they are functional. The generated model has the same shape:

| DSL | Generated |
|---|---|
| `Class("Animal")` | `protocol Animal`, the default implementation of its requirements for stored individuals, and the individual type `final class AnimalIndividual: Animal` |
| `Property("hasHabitat") { Domain(X); Range(Y) }` | a requirement `var hasHabitat: RDFCore.PropertyValues<any Y> { get }` on protocol `X`, and the term type `struct hasHabitat` |
| `Property("equivalentClass") { Domain(RDFS.Class) }`, a domain from another ontology, `RDFS.Resource`, another ontology's `OWL.Thing`, or no domain | `static func values(of: some RDFS.Class & RDFCore.StoredIndividual)` on the term type `struct equivalentClass` |
| several `Domain`s, several `Range`s | a requirement on each domain class; values in every range, `any Cert.Key & Cert.PublicKey` (see [Several Domains and Ranges](#several-domains-and-ranges)) |
| `Type(OWL.FunctionalProperty)` on a property | the requirement holds at most one value: `var hasDiet: RDFCore.PropertyValue<any Diet> { get }` |
| `SubClassOf(X)` | the class protocol refines `X` |
| `Individual("carnivore") { Type(X) }` | `static let carnivore: any X`, the one instance of a final class that conforms to `X` |
| `Datatype("HTML")`, `rdfs:Literal` and its subclasses | a value type (`struct`) that stores the literal and conforms to `RDFCore.LiteralValue` |
| every `Class(...)` and `Datatype(...)` | also `static let animalClass: any RDFS.Class`, the class as a value (see [Classes Are Also Values](#classes-are-also-values)) |
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
@StoredRequirements
public protocol Animal: RDFCore.Resource {
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

A class is a set of individuals, and an individual can be in several classes. A Swift protocol says the same: a type conforms to as many protocols as it needs. The class protocol's requirements are the properties whose `Domain` is the class, so anything that is an `Animal` has `hasHabitat`. `SubClassOf(X)` becomes refinement, so a `Predator` is an `Animal`, and a class with two superclasses refines both. A class with no superclass refines `RDFCore.Resource` (`rdfs:Resource`), which is `AnyObject` and `Entity`.

## Individuals Are Objects

An individual is an instance of a final class. Its identity inside the runtime is the object itself: the zebra a lion preys on is the zebra that lives in the savanna, not a copy of it, so a graph with cycles is built with ordinary references. No IRI or name stands in for an individual.

Each class protocol gets an individual type named after the class, `AnimalIndividual`, that conforms to the protocol and to `RDFCore.StoredIndividual`. A named individual declared with `Individual("carnivore")` becomes a static constant of the ontology, the one instance of a private final class that conforms to all of its classes, so `Fauna.carnivore` is the same object wherever it is used. `owl:Nothing` and its subclasses have no individuals, so they get no individual type.

An individual type stores only its `RDFCore.Membership`. `@Ontology` attaches `@StoredRequirements` to every class protocol it generates, and that extension macro implements each requirement of the protocol for `StoredIndividual`: the values live in the membership under the requirement's own key path (`\Self.hasHabitat`). The key is the requirement itself, a type-level identity, not a name: a property inherited along two paths (a `Mesopredator` is a predator and a prey, both animals) has one store. Because the implementations come with the protocol, an individual type has the requirements of every class it conforms to, declared in its own ontology or in another: `Fauna.Habitat` refines `OWL.Thing`, so `Fauna.HabitatIndividual` has `sameAs`; `OWL.ClassIndividual` has `subClassOf` from `RDFS.Class`; and `Individual("faunaOntology") { Type(OWL.Ontology) }` is a named individual of OWL's class. The individual type's initializer takes the values of the properties its own ontology declares; inherited properties of other ontologies' classes start empty and are set through their views.

Individuals are `Sendable` as checked by the compiler, with no `@unchecked`. Each property is read through an `RDFCore.PropertyValues` or `RDFCore.PropertyValue` view, and the store behind it guards the values with a mutex. Every method holds the lock for the whole change, so a read-modify-write such as `savanna.inhabitedBy.append(zebra)` is atomic and concurrent appends from many tasks all land; `update { values in ... }` does any other change in one step. Reads (`values`, `first`, `count`, iteration) see one snapshot. A property cannot be named `membership`, which every individual type uses; the macro reports it at the declaration.

## Individuals Live in a Graph

Properties link individuals in cycles (`hasHabitat` and `inhabitedBy`, `owl:sameAs`), and a cycle of strong references never frees itself. So each individual type is created in an `RDFCore.IndividualGraph`: `Fauna.PredatorIndividual(in: graph)`. The graph owns what its individuals store, and every individual holds its graph:

- A store keeps an individual of its graph as the graph's node for it, not as the object. Values link nodes, so the objects never hold each other, and an individual object is freed as soon as nothing outside the graph holds it. Reading the value again gives back the same object while anything holds it, and otherwise a new object of the same type on the same node, with the same values.
- An individual, and any property view of one (`let names = lion.commonName`), holds its graph. So the graph and everything in it stay alive while anything holds one of its individuals: a function can build a graph, return one individual and drop the graph, and the individual keeps its values and everything they link to.
- Once nothing holds the graph or any of its individuals, the graph is released, empties every store, and so breaks every cycle among its nodes. Everything is freed together.

A value links individuals of one graph; storing an individual of another graph stops the program. Named individuals such as `Fauna.carnivore` are static constants, belong to no graph and can be stored in any graph. Their own values are fixed: changing them stops the program, so nothing one graph asserts reaches another.

## Several Domains and Ranges

RDFS reads several `rdfs:domain`s as an intersection: a subject of the property is in every domain. The macro departs from that on purpose and makes the property a requirement of each domain class, because the published vocabularies use several domains to mean a union: `cert:modulus` has the domains `cert:RSAKey` and `cert:DSAKey`, and its comment reads "The modulus of an RSA public and private key. Or the modulus of a DSA Key." Under the intersection reading an RSA key with a modulus would also be a DSA key. The term's `Domain` type alias is the composition, a subject in all of them, and so is the subject of `values(of:)` for a property whose domains are all other ontologies' classes.

Several `Range`s keep the RDFS reading: a value is in all of them, so class ranges become a protocol composition, `any Cert.Key & Cert.PublicKey`. A literal has one datatype, so a property with several datatype ranges (`cert:modulus` is `xsd:hexBinary` or `xsd:base64Binary`) holds literals of any of them, `any RDFCore.LiteralValue`, and a reader casts to the datatype it finds: `key.modulus.first as? XSD.hexBinary`.

## Classes Are Also Values

Some properties take a class as their value: `acl:agentClass foaf:Agent` grants access to every agent, `acl:mode acl:Read` names an access mode, and `solid:forClass` registers a class in a type index. A class protocol is a type, not a value, and a metatype or an IRI would stand in for the class, so for every `Class(...)` and `Datatype(...)` the macro also generates a static constant that is the class as a value: an individual of the class's `rdf:type`, at the class's IRI.

```swift
let publicRead = ACL.AuthorizationIndividual(in: graph, accessTo: [document], agentClass: [Foaf.agentClass], mode: [ACL.readClass])
publicRead.agentClass.first === Foaf.agentClass   // true: one object
```

The constant is named after the class with a lowercase first word and `Class`: `Foaf.agentClass`, `Cert.rsaPublicKeyClass`, `XSD.nonNegativeIntegerClass`. It conforms to the classes the declaration's `Type(...)` names, or to `RDFS.Class` when it names none, so `Foaf.agentClass` is `any RDFS.Class & OWL.Class`. Like a named individual it belongs to no graph and its own values are fixed. It is not an individual of the class it names: `Foaf.agentClass is any Foaf.Agent` is false.

## Properties Are Many-Valued

A property has any number of values unless it is functional, so its requirement is a collection of its range, `RDFCore.PropertyValues<any Fauna.Habitat>`, which is a `Sequence` and takes `append`, `replace(with:)` and `removeAll(where:)`. `update(_:)` and `removeAll(where:)` run their closure while holding the property's lock, so the closure must not read or change the same property of the same individual. A property typed `OWL.FunctionalProperty` (however it is qualified, `RDFKit.OWL.FunctionalProperty` too), or a subproperty of one, has at most one value and its requirement is `RDFCore.PropertyValue<any Fauna.Diet>`, whose `value` is optional. An individual type's initializer takes the values as an array or an optional.

Values are typed by the property's `Range`. A class range is the class protocol, `any Fauna.Habitat`. A literal range is the datatype's value type: `RDFS.Literal`, `XSD.nonNegativeInteger`, `Fauna.Kilograms`. A property without a `Range`, or with the range `rdfs:Resource` or another ontology's `owl:Thing`, holds `any RDFCore.Resource`. For several ranges see [Several Domains and Ranges](#several-domains-and-ranges).

## Properties of Another Ontology's Classes

A property's domain can be a class another ontology declares (`owl:equivalentClass` has `rdfs:Class` as domain) or `rdfs:Resource` (`rdfs:label`, `owl:versionInfo`). Such a property cannot be a requirement of the domain's protocol, because that protocol is declared elsewhere, and an extension of it would be a file-scope declaration, which a macro can only write for the type it is attached to: the compiler turns an extension macro's `extension RDFS.Class` into an extension of the ontology struct. So the property's term type reads and changes its values, on any stored individual of the domain, in any module:

    OWL.equivalentClass.values(of: feline).append(cat)
    RDFS.label.values(of: lion).append(RDFS.Literal("Löwe", languageTag: "de"))

`values(of:)` takes `some RDFS.Class & RDFCore.StoredIndividual`, every domain of the property, so it applies only to individuals of the domain; a functional property has `value(of:)`. The values live in the individual's membership like any other, stored under the term type.

The terms RDFCore provides (`rdfs:label` is `RDFCore.Label`, `rdfs:subPropertyOf` is `RDFCore.SubPropertyOf`) cannot name their ranges, which RDFS and OWL declare, so RDFKit gives them their `values(of:)` in `Sources/RDFKit/RDFCoreTerms+PropertyValues.swift`. The expansion of the vocabulary that declares each one checks that accessor against the declared domain and range, so the declaration stays the source of truth: a mismatch does not compile.

A property with no domain applies to any resource, and so does one whose domain is another ontology's `owl:Thing`: every individual is an `owl:Thing`, but another ontology's classes need not say they refine it. Their `values(of:)` takes any stored individual, which is how most Solid terms are written:

    Cert.key.values(of: alice).append(aliceKey)   // cert:key: foaf:Agent -> cert:Key and cert:PublicKey
    Solid.oidcIssuer.values(of: alice)            // no domain
    Foaf.name.values(of: alice).append("Alice")   // the domain owl:Thing of another ontology

`rdf:type` has no accessor: an individual's classes are the protocols its type conforms to. A property whose domain is a literal class, or anything but a class, is reported at its `Domain`. A domain that is a value type RDFCore provides (`rdfkit:Prefix`) describes a field that type stores.

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
- a term declared twice, at the second declaration, and two local names that become the same Swift identifier (`version-1` and `version_1`);
- a class whose individual type name is taken by a declared term, and a class whose value's name is (`animalClass`);
- a property named `membership` with a class as its domain;
- a property whose domain is a literal class or not a class (`Domain(RDFS.Literal)`);
- a functional property that would make a value type contain itself.

## Testing

`Tests/RDFKitMacrosTests` pins the member expansion, the `content()` rewrite, the `#sourceLocation` lines and the diagnostics with `SwiftSyntaxMacrosGenericTestSupport`. `Tests/FaunaTests` uses the generated Fauna model as ordinary Swift, and `Tests/VocabularyTests` the Solid vocabularies, across ontologies.
