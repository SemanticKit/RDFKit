# RDFKit DSL Invariants

- RDFKit models RDF/RDFS/OWL only. Swift features are syntax, not ontology concepts.
- Ontology declarations are the source of truth. Generated types are not the source of truth.
- Do not reintroduce Java-style class-per-term APIs, static enum-style term containers, registries, symbolic metatype references, or `.self` references.
- RDF, RDFS, and OWL are declared ontology values. `@Ontology` generates a Swift type for each term: a protocol for each class (requirements are the properties with it as domain; `SubClassOf` is refinement), final-class individuals that conform to their classes, value types for datatypes and literals, and a term type for each property.
- Inside the runtime the type system is term identity: terms refer to each other as types, never through an IRI or a String, and an individual's identity is the object. An IRI is a static projection kept in a type's `metadata`, read only at the boundary (I/O, translation into SHACL or SPARQL, dereferenced identity such as WebID). No registries or dictionaries keyed by IRI or term name, and no identity built by string interpolation.
- See `docs/DslInvariants.md` and `docs/MacroDesign.md`.
- Child declarations do not know parent context. Consumers walking the content tree determine namespace, aliases, parent ontology, subject, and output form.
- `IsDefinedBy()` with no argument is redundant inside a containing ontology and must not be authored as boilerplate. Only explicit differing `IsDefinedBy(value)` belongs in content.
- Core contains only the declaration machinery needed to author ontologies: protocols, conformances, result builders, literal expressibility, and value declarations.
- Prefer protocol/conformance/default-extension behavior over repeated boilerplate in every declaration type.
- Tests are wrong if they preserve the old generated/metatype/static-container design.
