# The @Vocabulary Macro

## What It Does

`@Vocabulary` reads the ontology's DSL content tree and generates typed term structs with protocol conformances. It bridges the DSL declarations to a type-safe API.

## How It Works

```swift
@Vocabulary
public struct OWL: Ontology {
    public var content: Content {
        Namespace("http://www.w3.org/2002/07/owl#")

        Class("Thing") {
            Type(OWLTerm.Class)
            Label("Thing")
            Comment("The class of OWL individuals.")
        }

        Property("sameAs") {
            Type(RDFTerm.Property)
            Domain(OWLTerm.Thing)
            Range(OWLTerm.Thing)
            Label("sameAs")
            Comment("The property that determines that two given individuals are equal.")
        }
    }
}
```

The macro generates:

```swift
extension OWL {
    public struct ThingTerm: OntologyTerm, TypedTerm, SubClassedTerm, LabeledTerm, CommentedTerm {
        public let name = "Thing"
        public let iri = IRI("http://www.w3.org/2002/07/owl#Thing")
        public let kind: TermKind = .class
        public let children: [any Node]

        public init() {
            self.children = [
                TypeAnnotationValue(OWLTerm.Class),
                LabelAnnotationValue("Thing"),
                CommentAnnotationValue("The class of OWL individuals.")
            ]
        }
    }

    public static let Thing = ThingTerm()

    public struct SameAsTerm: OntologyTerm, TypedTerm, DomainTerm, RangeTerm, LabeledTerm, CommentedTerm {
        public let name = "sameAs"
        public let iri = IRI("http://www.w3.org/2002/07/owl#sameAs")
        public let kind: TermKind = .property
        public let children: [any Node]

        public init() {
            self.children = [
                TypeAnnotationValue(RDFTerm.Property),
                DomainAnnotationValue(OWLTerm.Thing),
                RangeAnnotationValue(OWLTerm.Thing),
                LabelAnnotationValue("sameAs"),
                CommentAnnotationValue("The property that determines that two given individuals are equal.")
            ]
        }
    }

    public static let sameAs = SameAsTerm()
}
```

## Generated Types

For each `Class("Name")`, `Property("Name")`, `Individual("Name")`, or `Datatype("Name")` in the content body:

1. **`{Name}Term` struct** — conforms to `OntologyTerm` plus contribution protocols based on annotations present
2. **`{Name}` static property** — returns an instance of the struct

### Contribution Protocols

The macro reads annotations and generates conformances:

| DSL Annotation | Protocol | Computed Property |
|---|---|---|
| `Type(...)` | `TypedTerm` | `type`, `types` |
| `Label("...")` | `LabeledTerm` | `label` |
| `Comment("...")` | `CommentedTerm` | `comment` |
| `SubClassOf(...)` | `SubClassedTerm` | `subClassOf` |
| `SubPropertyOf(...)` | `SubPropertyOfTerm` | `subPropertyOf` |
| `Domain(...)` | `DomainTerm` | `domain` |
| `Range(...)` | `RangeTerm` | `range` |
| `SeeAlso("...")` | `SeeAlsoTerm` | `seeAlso` |
| `OWLDeprecated()` | `DeprecatedTerm` | `isDeprecated` |
| `.isDeclaredBy(...)` | `DeclaredByTerm` | `declaredIn` |

## Naming Conflicts

DSL method names (`Class`, `Property`, `Individual`, `Datatype`) conflict with generated static properties. The macro skips static property generation for these four names. Access the struct directly instead: `OWL.ClassTerm`.

## Cross-Ontology References

Annotations reference other ontologies' terms directly:

```swift
Class("AllDifferent") {
    Type(RDFSTerm.Class)        // references RDFS ontology
    SubClassOf(RDFSTerm.Resource)
}
```

The generated code preserves these references as-is.

## Content Modifiers

Domain-specific modifiers chain on term declarations:

```swift
Class("PlainLiteral") {
    Type(RDFSTerm.Datatype)
    Label("PlainLiteral")
}.deprecated()                    // adds OWLDeprecatedAnnotationValue
```

The macro recognizes `.deprecated()` and `.isDeclaredBy(namespace:)` as chained method calls.
