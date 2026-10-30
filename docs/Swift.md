# Swift Integration

## How Swift Types Conform to RDF Terms

The DSL enables Swift types to conform to RDF/RDFS/OWL terms. This bridges the gap between Swift's type system and RDF's vocabulary.

## Foundation Conformances

All types should conform to standard Swift protocols where applicable:

```swift
// Namespace conforms to everything useful
public struct Namespace: Node, RawRepresentable, Equatable, Hashable,
    Sendable, Codable, Comparable, LosslessStringConvertible,
    CustomStringConvertible, ExpressibleByStringLiteral {
    // ...
}
```

**Minimum conformance set for all types:**
- `Sendable` — concurrency
- `Equatable` — comparison
- `Hashable` — collections
- `Codable` — serialization
- `CustomStringConvertible` — display

## Collection Conformances

Swift collections can conform to RDF terms using the DSL:

```swift
// A list of resources conforms to rdf:List
extension Array where Element: Resource {
    var rdfList: RDFList<Element> { RDFList(self) }
}

// A set of resources conforms to owl:AllDifferent
extension Set where Element: NamedIndividual {
    var owlAllDifferent: OWLAllDifferent<Element> { OWLAllDifferent(self) }
}
```

## Type Mapping

| Swift Type | RDF Term | Description |
|------------|----------|-------------|
| `String` | `rdfs:Literal` | Literal values |
| `Int`, `Double`, etc. | `xsd:*` datatypes | Numeric datatypes |
| `URL` | `xsd:anyURI` | URI references |
| `Date` | `xsd:dateTime` | Date/time values |
| `Data` | `xsd:hexBinary` | Binary data |
| `Array<T>` | `rdf:List` | Ordered collections |
| `Set<T>` | `owl:AllDifferent` | Unordered collections |
| `Dictionary<K,V>` | `rdf:Property` | Key-value relationships |

## Protocol Conformances

```swift
// A type that can be an RDF subject
protocol RDFSubject: Node, Subject {}

// A type that can be an RDF object
protocol RDFObject: Node, Object {}

// A type that can be an RDF predicate
protocol RDFPredicate: Node, Predicate {}
```

## Custom Type Conformances

A Swift type is not mapped onto an RDF class by hand, and it stores no `rdfType`, label or IRI. Class membership is the type system: a `Class` declared in the DSL (or translated from RDF) generates a Swift class, and a class can be a protocol. An individual is an instance of the classes it belongs to, and the instance is its identity:

```swift
// alice.ttl: :alice a foaf:Person ; foaf:knows :bob .
alice is Person                          // rdf:type is membership in the Swift type
alice is Agent                           // foaf:Person rdfs:subClassOf foaf:Agent
alice.knows.contains { $0 === bob }      // compared as instances, never by IRI
```

`rdfs:label` and `rdfs:comment` on a class become DocC documentation on the generated type, not stored properties. The IRI is derived from the declaration (its ontology and namespace) only at the boundary, when an encoder, decoder or translator asks for it.

## Usage Patterns

```swift
// Create an RDF list from a Swift array
let resources: [Resource] = [person1, person2, person3]
let rdfList = resources.rdfList

// Create an OWL AllDifferent from a Swift set
let individuals: Set<NamedIndividual> = [person1, person2, person3]
let allDifferent = individuals.owlAllDifferent

// Declare classes and properties in an ontology's var body
@Ontology
struct MyOntology: Ontology {
    var body: some Content {
        Namespace("https://example.org/my#")
        Class("Person") {
            Type(RDF.Class)
            Label("Person")
            Comment("A person entity.")
        }

        Property("knows") {
            Domain(MyOntology.Person)
            Range(MyOntology.Person)
            Label("knows")
            Comment("knows another person.")
        }
    }
}
```
