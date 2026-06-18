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

```swift
// Define a custom type that conforms to RDF terms
struct Person: Resource, NamedIndividual {
    let name: String
    let age: Int
    
    // Conform to RDF terms
    var rdfType: RDFS.Class { .Person }
    var rdfLabel: String { name }
    var rdfComment: String { "A person named \(name)" }
}
```

## Usage Patterns

```swift
// Create an RDF list from a Swift array
let resources: [Resource] = [person1, person2, person3]
let rdfList = resources.rdfList

// Create an OWL AllDifferent from a Swift set
let individuals: Set<NamedIndividual> = [person1, person2, person3]
let allDifferent = individuals.owlAllDifferent

// Use custom types in ontologies
let ontology = MyOntology {
    Class("Person") {
        Type(RDFS.Class)
        Label("Person")
        Comment("A person entity.")
    }
    
    Property("knows") {
        Domain(Person.self)
        Range(Person.self)
        Label("knows")
        Comment("knows another person.")
    }
}
```
