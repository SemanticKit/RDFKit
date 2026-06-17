# Layer 2: DSL Vocabulary Types — Final Plan

## Design Principles

1. **DSL terms match RDF/RDFS/OWL vocabulary names 1:1** — `Class` = `rdfs:Class`, `Label` = `rdfs:label`, etc.
2. **Protocol-oriented** — protocols define roles, structs conform
3. **Easy, clean, productive** — a developer who knows RDF can write the DSL immediately
4. **`@ContentBuilder` for trailing closures** — existing infrastructure, no new builders needed

## Vocabulary Mapping

| DSL Term        | RDF/RDFS/OWL Concept     | Pattern                      |
| --------------- | ------------------------ | ---------------------------- |
| `Class("Name")`   | `rdfs:Class`               | Declaration (name + closure) |
| `Property("Name")`| `rdf:Property`             | Declaration (name + closure) |
| `Individual("Name")`| instance declaration     | Declaration (name + closure) |
| `Datatype("Name")`| `rdfs:Datatype`            | Declaration (name + closure) |
| `Type(term)`      | `rdf:type`                 | Term reference annotation    |
| `SubClassOf(term)`| `rdfs:subClassOf`          | Term reference annotation    |
| `SubPropertyOf(term)`| `rdfs:subPropertyOf`     | Term reference annotation    |
| `Domain(term)`    | `rdfs:domain`              | Term reference annotation    |
| `Range(term)`     | `rdfs:range`               | Term reference annotation    |
| `Label(text)`     | `rdfs:label`               | String annotation            |
| `Comment(text)`   | `rdfs:comment`             | String annotation            |
| `SeeAlso(url)`    | `rdfs:seeAlso`             | String annotation            |
| `OWLDeprecated()` | `owl:deprecated`           | Flag annotation              |

## Protocol Hierarchy

```
Node
  └─ TermContent (marker: can appear as child of a term declaration)
       ├─ TermDeclarationProtocol (name + children)
       │   ├─ ClassDeclaration
       │   ├─ PropertyDeclaration
       │   ├─ IndividualDeclaration
       │   └─ DatatypeDeclaration
       ├─ TypeAnnotation
       ├─ SubClassOfAnnotation
       ├─ SubPropertyOfAnnotation
       ├─ DomainAnnotation
       ├─ RangeAnnotation
       ├─ LabelAnnotation
       ├─ CommentAnnotation
       ├─ SeeAlsoAnnotation
       └─ OWLDeprecatedAnnotation
```

## Concrete Types

### TermDeclaration (single struct, multiple conformance)

```swift
public enum TermKind: Sendable {
    case `class`, property, individual, datatype
}

public struct TermDeclaration: ClassDeclaration, PropertyDeclaration,
    IndividualDeclaration, DatatypeDeclaration
{
    public let kind: TermKind
    public let name: String
    public let children: [any Node]
}
```

### Annotation Structs

Each is a minimal struct conforming to its protocol:
- `TypeAnnotation` — stores `term: any Node`
- `LabelAnnotation` — stores `text: String`
- `CommentAnnotation` — stores `text: String`
- `DomainAnnotation` — stores `term: any Node`
- `RangeAnnotation` — stores `term: any Node`
- `SubClassOfAnnotation` — stores `term: any Node`
- `SubPropertyOfAnnotation` — stores `term: any Node`
- `SeeAlsoAnnotation` — stores `url: String`
- `OWLDeprecatedAnnotation` — no stored properties

## Free Functions (DSL Entry Points)

```swift
// Declarations — @ContentBuilder processes trailing closures
func Class(_ name: String, @ContentBuilder children: () -> any Node) -> any Node
func Property(_ name: String, @ContentBuilder children: () -> any Node) -> any Node
func Individual(_ name: String, @ContentBuilder children: () -> any Node) -> any Node
func Datatype(_ name: String, @ContentBuilder children: () -> any Node) -> any Node

// Term reference annotations
func Type(_ term: any Node) -> any Node
func SubClassOf(_ term: any Node) -> any Node
func SubPropertyOf(_ term: any Node) -> any Node
func Domain(_ term: any Node) -> any Node
func Range(_ term: any Node) -> any Node

// String annotations
func Label(_ text: String) -> any Node
func Comment(_ text: String) -> any Node
func SeeAlso(_ url: String) -> any Node

// Flag annotations
func OWLDeprecated() -> any Node
```

All return `any Node` for `@ContentBuilder` compatibility.

## DSL Usage (after implementation)

```swift
// In ontology content:
Class("Resource") {
    Type(RDFS.Class)
    Label("Resource")
    Comment("The class resource, everything.")
}
Property("label") {
    Type(RDF.Property)
    Domain(RDFS.Resource)
    Range(RDFS.Literal)
    Label("label")
    Comment("A human-readable name for the subject.")
}
```

Reads exactly like writing RDF — the terms ARE the RDF vocabulary.

## File

`Sources/RDFCore/Vocabulary.swift` — single file, ~100 lines

## What This Enables

- RDF.swift, RDFS.swift, OWL.swift, and tests compile (DSL calls resolve)
- IRI term references (RDFS.Class, RDF.Property) still need Layer 3
