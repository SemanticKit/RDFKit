# ParallelTests fixtures

The RDF documents the parallel tests translate to Swift and back. Each one is
stored byte for byte as its source gives it, unedited. The `.swift` file in
each directory is the Swift source file SwiftPM needs for the target the
documents build into; it is not a fixture.

| File | Source | Retrieved | sha256 |
|---|---|---|---|
| `W3C/rdf.ttl` | [`ns/rdf.ttl`](https://github.com/w3c/rdf-schema/blob/476ad2dc997a9f6085204bbdead2b14cee511d70/ns/rdf.ttl) in github.com/w3c/rdf-schema at commit 476ad2d (2026-10-23) | from git at that commit | `de3586302831db835bde8075dcf88a0305329318eebba71e04e77d3a6ec77e46` |
| `W3C/rdfs.ttl` | [`ns/rdfs.ttl`](https://github.com/w3c/rdf-schema/blob/476ad2dc997a9f6085204bbdead2b14cee511d70/ns/rdfs.ttl) in github.com/w3c/rdf-schema at commit 476ad2d (2026-10-23) | from git at that commit | `d3da35bc9190f688f2b8dff7d16489aea574d5caad79ac6981743fc74ba4bc2d` |
| `FOAF/index.rdf` | <http://xmlns.com/foaf/spec/index.rdf>, served from `https://xmlns.com/foaf/spec/index.rdf` as `application/rdf+xml` (Last-Modified Fri, 23 Jan 2026 23:02:50 GMT). The namespace IRI <http://xmlns.com/foaf/0.1/> serves the same bytes for `Accept: application/rdf+xml`. | 2026-10-29 23:09 UTC, with curl | `3d859b5d92a2c3d041545d014fa826f682ca06d056af8c7b31e32d930abf2bc5` |
| `AliceProfile/alice.ttl` | Written for these tests in commit e9d46c1: two `foaf:Person`s who know each other. | not retrieved | `ff4e1ded544490ab185d54d57720b4f83e63a0bcc7e7dc16801519a1a7f6a436` |

Check them with:

    cd Tests/ParallelTests/Fixtures
    sha256sum W3C/rdf.ttl W3C/rdfs.ttl FOAF/index.rdf AliceProfile/alice.ttl
