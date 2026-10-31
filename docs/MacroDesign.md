# The @Ontology Macro

## What It Does

`@Ontology` reads the declarations in an ontology's `body` and generates the Swift types they declare, nested in the ontology. It uses the same generators as `RDFTranslator` (`OntologyGeneration`):

- each class becomes a protocol, and its `SubClassOf` classes become the protocols it inherits (D1)
- each property becomes a requirement on its domain's protocol (D4)
- labels and comments become DocC (D8)

It generates no structs, no term values and no stored IRIs.

## How It Works

```swift
@Ontology
public struct RDF: Ontology {
    public var body: some Content {
        Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#")

        Class("List") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Resource)
            Label("List")
            Comment("The class of RDF Lists.")
        }

        Property("first") {
            Type(RDF.Property)
            Domain(RDF.List)
            Range(RDFS.Resource)
            Label("first")
            Comment("The first item in the subject RDF list.")
        }
    }
}
```

The macro adds, as members of `RDF`:

```swift
public struct RDF: Ontology {
    public var body: some Content { … }

    /// The class of RDF Lists.
    ///
    /// Label: List
    public protocol List: RDFS.Resource, AnyObject {
        /// The first item in the subject RDF list.
        ///
        /// Label: first
        var first: Values<any RDFS.Resource> {
            get
            set
        }
    }
}
```

`@Ontology` also attaches `@OntologyBody` to `var body`. That macro owns the authored body, so the declarations are read only as syntax. The terms the body names, such as `RDFS.Class` in `Type(RDFS.Class)`, are checked by the compiler as types through typealiases (`typealias _RDFS_Class = RDFS.Class`). The declarations themselves take no arguments at run time: `Type()`, `SubClassOf()`, `Domain()`, `Range()`.

## What the Declarations Generate

| Declaration | Generates |
|---|---|
| `Class("Name") { … }` | `public protocol Name`, nested in the ontology (D1) |
| `SubClassOf(X)` | `Name` inherits `X`. A class with no `SubClassOf` inherits the root, `RDFS.Resource` (rdfs8). |
| `Type(X)` | Whether the term is a class or a property, as the published semantics entail from it |
| `Property("name") { … }` | A requirement `var name` on its domain's protocol, or its own protocol inheriting its domain when the domain is the root or in another ontology (D4) |
| `Domain(X)` | The protocol the requirement goes on |
| `Range(Y)` | The requirement's type: `Values<any Y>`, or `(any Y)?` for a functional property (D5) |
| `Label("…")`, `Comment("…")` | DocC on the declaration (D8) |

Whether a term is a class, a property, the root, a literal class or functional is decided by `Schema`, from the published semantics, not by the macro (see [CodeGeneration.md](CodeGeneration.md)). A literal class's protocol does not inherit `AnyObject`, because its members are Swift value types (D6).

## Cross-Ontology References

Declarations name other ontologies' terms as types:

```swift
Class("AllDifferent") {
    Type(RDFS.Class)
    SubClassOf(RDFS.Resource)
}
```

The generated protocol inherits `RDFS.Resource` as written.
