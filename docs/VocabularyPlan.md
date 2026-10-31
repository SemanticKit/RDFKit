# The Self-Describing Loop

## Current State

RDF, RDFS and OWL describe themselves: `rdfs:Class rdf:type rdfs:Class`. RDFKit translates their published documents, `rdf.ttl`, `rdfs.ttl` and `owl.ttl`, into Swift the same way it translates any other vocabulary, under the OWL 2 RDF-Based Semantics (D7). There are no hand-written term references, term enums or `+Terms.swift` files.

## The Loop

1. The vocabulary's documents state its terms, their types, superclasses, domains, ranges and annotations.
2. `Schema` closes those statements under the published semantics, read from the W3C documents themselves.
3. `RDFTranslator` generates a protocol for each class and a requirement for each property, with DocC from the annotations.
4. The generated protocols are the vocabulary, in Swift. A vocabulary that builds on another (`--layer`) uses the other's protocols.

## What the Translator Generates

```swift
/// The class of classes.
///
/// Label: Class
public protocol Class: RDFS.Resource, AnyObject {
}
```

IRIs are not stored. A term's IRI is derived from its declaration when it is asked for (rule 17): its namespace plus its local name.

## What Stays

- The published documents, stored unedited, with their provenance.
- The DSL (`@Ontology`), for vocabularies declared in Swift. It generates the same protocols as the translator.
- `RDFCore`'s data model at the boundary (rule 20).

## Testing Approach

Translate published vocabularies end to end and use the result as a consumer would. FOAF and an Alice profile are translated from their documents in `Tests/ParallelTests/Fixtures`, and `ParallelTests` checks the Swift they give. Don't test scaffolding types.
