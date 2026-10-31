# rdf.ttl

The RDF 1.2 vocabulary, stored byte for byte as its source gives it,
unedited. RDFTranslator translates it to the RDF terms of RDFKit.

| File | Source | Retrieved | sha256 |
|---|---|---|---|
| `rdf.ttl` | [`ns/rdf.ttl`](https://github.com/w3c/rdf-schema/blob/476ad2dc997a9f6085204bbdead2b14cee511d70/ns/rdf.ttl) in github.com/w3c/rdf-schema, the RDF & SPARQL Working Group's repository for RDF 1.2 Schema, at commit 476ad2d (2026-10-23) | from git at that commit, as `Tests/ParallelTests/Fixtures/W3C/rdf.ttl` on main records it | `de3586302831db835bde8075dcf88a0305329318eebba71e04e77d3a6ec77e46` |

The namespace document <http://www.w3.org/1999/02/22-rdf-syntax-ns> still
serves the RDF 1.1 vocabulary (`22-rdf-syntax-ns.ttl`, Last-Modified Mon, 16 Dec
2019 15:09:32 GMT, sha256 `93d52b1a5824c7dd6504ca79c16205c0b740a0ba68b7a14952780f52561186a2`
on 2026-10-31), so the RDF 1.2 file is taken from the Working Group's repository.

Check it with:

    shasum -a 256 Sources/RDFKit/RDF/rdf.ttl
