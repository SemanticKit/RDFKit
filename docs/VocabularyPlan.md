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
- Every class but `OWL.Nothing`, the class with no individuals, gets an individual type (`RDF.ListIndividual`, `OWL.ThingIndividual`). That includes classes that refine another vocabulary's class: `OWL.ClassIndividual` has `subClassOf` from `RDFS.Class` and `disjointWith` from `OWL.Class`, because `@StoredRequirements` implements each class protocol's requirements where the protocol is declared. A named individual can be of several classes of other vocabularies, and each property it inherits along several paths is stored once. `RDFS.Resource` is the root class, so every individual has `label` and `comment`.
- A property one vocabulary declares for another vocabulary's class is a member of every individual of that class: `rdfs:domain` and `rdfs:range` on every `RDF.Property`, `owl:equivalentClass` on every `RDFS.Class`, `rdf:value` and `owl:versionInfo` on every resource. Each vocabulary generates an extension point (`OWL.Extending`) for them, which `RDFS.Resource` refines; see MacroDesign.md, "Properties for Other Ontologies' Classes".
- Named individuals are static constants: `RDF.nil` is the one empty list.
- `rdfs:Literal` and the datatypes (`RDF.HTML`, `RDF.langString`, `XSD.nonNegativeInteger`) are value types that store the literal: its lexical form, with the language tag and base direction RDF allows on strings. A property whose range is a datatype holds that datatype's type, so each term has one Swift type: `XSD.nonNegativeInteger("14")`, `RDF.langString("Löwe", languageTag: "de")`.
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

The declaration forms `Class`, `Property`, `Datatype` and `Individual` are RDFCore structs that the DSL calls. They are not aliases of the vocabulary's classes: `RDFS.Class` is the generated protocol for `rdfs:Class`, and `Class("Animal")` in a `content()` body is the declaration form, which the body macro writes as `RDFCore.Class("Animal")`. The declaration forms are content elements (`RDFCore.ContentElement`), not entities: they carry no IRI or metadata, so `rdfs:Class`, `rdf:Property`, `rdfs:Datatype` and `owl:NamedIndividual` have one Swift type each, the one generated from RDFS.swift, RDF.swift or OWL.swift, whose IRI is projected from that vocabulary's namespace.

The macro also recognises the meaning of a few vocabulary terms by their qualified spelling, because they change what it generates: `RDFS.Literal` makes its subclasses value types, `RDFS.Resource` is the root class and refines the extension points `RDF.Extending`, `RDFS.Extending` and `OWL.Extending`, `OWL.Nothing` has no individual type, and `OWL.FunctionalProperty` makes a property single-valued.

## What Stays

- The DSL syntax: `Class("Animal") { Domain(Fauna.Animal) }` inside `func content()`.
- The result builder (`ContentBuilder`) and the content tree that `content()` returns.
- IRIs as boundary values only: each term's IRI is in its static `metadata`, computed from the namespace when the macro expands.

## Testing Approach

Don't test scaffolding types. `Tests/FaunaTests` declares an ontology with the DSL and uses its generated model end to end: individuals of several classes, cycles between individuals, many-valued and functional properties, and the boundary projection of IRIs. `Tests/RDFKitTests` uses the generated RDF, RDFS, OWL and XSD vocabularies the same way, one file per vocabulary, with a small fixture ontology (`Kinship`) whose classes refine `OWL.Thing` and two OWL property characteristics, and which names an individual of two OWL classes. `Tests/RDFKitMacrosTests` pins what the macro generates.
