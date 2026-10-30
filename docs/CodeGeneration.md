# Code Generation Architecture

## The Fundamental Rule

Everything declared in the DSL generates the Swift form of what it declares. A `Class` declaration generates a Swift class (a class can be a protocol), a `Property` generates a property on the classes of its domain, and an `Individual` generates an instance of its declared classes. The content block of an ontology, its `var body`, contains these declarations. The DSL forms themselves conform to `Entity`: they are syntax that `@Ontology` reads, not the generated types.

```swift
Class("Resource") {
    Type(RDF.Class)
    Label("Resource")
    Comment("The class resource, everything.")
}

Property("label") {
    Type(RDF.Property)
    Domain(RDF.Resource)
    Range(RDF.Literal)
    Label("label")
}
```

`Resource` generates a Swift class. `label` generates a property on its domain's class. The trailing closure of a declaration contains its declaration forms. They describe what the declaration states. Properties declare their domain and range inside themselves.

`ontology.body` holds the declarations as written. What users build with is the generated Swift: the classes, their properties, and the instances that are their members.

## Metadata

Every generated class, property and named individual carries its declared key. It is type-level coding information, as a `CodingKey` is for a `Codable` property. It is not a node, and it holds no IRI.

A generated term carries its declared key (`RDFCore.TermKey`: its declared name and its ontology), never an IRI; an encoder derives the IRI from the key and the ontology's namespace at the boundary.

## Behaviors

Some elements have behaviors — actions that drive code generation. Others are just declarations.

- `Label("...")` — documents the generated declaration (DocC)
- `Comment("...")` — adds a documentation comment (DocC)
- `Domain(X)` — attaches a property to class X
- `Range(Y)` — sets the type of the property value
- `SubClassOf(X)` — makes the generated class refine X
- `Deprecated("reason")` — adds `@available(*, deprecated, message: "reason")`

Today, behaviors are hard-coded in the macro. The macro reads the DSL and generates code based on what it finds.

## Code Generation Flow

1. Macro parses the DSL content block in `var body`
2. For each `Class` declaration, it generates a Swift class: a protocol for the class, a storing protocol, and a final class whose instances are its members
3. For each `Property` declaration, it generates a requirement on its domains' protocols, typed by its range, and a property term type that carries its declared key
4. For each `Individual` declaration, it generates the one instance of its declared classes
5. Label and Comment become DocC documentation on the generated declarations
6. Properties with Domain/Range attach to the domain class

## The Macro Must

1. Parse all declarations in the content block
2. Collect Property declarations with their Domain/Range
3. For each Class declaration, look up which Properties have it as their Domain
4. Generate those Properties as requirements of the Class's protocol and as members of its instances
5. Generate DocC from Label and Comment, and `@available` from `Deprecated`
6. Give each generated class, property and individual its declared key, and no stored or static IRI

## The Protocol

`Entity` is the protocol of the DSL forms: `Class`, `Property`, `Datatype`, `Individual` and the annotations. They carry no RDF of their own; what `rdfs:Class` or `rdfs:label` is comes from the one translation of rdf.ttl, rdfs.ttl and owl.ttl, whose types the generated code names.

## What the Macro Generates

- For a class, a protocol, a storing protocol and a final class, with no stored `rdfType`: membership is the type system
- A declared key (`RDFCore.TermKey`) as type-level coding information, and no stored or static IRI and no `init(iri:)`
- DocC documentation from Label and Comment
- Properties from Domain/Range as requirements on the domain class's protocol and members of its instances
