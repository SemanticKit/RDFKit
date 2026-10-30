# ContentModifier Design

## Pattern (unlike SwiftUI's ViewModifier)

In SwiftUI:
```swift
Text("Hello")
    .padding()
    .foregroundColor(.red)
    .background(.blue)
```

Each modifier is a method on a view instance that returns a modified view. Setting a view's background makes sense: the view is an instance.

An ontology declares types, and declared types are not modified. RDFKit has no content modifiers (`add*`, `isDeclaredBy`). Everything a declaration states goes inside its trailing closure, as DSL declaration forms, in the ontology's `var body`:
```swift
Class("Foo") {
    Label("Foo")
    Comment("Bar")
    Deprecated("Use Baz.")
}
```

Each concept has three forms: RDF, DSL and Swift.

| RDF | DSL | Swift |
|---|---|---|
| `owl:Class` | `Class("Foo")` | `class Foo { }` (a class can be a protocol) |
| `owl:deprecated` | `Deprecated("reason")` | `@available` |
| `rdfs:label`, `rdfs:comment` | `Label`, `Comment` | DocC documentation |

The declaring ontology and namespace come from where the declaration is written (its `@Ontology` type and its `Namespace`), not from a modifier.

## Rules

- A declaration's statements are declaration forms in its trailing closure, never methods chained on the declaration
- `add*` methods are not used: they indicate type modification
- `isDeclaredBy` is not used: the declaration's ontology is where it is written
- `Deprecated("reason")` is a declaration form and generates `@available`
- Declaration forms only state what applies to the declaration they are written in
