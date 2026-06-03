# RDFS Directory Instructions

## Scope
This directory contains RDF Schema standard-defined vocabulary shapes only.

RDFS is defined by RDF 1.2 Schema. RDF 1.2 Schema is part of the RDF 1.2 document set. Do not use old RDFS/RDF namespace-date strings as evidence of the current standards version. Namespace IRIs identify terms; the source documents below define the current standard.

RDFS is self-describing. Its schema and vocabulary content must drive the DSL pieces used to represent RDFS in RDFKit.

## Latest RDFS Standard Document
Primary source:

1. RDF 1.2 Schema  
   https://www.w3.org/TR/rdf12-schema/

## Supporting RDF 1.2 Documents
RDFS work may require these RDF 1.2 documents for concepts, semantics, and serializations:

1. What’s New in RDF 1.2  
   https://www.w3.org/TR/rdf12-new/
2. RDF 1.2 Concepts and Abstract Data Model  
   https://www.w3.org/TR/rdf12-concepts/
3. RDF 1.2 N-Quads  
   https://www.w3.org/TR/rdf12-n-quads/
4. RDF 1.2 N-Triples  
   https://www.w3.org/TR/rdf12-n-triples/
5. RDF 1.2 Primer  
   https://www.w3.org/TR/rdf12-primer/
6. RDF 1.2 Semantics  
   https://www.w3.org/TR/rdf12-semantics/
7. RDF 1.2 TriG  
   https://www.w3.org/TR/rdf12-trig/
8. RDF 1.2 Turtle  
   https://www.w3.org/TR/rdf12-turtle/
9. RDF 1.2 XML Syntax  
   https://www.w3.org/TR/rdf12-xml/

## Rules
- Use RDF 1.2 Schema as the authoritative RDFS source.
- Keep stable vocabulary namespace IRIs separate from standards-source document IRIs.
- Treat RDFS as a self-describing DSL vocabulary.
- User-facing DSL work must operate at RDFS concept level, not triple-authoring level.
- RDFS properties and classes should be modeled through protocols and conformances.
