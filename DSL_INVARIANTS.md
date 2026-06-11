# RDFKit DSL Invariants

- RDFKit models RDF/RDFS/OWL only. Swift features are syntax, not ontology concepts.
- Ontology declarations are the source of truth. Generated term structs are not the source of truth.
- Do not reintroduce Java-style class-per-term APIs, static enum-style term containers, registries, symbolic metatype references, or `.self` references.
- RDF, RDFS, and OWL are declared ontology values. Term lookup is dynamic member lookup on those ontology values, yielding IRI-backed term references.
- Term identity is RDF IRI identity. Swift type identity is never term identity.
- Child declarations do not know parent context. Consumers walking the content tree determine namespace, aliases, parent ontology, subject, and output form.
- `IsDefinedBy()` with no argument is redundant inside a containing ontology and must not be authored as boilerplate. Only explicit differing `IsDefinedBy(value)` belongs in content.
- Core contains only the declaration machinery needed to author ontologies: protocols, conformances, result builders, literal expressibility, and value declarations.
- Prefer protocol/conformance/default-extension behavior over repeated boilerplate in every declaration type.
- Tests are wrong if they preserve the old generated/metatype/static-container design.
