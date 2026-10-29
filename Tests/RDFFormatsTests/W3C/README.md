# W3C RDF test suites

`rdf-tests/` holds the RDF 1.2 N-Triples, Turtle and RDF/XML test suites from
[w3c/rdf-tests](https://github.com/w3c/rdf-tests), with the RDF 1.1 suites
their manifests include, laid out as in that repository. `RDFFormatsTests`
reads them through their manifests, starting from
`rdf/rdf12/rdf-n-triples/manifest.ttl`, `rdf/rdf12/rdf-turtle/manifest.ttl` and
`rdf/rdf12/rdf-xml/manifest.ttl`.

To refresh them from the repository's main branch, run:

```sh
Scripts/fetch-w3c-rdf-tests.sh
```

The suites are distributed under the W3C Test Suite Licence and the W3C
3-clause BSD Licence.
