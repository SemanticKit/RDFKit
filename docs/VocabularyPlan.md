# The Self-Describing Loop

## Current State

RDF describes itself in layers, and RDF, RDFS and OWL go through the same translation as any vocabulary. `RDFTranslatorPlugin` translates rdf.ttl and rdfs.ttl into the module `RDF`, and owl.ttl into `OWL` on top of it. There is no second, hand-authored copy of them in the DSL: `RDF.Class`, `RDF.Property`, `RDF.List`, `OWL.Thing` and `OWL.ObjectProperty` are types the translator writes from the W3C documents, and encoding `RDF.ontology` or `OWL.ontology` gives back a graph isomorphic to those documents.

## What the Standard Vocabularies Become

The vocabularies follow the same rules as any translated vocabulary (see `Sources/RDFTranslator/Declarations.swift`):

- Every class is a protocol, for membership, a storing protocol and a final class whose instances are its members: `RDF.List`, `RDF.ListStoring`, `RDF.ListIndividual`. `rdfs:subClassOf` is refinement (`OWL.ObjectProperty` refines `RDF.Property`).
- Every property is an individual of `rdf:Property` (`RDF.type`, `OWL.sameAs`), a value type that holds its values on an individual, and a storing protocol that gives the individual its accessor, typed by the property's range.
- Named individuals are module-level values: `RDF.nil` is the one empty list. Each is the one instance of a Swift class of its own that carries its declared key, from which the encoders derive its IRI.
- Literal classes and datatypes (`RDF.Literal`, `RDF.langString`) have `RDFCore.Literal` members.

## The DSL Builds on Them

An ontology written with the DSL names the translated vocabularies by type, `Type(RDF.Class)`, `Range(RDF.Literal)`, `SubClassOf(FOAF.Person)`, and `@Ontology` generates the same Swift the translator writes (see `MacroDesign.md`). The RDFKit vocabulary itself is declared this way, in `Sources/RDFKit/RDFKit.swift`.

The declaration forms `Class`, `Property` and `Datatype`, and the annotations `Label`, `Comment`, `SeeAlso` and `Deprecated`, are RDFCore structs that the DSL calls. They are not aliases of the vocabulary's classes: `RDF.Class` is the translated protocol for `rdfs:Class`, and `Class("Animal")` in a `var body` is the declaration form, which the body macro writes as `RDFCore.Class("Animal")`.

## What Stays

- The DSL syntax: `Class("Animal") { Domain(Fauna.Animal) }` inside `var body: some Content`.
- The result builder (`ContentBuilder`) and the content tree that `body` returns.
- IRIs as boundary values only: each term's IRI is computed from the namespace, by the macro when it expands or by the translator from the document, and read only by the encoders.

## Testing Approach

Don't test scaffolding types. `Tests/RDFTranslatorTests` checks the translated layers and a small library vocabulary end to end, including the way back to the documents' graphs. `Tests/ParallelTests` (frozen) checks the parallel on FOAF and Alice's profile. `Tests/RDFKitTests` uses DSL-generated models with translated ones.
