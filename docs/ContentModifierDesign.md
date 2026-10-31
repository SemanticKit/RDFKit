# Declarations and Their Annotations

RDFKit has no content modifiers. A declaration's annotations are written inside its block, and nothing is chained on a declaration:

```swift
Class("Person") {
    Type(RDFS.Class)
    SubClassOf(FOAF.Agent)
    Label("Person")
    Comment("A person.")
}
```

Chained `.add…(…)` modifiers are a rejected shape (DESIGN-CONTRACT.md, rules 1 and 6), and CI fails when generated Swift contains one.

## Rules

- A declaration's annotations go in its block, one declaration per annotation.
- The declarations carry no data at run time. `@Ontology` reads them as syntax and generates the protocols they declare ([MacroDesign.md](MacroDesign.md)).
- `owl:deprecated`, `rdfs:seeAlso`, `rdfs:isDefinedBy` and the other annotation properties of a translated vocabulary become DocC on the generated declaration (D8).
