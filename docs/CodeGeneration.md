# Code Generation Architecture

## The Fundamental Rule

Everything declared in the DSL creates a type that conforms to `Entity`. Every Entity is a building block. The content block of an ontology contains Entity declarations.

```swift
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
}
```

`Resource` is an Entity. `label` is an Entity. They are all the same thing. The trailing closure of a declaration contains annotations — not Entities. Annotations describe what the declaration does. Properties declare their domain and range inside themselves.

Entity instances are what you get when you call `ontology.content`. The content block is evaluated at runtime. Each DSL function call (Class, Property, etc.) returns an Entity instance. The content property returns an array of these Entity instances.

## Metadata

Every Entity has Metadata. Metadata is a descriptor. It captures what the Entity does. It is not a node. It describes the Entity.

Metadata has CodingKeys. The CodingKeys enumerate the properties. The properties are the children. The children describe what the Entity contains.

The `ContentMetadata` protocol defines the minimum shape: `id` and `name`. Concrete Metadata types have more properties based on what the Entity declares.

## Behaviors

Some elements have behaviors — actions that drive code generation. Others are just declarations.

- `Label("...")` — overrides the output name
- `Comment("...")` — adds a documentation comment
- `Domain(X)` — attaches a property to class X
- `Range(Y)` — sets the type of the property value
- `SubClassOf(X)` — makes the Entity conform to X
- `Deprecated` — adds `@available(*, deprecated)`

Today, behaviors are hard-coded in the macro. The macro reads the DSL and generates code based on what it finds.

## Code Generation Flow

1. Macro parses the DSL content block
2. For each declaration, it generates a struct conforming to `Entity`
3. Each struct has nested `Metadata` — the descriptor
4. Metadata captures what the declaration does
5. The code generator reads Metadata to produce Swift code
6. Properties with Domain/Range attach stored properties to the domain class

## The Macro Must

1. Parse all declarations in the content block
2. Collect Property declarations with their Domain/Range
3. For each Class declaration, look up which Properties have it as their Domain
4. Generate stored properties on the Class struct based on those Properties
5. Generate Metadata capturing all annotations (Label, Comment, etc.)
6. Generate `callAsFunction` that accepts `@EntityContentBuilder` and returns `Metadata`

## The Protocol

`Entity` provides a default `callAsFunction` — the base DSL shape. The macro generates additional overloads based on Metadata. These are overloads, not replacements.

## What Needs to Change

The macro currently generates:
- Struct with `Entity, IRIIdentifiable, Sendable`
- Metadata with `Codable, Identifiable, Sendable`
- `callAsFunction` returning `TermDeclaration`
- Properties from annotations inside Metadata only

The macro needs to generate:
- Struct with `Entity, Sendable`
- Metadata conforming to `ContentMetadata`
- `callAsFunction` returning `Metadata` with `@EntityContentBuilder`
- Properties from Domain/Range as stored properties on the domain class struct
