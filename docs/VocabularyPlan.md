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
- Properties are term types (`RDFS.subClassOf`, `OWL.sameAs`) that name their domain and range. A property whose domain is `rdfs:Resource`, such as `rdfs:member`, is read and written through its term: `RDFS.member[bag]`.
- Every class and datatype is also a value, an individual of its `rdf:type`: `RDFS.classClass`, `OWL.thingClass`, `XSD.nonNegativeIntegerClass`.

## Bootstrap Terms

Some terms are the DSL itself. RDFCore provides them, and when a vocabulary declares one the macro aliases the RDFCore type instead of generating a second type for the same term:

| Term | RDFCore type |
|---|---|
| `rdfs:Resource` | `Resource`, the protocol every class refines |
| `rdf:type`, `rdfs:domain`, `rdfs:range`, `rdfs:subClassOf`, `rdfs:subPropertyOf` | `Type`, `Domain`, `Range`, `SubClassOf`, `SubPropertyOf`, generic over the related term |
| `rdfs:label`, `rdfs:comment`, `rdfs:seeAlso`, `owl:deprecated` | `Label`, `Comment`, `SeeAlso`, `Deprecated` |
| `rdfkit:Namespace`, `rdfkit:Prefix` | `Namespace`, `Prefix` |

The declaration forms `Class`, `Property`, `Datatype` and `Individual` are RDFCore structs that the DSL calls. They are not aliases of the vocabulary's classes: `RDFS.Class` is the generated protocol for `rdfs:Class`, and `Class("Animal")` in a `content()` body is the declaration form, which the body macro writes as `RDFCore.Class("Animal")`.

The macro also recognises the meaning of a few vocabulary terms by their qualified spelling, because they change what it generates: `RDFS.Literal` makes its subclasses value types, `RDFS.Resource` is the root class, `OWL.Thing` named by another vocabulary is any resource, `OWL.Nothing` has no individual type, `OWL.FunctionalProperty` makes a property single-valued, and the XSD, RDFS and RDF datatypes make a property with several ranges hold any literal.

## The Solid Vocabularies

FOAF, cert, WAC (`acl`), ACP, LDP and the Solid terms are declared with the DSL in `Sources/Vocabularies`, one target each (`FOAF`, `Cert`, `ACL`, `ACP`, `LDP`, `Solid`), as their published vocabularies declare them: classes, properties, individuals, types (`owl:FunctionalProperty` and `owl:InverseFunctionalProperty` included), superclasses, superproperties, domains, ranges, labels and comments. Each file's documentation names its source and the places where the published vocabulary names a term it does not declare (`cert:DSAKey`, `cert:RSAPrivateKey`).

The terms of other vocabularies they name (`geo:SpatialThing`, `contact:Person`, `skos:Concept`, `gen:InformationResource`, `vcard:Group`, `log:Formula`, `sioc:Post` and the OpenID Connect `issuer`) are declared, alone, in the `ReferencedVocabularies` target, so that the Solid vocabularies refer to them as types. LDP also names `rdf:Resource` and `owl:Individual`, which RDF 1.2 and OWL 2 do not define. `RDF` and `OWL` keep to what the standards define, so these two are declared there too, as `LegacyRDF.Resource` and `LegacyOWL.Individual`, plain `rdfs:Class`es in their own namespaces; each IRI still has one Swift type.

A WebID profile is built from their types: `Foaf.PersonIndividual(in: graph)` is a person, `alice.knows` links people, `Cert.key[alice]` holds her keys, and `acl:agentClass` holds `Foaf.agentClass`.

## What Stays

- The DSL syntax: `Class("Animal") { Domain(Fauna.Animal) }` inside `func content()`.
- The result builder (`ContentBuilder`) and the content tree that `content()` returns.
- IRIs as boundary values only: each term's IRI is in its static `metadata`, computed from the namespace when the macro expands.

## Testing Approach

Don't test scaffolding types. `Tests/FaunaTests` declares an ontology with the DSL and uses its generated model end to end: individuals of several classes, cycles between individuals, many-valued and functional properties, and the boundary projection of IRIs. `Tests/VocabularyTests` does the same for the Solid vocabularies and builds a WebID profile across them. `Tests/RDFKitMacrosTests` pins what the macro generates.
