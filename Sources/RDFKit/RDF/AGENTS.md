# RDF Directory Instructions

## Scope
This directory contains RDF standard-defined shapes and RDF model types only.

Use the latest RDF 1.2 document set as the standards authority. Do not treat legacy namespace dates as the version of the standard. Namespace IRIs identify vocabularies; the source documents below define the current standard.

RDF is self-describing. RDFTranslatorPlugin translates `rdf.ttl`, the published RDF 1.2 vocabulary stored unedited, into the RDF terms of RDFKit: each class becomes a protocol and each property a requirement on its domain's protocol. No RDF term is written by hand.

## Latest RDF Standard Documents
The current RDF standard family is RDF 1.2. Use the latest W3C `/TR/` URLs:

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
6. RDF 1.2 Schema  
   https://www.w3.org/TR/rdf12-schema/
7. RDF 1.2 Semantics  
   https://www.w3.org/TR/rdf12-semantics/
8. RDF 1.2 TriG  
   https://www.w3.org/TR/rdf12-trig/
9. RDF 1.2 Turtle  
   https://www.w3.org/TR/rdf12-turtle/
10. RDF 1.2 XML Syntax  
    https://www.w3.org/TR/rdf12-xml/

## Rules
- Use RDF 1.2 documents as source authority.
- Keep stable vocabulary namespace IRIs separate from standards-source document IRIs.
- Translate `rdf.ttl`; never hand-write or edit the generated terms (rule 0).
- User-facing Swift works at the RDF concept level, not the triple-authoring level.
- Triples are what a vocabulary or individual encodes to, not declarations.
