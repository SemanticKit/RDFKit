# RDFKit DSL Invariants

## Core Principles

1. **RDF is self-describing.** RDF, RDFS, and OWL are declared ontology values. Their content drives the DSL.

2. **Protocol-oriented, not class-per-term.** Protocols define roles; extensions provide behavior; the compiler enforces structure. An OWL/RDFS class is a protocol whose requirements are the properties with the class as domain, and `SubClassOf` is refinement. Individuals are references, final classes that conform to their classes' protocols, so one individual can belong to several classes and graphs of individuals can have cycles. Datatypes and literals are value types. No hand-written file or type per term: the macro generates them from the ontology's content.

3. **DSL terms match RDF/RDFS/OWL vocabulary names 1:1.** `Class` = `rdfs:Class`, `Label` = `rdfs:label`. No abstraction layers.

4. **Ontology declarations are the source of truth.** Generated types are not the source of truth. The content tree IS the ontology.

5. **Child declarations do not know parent context.** Consumers walking the content tree determine namespace, aliases, parent ontology, subject, and output form.

6. **Inside the runtime, the type system is term identity.** A term is its Swift type, and types refer to each other as types: a property whose range is `Fauna.Habitat` is typed `Fauna.Habitat`, never `IRI` or `String`. An individual's identity is the object. An IRI is a static projection of a type, computed from the namespace when the macro expands and kept in the type's `metadata`. It is read only at the boundary: I/O (Turtle, N-Triples, HTTP, pods), translation into non-Swift expression languages (SHACL, SPARQL, HTTP signature bases, ACL documents), and identity that external systems dereference (WebID). Decoders turn IRIs into types on the way in. Registries or dictionaries keyed by IRI, string term names, and identity built by string interpolation are design errors.

7. **The type system does the work.** Not runtime walking, not resolver structs, not string concatenation. If something needs to be known, the type should already know it.

## What Belongs in RDFCore

Only the declaration machinery needed to author ontologies:
- Protocols and conformances
- Result builders (parameter packs, no manual arity)
- Literal expressibility
- Value types (Namespace, Prefix, the declaration forms)
- The runtime of generated individuals (Resource, IndividualGraph, PropertyValues, PropertyValue)
- Content modifiers (type-safe, target-specific)

## What Does NOT Belong

- Java-style class-per-term APIs
- Static enum-style term containers (these are scaffolding, coming down)
- Registries, symbolic metatype references, `.self` references
- Resolver structs (the type system already provides identity via `Identifiable`)
- Runtime string manipulation for IRI resolution

## The Self-Describing Loop

The end state is the loop:
1. DSL defines ontologies (RDF, RDFS, OWL)
2. The ontology metadata (names, types, relationships) is the source
3. The compiler reads this metadata and generates type-safe Swift types
4. Those generated types ARE the DSL — not wrappers, not scaffolding

This eliminates hand-written term enums (`OWL+Terms.swift`, `RDF+Terms.swift`, `RDFS+Terms.swift`) and the generic `TermDeclaration` scaffolding.

## Testing

Tests are wrong if they:
- Test individual properties of generic scaffolding types
- Use the old generated/metatype/static-container design
- Construct `TermDeclaration` by hand instead of using the DSL

Tests are right if they:
- Build a new ontology using the DSL
- Verify the ontology works end-to-end at a high level
- Prove the DSL is self-describing
