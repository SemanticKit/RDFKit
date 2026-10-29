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

Content elements are what you get when you call `ontology.content()`. The content block is evaluated at runtime. Each DSL function call (Class, Property, etc.) returns a declaration value, an `RDFCore.ContentElement`; the term it declares is the generated type, which is the Entity. A declaration value has no metadata of its own, so `Class("Animal")` never claims the identity of `rdfs:Class`, which belongs to the generated `RDFS.Class`. The content property returns an array of these content elements.

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

1. `@Ontology` parses the declarations in the `content()` body as syntax.
2. A `Class` becomes a protocol. Its requirements are the properties whose `Domain` is the class, many-valued (`RDFCore.PropertyValues<Range>`) unless the property is an `owl:FunctionalProperty` (`RDFCore.PropertyValue<Range>`). `SubClassOf(X)` becomes refinement of `X`.
3. Each class protocol carries `@StoredRequirements`, which implements its requirements for `RDFCore.StoredIndividual`, so any individual type of the class or of a subclass, in any ontology, has them.
4. Each class also gets an individual type, a final class conforming to the protocol and created in an `RDFCore.IndividualGraph`. Its instances are individuals; their identity is the object.
5. An `Individual` becomes a static constant, the one instance of a private final class that conforms to its classes.
6. A `Datatype`, `rdfs:Literal` and its subclasses become value types that store the literal.
7. A `Property` also becomes a term type that names its `Domain` and `Range` as type aliases.
8. Each generated type has static `metadata` with its IRI, computed from the namespace during expansion and read only at the boundary.
9. The body macro `@OntologyContent` rewrites the authored `content()` body so it builds the same declarations from the generated types.

See `MacroDesign.md` for the generated code and the reasons for each shape.
