# Swift Integration

## How RDF Becomes Swift

| RDF | Swift |
|---|---|
| A class | A protocol. `rdfs:subClassOf` is protocol inheritance (D1). |
| `rdfs:Resource`, `owl:Thing` | The root protocol, `RDFS.Resource`. `OWL.Thing` is a typealias of it (D7). |
| `owl:Nothing` | `Never` (D7) |
| A property | A requirement on its domain's protocol (D4) |
| A many-valued property | `Values<any Range>`, a set of values (D5) |
| An `owl:FunctionalProperty` | `(any Range)?`. `nil` means no value is stated (D5). |
| An individual | An instance of a generated final class that conforms to the protocols of its classes (D2). Its identity is the object's, `===` (D3). |
| A literal | The Swift value type of its datatype (D6). `RDFCore.Literal` is used only at the boundary (rule 20). |
| An annotation | DocC on the declaration (D8) |

## Datatypes

The XML Schema datatypes RDF uses are generated into `XSD` from the W3C documents:

| Datatype | Swift |
|---|---|
| `xsd:string`, `xsd:boolean`, `xsd:double`, `xsd:float` | `String`, `Bool`, `Double`, `Float`: their value spaces are exactly these Swift types |
| `xsd:decimal`, `xsd:integer` and its derivations | `XSD.decimal`, `XSD.integer`, `XSD.long`, …, which hold a `DecimalNumber` or `BigInteger` and check their facets in a throwing `init(_:)` |
| `xsd:dateTime`, `xsd:date` and the other date and time types | `XSD.dateTime`, …, on the seven-property model, with a `Date` view where one exists |
| `xsd:duration` and its derivations | `XSD.duration`, `XSD.dayTimeDuration`, `XSD.yearMonthDuration` |
| `xsd:hexBinary`, `xsd:base64Binary` | `XSD.hexBinary`, `XSD.base64Binary`, holding `[UInt8]` |
| `xsd:anyURI` | `XSD.anyURI`, with a `URL` view |

Each has `init(lexicalForm:)`, the datatype's lexical mapping.

## Values

`Values<Element>` keeps a set's meaning without hashing. Swift 6.4.2 cannot hash an existential such as `any FOAF.Person`, so a `Set` of one does not compile (SE-0309). Two individuals are the same value when they are the same object, and two literals when their Swift values are equal.

```swift
alice.knows.insert(bob)
alice.knows.contains { $0 === bob }
```

## Usage

```swift
import AliceProfile
import FOAF

alice.knows.contains { $0 === bob }   // true
let triples = try NTriplesEncoder().encode(alice)
```

A property whose range is a class takes the individuals of that class, and the compiler checks the range.
