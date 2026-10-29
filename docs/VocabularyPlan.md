# The Self-Describing Loop

## Current State

RDF, RDFS, OWL, XSD and the RDFKit vocabulary are declared with the DSL in `Sources/RDFKit`, and each is an `@Ontology` struct. The macro generates their Swift model from that content, the same way it generates the model of any other ontology (see `MacroDesign.md`). There are no hand-written term enums and no `+Terms.swift` files: `RDFS.Class`, `OWL.Thing` and `RDF.List` are types the macro generates.

```swift
@Ontology
public struct OWL: Ontology {
    public func content() -> Content {
        Namespace("http://www.w3.org/2002/07/owl#")

        Class("Thing") {
            Type(OWL.Class)
            Label("Thing")
            Comment("The class of OWL individuals.")
        }

        Property("sameAs") {
            Type(RDF.Property)
            Domain(OWL.Thing)
            Range(OWL.Thing)
            Label("sameAs")
        }
    }
}
```

## What the Standard Vocabularies Become

The vocabularies follow the same rules as any ontology:

- Every class is a protocol: `RDFS.Class`, `RDF.Property`, `RDF.List`, `OWL.Thing`, `OWL.ObjectProperty`, `OWL.FunctionalProperty`. Its requirements are the properties the vocabulary declares with that class as domain (`RDF.List` requires `first` and `rest`; `OWL.Thing` requires `sameAs` and `differentFrom`), and `SubClassOf` becomes refinement (`OWL.Class` refines `RDFS.Class`).
- Every class with individuals gets an individual type, including classes that refine another vocabulary's class: `OWL.ClassIndividual` is an `RDFS.Class` with `subClassOf`, and `OWL.TransitivePropertyIndividual` is an `OWL.ObjectProperty` and an `RDF.Property`. `RDFS.Resource` is the root class, so every individual has `label` and `comment`. `OWL.Nothing` has no individuals and no individual type.
- Named individuals are static constants: `RDF.nil` is the one empty list.
- `rdfs:Literal` and the datatypes (`RDF.HTML`, `RDF.langString`, `XSD.nonNegativeInteger`) are value types.
- Properties are term types (`RDFS.subClassOf`, `OWL.sameAs`) that name their domain and range.

## Bootstrap Terms

Some terms are the DSL itself: content is written with them. The macro generates them from their declarations like every other term, and the content body macro writes each annotation as the term it stands for:

| Written in content | Generated term |
|---|---|
| `Type(X)`, `Domain(X)`, `Range(X)`, `SubClassOf(X)`, `SubPropertyOf(X)` | `RDF.type<X>`, `RDFS.domain<X>`, `RDFS.range<X>`, `RDFS.subClassOf<X>`, `RDFS.subPropertyOf<X>`, generic over the related term |
| `Label("...")`, `Comment("...")` | `RDFS.label`, `RDFS.comment`, which carry the text |
| `SeeAlso("https://...")` | `RDFS.seeAlso`, which carries the address of the document readers dereference |
| `Deprecated()` | `OWL.deprecated` |

`rdfs:Resource` is the generated root protocol `RDFS.Resource`. RDFKit's own `rdfkit:Namespace` and `rdfkit:Prefix` are aliases of the RDFCore values `Namespace` and `Prefix`, which content is written with.

The declaration forms `Class`, `Property`, `Datatype` and `Individual` are RDFCore structs that the DSL calls. They are not aliases of the vocabulary's classes: `RDFS.Class` is the generated protocol for `rdfs:Class`, and `Class("Animal")` in a `content()` body is the declaration form, which the body macro writes as `RDFCore.Class("Animal")`.

The macro also recognises the meaning of a few vocabulary terms by their qualified spelling, because they change what it generates: `RDFS.Literal` and `XSD.nonNegativeInteger` map to the Swift value types `String` and `UInt`, `RDFS.Literal` makes its subclasses value types, `RDFS.Resource` is the root class, `OWL.Nothing` has no individual type, and `OWL.FunctionalProperty` makes a property single-valued.

## What Stays

- The DSL syntax: `Class("Animal") { Domain(Fauna.Animal) }` inside `func content()`.
- The result builder (`ContentBuilder`) and the content tree that `content()` returns.
- IRIs as boundary values only: each term's IRI is in its static `metadata`, computed from the namespace when the macro expands.

## Testing Approach

Don't test scaffolding types. `Tests/FaunaTests` declares an ontology with the DSL and uses its generated model end to end: individuals of several classes, cycles between individuals, many-valued and functional properties, and the boundary projection of IRIs. `Tests/RDFKitTests` uses the generated RDF, RDFS, OWL and XSD vocabularies the same way, one file per vocabulary, with a small fixture ontology (`Kinship`) whose classes refine `OWL.Thing`. `Tests/RDFKitMacrosTests` pins what the macro generates.
