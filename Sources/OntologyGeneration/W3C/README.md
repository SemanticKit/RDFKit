# The W3C documents the generators' semantics are translated from

The meaning the generators give the terms they translate (D5, D7) is the
meaning these specifications state, read from their own tables. Each is
stored byte for byte as the W3C serves it, unedited.

| File | What the generators read | Source | Retrieved | sha256 |
|---|---|---|---|---|
| `rdf12-semantics.html` | RDF 1.2 Semantics, W3C Recommendation: the table `rdfs_entailment_patterns` of the RDFS entailment patterns rdfs1 to rdfs14a (§ "RDFS Entailment Patterns") | <https://www.w3.org/TR/rdf12-semantics/> (Last-Modified Tue, 29 Sep 2026 22:02:42 GMT) | 2026-10-31, with curl | `e730917b222128aeebf81a3f0da55575aebcca37ddd5fbcc4a4163183854b680` |
| `rdf12-schema.html` | RDF 1.2 Schema: the definitions of the RDFS vocabulary the patterns use | <https://www.w3.org/TR/rdf12-schema/> (Last-Modified Fri, 23 Oct 2026 19:24:41 GMT) | 2026-10-31, with curl | `1e6a0dce1fe749116e6b23fd3b41d889c3f9d5a7bf8d3c5485d91af421eb43b7` |
| `owl2-rdf-based-semantics.html` | OWL 2 Web Ontology Language RDF-Based Semantics (Second Edition), W3C Recommendation: the parts of the universe (§4.1, `IR`, `IC`, `IP` …) and the conditions on the class extensions of the built-in classes (§5.2), such as `owl:Thing ∈ IC, = IR` and `owl:Nothing ∈ IC, = ∅` (D7) | <https://www.w3.org/TR/owl2-rdf-based-semantics/> (Last-Modified Mon, 02 Oct 2017 10:45:22 GMT) | 2026-10-31, with curl | `dc79e10c5951f1ec809278a5798efa2d50bd759c47da613179e49432bd65be34` |
| `owl2-profiles.html` | OWL 2 Web Ontology Language Profiles (Second Edition), W3C Recommendation: the OWL 2 RL rules of §4.3, Tables 4 to 9, such as prp-fp for a functional property's "at most one" value (D5) | <https://www.w3.org/TR/owl2-profiles/> (Last-Modified Mon, 02 Oct 2017 10:45:20 GMT) | 2026-10-31, with curl | `1599d792a39fe30000913822deffd78cb0905542c3ee3d956efc9e51a7273c05` |

Check them with:

    cd Sources/OntologyGeneration/W3C
    shasum -a 256 rdf12-semantics.html rdf12-schema.html owl2-rdf-based-semantics.html owl2-profiles.html
