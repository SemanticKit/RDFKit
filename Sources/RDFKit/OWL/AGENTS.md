# OWL Directory Instructions

## Scope
This directory contains OWL standard-defined vocabulary and ontology-language shapes only.

Use OWL 2 Web Ontology Language, Second Edition, as the latest W3C Recommendation family for OWL. Namespace IRIs identify OWL terms; the source documents below define the standard.

OWL is self-describing. RDFTranslatorPlugin translates `owl.ttl`, the published OWL 2 vocabulary stored unedited, into the OWL terms of RDFKit, under the OWL 2 RDF-Based Semantics (D7). No OWL term is written by hand.

## Latest OWL Standard Documents
The latest OWL standard family is OWL 2 Web Ontology Language, Second Edition. Use the latest W3C `/TR/` URLs:

1. OWL 2 Web Ontology Language: Document Overview  
   https://www.w3.org/TR/owl-overview/
2. OWL 2 Web Ontology Language: Structural Specification and Functional-Style Syntax  
   https://www.w3.org/TR/owl2-syntax/
3. OWL 2 Web Ontology Language: Mapping to RDF Graphs  
   https://www.w3.org/TR/owl2-mapping-to-rdf/
4. OWL 2 Web Ontology Language: Direct Semantics  
   https://www.w3.org/TR/owl2-direct-semantics/
5. OWL 2 Web Ontology Language: RDF-Based Semantics  
   https://www.w3.org/TR/owl2-rdf-based-semantics/
6. OWL 2 Web Ontology Language: Conformance  
   https://www.w3.org/TR/owl2-conformance/
7. OWL 2 Web Ontology Language: Profiles  
   https://www.w3.org/TR/owl2-profiles/
8. OWL 2 Web Ontology Language: Primer  
   https://www.w3.org/TR/owl2-primer/
9. OWL 2 Web Ontology Language: New Features and Rationale  
   https://www.w3.org/TR/owl2-new-features/
10. OWL 2 Web Ontology Language: Quick Reference Guide  
    https://www.w3.org/TR/owl2-quick-reference/
11. OWL 2 Web Ontology Language: XML Serialization  
    https://www.w3.org/TR/owl2-xml-serialization/
12. OWL 2 Web Ontology Language: Manchester Syntax  
    https://www.w3.org/TR/owl2-manchester-syntax/
13. OWL 2 Web Ontology Language: Data Range Extension: Linear Equations  
    https://www.w3.org/TR/owl2-dr-linear/

## Rules
- Use OWL 2 Second Edition documents as source authority.
- Keep stable vocabulary namespace IRIs separate from standards-source document IRIs.
- Translate `owl.ttl`; never hand-write or edit the generated terms (rule 0).
- OWL is an RDF-based ontology language: its terms are translated like RDF's and RDFS's. `owl:Thing` is the root, `RDFS.Resource`, and `owl:Nothing` is `Never` (D7).
- User-facing Swift works at the OWL concept level, not the triple-authoring level.
