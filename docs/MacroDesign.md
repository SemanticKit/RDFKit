# The @Ontology Macro

## What It Does

`@Ontology` reads an ontology's DSL content from its `func content()` and generates the Swift model of the ontology inside the ontology struct. RDF, RDFS and OWL model a graph of individuals: class membership is multiple and open, identity is shared, the graph has cycles, and properties have many values unless they are functional. The generated model has the same shape:

| DSL | Generated |
|---|---|
| `Class("Animal")` | `protocol Animal`, and the individual type `final class AnimalIndividual: Animal` |
| `Property("hasHabitat") { Domain(X); Range(Y) }` | a requirement `var hasHabitat: [any Y] { get set }` on protocol `X`, and the term type `struct hasHabitat: PropertyTerm`, which reads and writes the values of any subject: `Fauna.hasHabitat[lion]` |
| a property whose `Domain` is another ontology's class, `rdfs:Resource` or `owl:Thing`, or that has no `Domain` | the term type only: `Cert.key[alice]`, `Foaf.name[alice]` |
| several `Domain`s | a requirement on each, and a term subscript for each and for a subject in all of them |
| several `Range`s | values in all of them: `any Cert.Key & Cert.PublicKey` |
| `Type(OWL.FunctionalProperty)` on a property | the requirement holds at most one value: `var hasDiet: (any Diet)? { get set }` |
| `SubClassOf(X)` | the class protocol refines `X` |
| `Individual("carnivore") { Type(X) }` | `static let carnivore: any X`, the one instance of a final class that conforms to `X` (`X` may be another ontology's class) |
| `Datatype("HTML")`, `rdfs:Literal` and its subclasses | a value type (`struct`) |
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
@ClassProperties
public protocol Animal: RDFCore.Resource {
    var hasHabitat: [any Fauna.Habitat] { get set }
    var hasDiet: (any Fauna.Diet)? { get set }
}

@ClassProperties
public protocol Predator: Fauna.Animal {
    var preysOn: [any Fauna.Animal] { get set }
}

/// An individual of ``Fauna/Predator``.
public final class PredatorIndividual: Fauna.Predator {
    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(
        id: "https://fauna.example.org/ontology#Predator", name: "Predator")

    public let propertyValues = RDFCore.IndividualStorage()

    public init(hasHabitat: [any Fauna.Habitat] = [], hasDiet: (any Fauna.Diet)? = nil, preysOn: [any Fauna.Animal] = []) {
        propertyValues[Fauna.hasHabitat()] = hasHabitat
        propertyValues[Fauna.hasDiet()] = hasDiet
        propertyValues[Fauna.preysOn()] = preysOn
    }

    public var hasHabitat: [any Fauna.Habitat] {
        get { propertyValues[Fauna.hasHabitat()] }
        set { propertyValues[Fauna.hasHabitat()] = newValue }
    }
    // hasDiet and preysOn likewise
}

public static let carnivore: any Fauna.Diet = _carnivoreIndividual()

public struct hasHabitat: RDFCore.PropertyTerm {
    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(
        id: "https://fauna.example.org/ontology#hasHabitat", name: "hasHabitat")
    public typealias Domain = any Fauna.Animal
    public typealias Range = any Fauna.Habitat
    public typealias Value = [any Fauna.Habitat]
    public static var noValues: Value { [] }
    public init() {}

    public static subscript(subject: any Fauna.Animal) -> Value {
        get { subject.propertyValues[Self()] }
        set { subject.propertyValues[Self()] = newValue }
    }
}

// At file scope, from @ClassProperties on Fauna.Animal:
extension Fauna.Animal {
    public var hasHabitat: [any Fauna.Habitat] {
        get { propertyValues[Fauna.hasHabitat()] }
        set { propertyValues[Fauna.hasHabitat()] = newValue }
    }
    // hasDiet likewise
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
Fauna.preysOn[lion] == lion.preysOn          // the same values, through the term
```

## Classes Are Protocols

A class is a set of individuals, and an individual can be in several classes. A Swift protocol says the same: a type conforms to as many protocols as it needs. The class protocol's requirements are the properties whose `Domain` is the class, so anything that is an `Animal` has `hasHabitat`. `SubClassOf(X)` becomes refinement, so a `Predator` is an `Animal`, and a class with two superclasses refines both. A class with no superclass refines `RDFCore.Resource` (`rdfs:Resource`), which is `AnyObject` and `Entity`.

## Individuals Are Objects

An individual is an instance of a final class. Its identity inside the runtime is the object itself: the zebra a lion preys on is the zebra that lives in the savanna, not a copy of it, so a graph with cycles is built with ordinary references. No IRI or name stands in for an individual.

Each class protocol gets an individual type named after the class, `AnimalIndividual`, that conforms to the protocol and stores every requirement of the class and its superclasses. A named individual declared with `Individual("carnivore")` becomes a static constant of the ontology, the one instance of a private final class that conforms to all of its classes, so `Fauna.carnivore` is the same object wherever it is used.

Every class gets an individual type, also one that refines another ontology's class, except `owl:Nothing`, which has no individuals. `Foaf.PersonIndividual` conforms to `Geo.SpatialThing` and `Contact.Person`, whose requirements the FOAF ontology cannot see: see [Properties Are Kept by Their Term](#properties-are-kept-by-their-term). A named individual can be of another ontology's class too.

Individuals are `Sendable` as checked by the compiler: the property values of an individual live in one `RDFCore.IndividualStorage`, a mutex, and each read and each write of a property takes the lock.

## Properties Are Kept by Their Term

An individual keeps the values of each property under the property's term type: `propertyValues[Fauna.hasHabitat()]`. `RDFCore.IndividualStorage` finds them by the type, never by an IRI or a name, so one individual holds the values of properties from any number of ontologies without mixing them up.

Each property term type conforms to `RDFCore.PropertyTerm` and has a static subscript that takes a subject of its `Domain`: `Fauna.hasHabitat[lion]`. This is how a property is used on a class of another ontology. `cert:key` has the domain `foaf:Agent`, and the cert ontology cannot add a requirement to the FOAF protocol, so a key is written `Cert.key[alice] = [key]`. A property with no domain, or the domain `rdfs:Resource` or `owl:Thing` of another ontology, takes any resource: `Solid.oidcIssuer[alice]`, `Foaf.name[alice]`. A property with several domains has a subscript for each, and one for a subject in all of them.

A macro can extend only the type it is attached to, so `@Ontology` attaches the extension macro `@ClassProperties` to each class protocol it generates. `@ClassProperties` gives every requirement of the protocol a default implementation that reads and writes the same storage. That is what lets an individual type of one ontology conform to another ontology's class: `Cert.X509CertificateIndividual` conforms to `Foaf.Document` and has its `primaryTopic`. The individual types an ontology generates implement the requirements they know themselves, so a property of two classes an individual is in has one implementation.

The term types of `rdfs:subClassOf` and the other annotations RDFCore provides are aliases of RDFCore types, not property terms, so a requirement made from one of them keeps its values under a key type the macro generates beside the alias, `RDFS._subClassOfValues`.

## Properties Are Many-Valued

A property has any number of values unless it is functional, so its requirement is an array of its range: `[any Fauna.Habitat]`, `[String]`. A property typed `OWL.FunctionalProperty`, or a subproperty of one, has at most one value and its requirement is optional: `(any Fauna.Diet)?`, `String?`.

Values are typed by the property's `Range`. A class range is the class protocol, `any Fauna.Habitat`. A literal range is a Swift value type: `RDFS.Literal` and `XSD.string` are `String`, `XSD.nonNegativeInteger` is `UInt`, `XSD.hexBinary` and `XSD.base64Binary` are `[UInt8]`. A property without a `Range`, or with the range `rdfs:Resource` or another ontology's `owl:Thing`, holds `any RDFCore.Resource`. A property with several ranges holds values that are in all of them: `any Cert.Key & Cert.PublicKey`.

## Datatypes Are Values

Literals have no identity, so `Datatype(...)` declarations, `rdfs:Literal` and the classes that are subclasses of it become structs. A functional property of a value type cannot range over the value type itself, because the struct would contain itself; the macro reports that at the property.

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
- a functional property that would make a value type contain itself.

## Testing

`Tests/RDFKitMacrosTests` pins the member expansion, the `@ClassProperties` default implementations, the `content()` rewrite, the `#sourceLocation` lines and the diagnostics with `SwiftSyntaxMacrosGenericTestSupport`. `Tests/FaunaTests` uses the generated Fauna model as ordinary Swift. `Tests/VocabularyTests` uses the FOAF, cert, ACL, ACP, LDP and Solid vocabularies the same way, and builds a WebID profile across them.
