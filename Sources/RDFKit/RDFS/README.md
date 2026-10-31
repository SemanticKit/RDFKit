# rdfs.ttl

The RDF 1.2 Schema vocabulary, stored byte for byte as its source gives it,
unedited. RDFTranslator translates it to the RDFS terms of RDFKit.

| File | Source | Retrieved | sha256 |
|---|---|---|---|
| `rdfs.ttl` | [`ns/rdfs.ttl`](https://github.com/w3c/rdf-schema/blob/476ad2dc997a9f6085204bbdead2b14cee511d70/ns/rdfs.ttl) in github.com/w3c/rdf-schema, the RDF & SPARQL Working Group's repository for RDF 1.2 Schema, at commit 476ad2d (2026-10-23) | from git at that commit, as `Tests/ParallelTests/Fixtures/W3C/rdfs.ttl` on main records it | `d3da35bc9190f688f2b8dff7d16489aea574d5caad79ac6981743fc74ba4bc2d` |

The namespace document <http://www.w3.org/2000/01/rdf-schema> serves an
earlier vocabulary (`rdf-schema.ttl`, Last-Modified Wed, 18 Dec 2024 14:38:20
GMT, sha256 `ecee3a011b7c13ea2a7e40b0a208bfe6be53d69fdd53ee035e09e9f9e5108ad6`
on 2026-10-31), so the RDF 1.2 file is taken from the Working Group's repository.

Check it with:

    shasum -a 256 Sources/RDFKit/RDFS/rdfs.ttl
