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
- Every class but `OWL.Nothing`, the class with no individuals, gets an individual type (`RDF.ListIndividual`, `OWL.ThingIndividual`). That includes classes that refine another vocabulary's class: `OWL.ClassIndividual` has `subClassOf` from `RDFS.Class` and `disjointWith` from `OWL.Class`, because `@StoredRequirements` implements each class protocol's requirements where the protocol is declared.
- Named individuals are static constants: `RDF.nil` is the one empty list.
- `rdfs:Literal` and the datatypes (`RDF.HTML`, `RDF.langString`, `XSD.nonNegativeInteger`) are value types that store the literal: its lexical form, with the language tag and base direction RDF allows on strings. A property whose range is a datatype holds that datatype's type, so each term has one Swift type: `XSD.nonNegativeInteger("14")`, `RDF.langString("Löwe", languageTag: "de")`.
- Properties are term types (`RDFS.subClassOf`, `OWL.sameAs`) that name their domain and range.
- A property whose domain is another vocabulary's class or `rdfs:Resource` is read through its term type: `OWL.equivalentClass.values(of: feline)` on any individual of `RDFS.Class` (an `OWL.ClassIndividual` or an `RDFS.ClassIndividual`), `RDFS.subPropertyOf.values(of: property)` on any individual of `RDF.Property`, and `RDFS.label.values(of: lion)`, `RDFS.comment`, `RDFS.seeAlso` and `OWL.versionInfo` on every individual. The RDFCore-provided terms among them get their accessor in `Sources/RDFKit/RDFCoreTerms+PropertyValues.swift`, which each vocabulary's expansion checks against its declaration. `rdf:type` is the conformances of an individual's type, not a stored value.

## Bootstrap Terms

Some terms are the DSL itself. RDFCore provides them, and when a vocabulary declares one the macro aliases the RDFCore type instead of generating a second type for the same term:

| Term | RDFCore type |
|---|---|
| `rdfs:Resource` | `Resource`, the protocol every class refines |
| `rdf:type`, `rdfs:domain`, `rdfs:range`, `rdfs:subClassOf`, `rdfs:subPropertyOf` | `Type`, `Domain`, `Range`, `SubClassOf`, `SubPropertyOf`, generic over the related term |
| `rdfs:label`, `rdfs:comment`, `rdfs:seeAlso`, `owl:deprecated` | `Label`, `Comment`, `SeeAlso`, `Deprecated` |
| `rdfkit:Namespace`, `rdfkit:Prefix` | `Namespace`, `Prefix` |

The declaration forms `Class`, `Property`, `Datatype` and `Individual` are RDFCore structs that the DSL calls. They are not aliases of the vocabulary's classes: `RDFS.Class` is the generated protocol for `rdfs:Class`, and `Class("Animal")` in a `content()` body is the declaration form, which the body macro writes as `RDFCore.Class("Animal")`.

The macro also recognises the meaning of a few vocabulary terms by their qualified spelling, because they change what it generates, with or without the module (`RDFKit.OWL.FunctionalProperty`): `RDFS.Literal` makes its subclasses value types, `RDFS.Resource` is the root class, `OWL.Nothing` has no individual type, and `OWL.FunctionalProperty` makes a property single-valued.

## What Stays

- The DSL syntax: `Class("Animal") { Domain(Fauna.Animal) }` inside `func content()`.
- The result builder (`ContentBuilder`) and the content tree that `content()` returns.
- IRIs as boundary values only: each term's IRI is in its static `metadata`, computed from the namespace when the macro expands.

## Testing Approach

Don't test scaffolding types. `Tests/FaunaTests` declares an ontology with the DSL and uses its generated model end to end: individuals of several classes, cycles between individuals, many-valued and functional properties, and the boundary projection of IRIs. `Tests/RDFKitMacrosTests` pins what the macro generates.
