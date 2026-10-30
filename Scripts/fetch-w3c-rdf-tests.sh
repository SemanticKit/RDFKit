#!/bin/sh
# Fetches the W3C RDF 1.2 N-Triples, Turtle and RDF/XML test suites, and the RDF 1.1
# suites their manifests include, from the main branch of
# https://github.com/w3c/rdf-tests into Tests/RDFFormatsTests/W3C/rdf-tests,
# and the test vocabularies their manifests are written in (ns/test-manifest.ttl
# and ns/rdftest.ttl) into the targets that translate them,
# Tests/RDFFormatsTests/Vocabularies/TestManifest and .../RDFTest.
#
# Run it from anywhere to refresh the suites; commit the result. Only the
# manifests, test documents and licence files are kept.
set -eu

package=$(cd "$(dirname "$0")/.." && pwd)
destination="$package/Tests/RDFFormatsTests/W3C/rdf-tests"
vocabularies="$package/Tests/RDFFormatsTests/Vocabularies"
suites="rdf/rdf12/rdf-n-triples rdf/rdf12/rdf-turtle rdf/rdf12/rdf-xml rdf/rdf11/rdf-n-triples rdf/rdf11/rdf-turtle rdf/rdf11/rdf-xml"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

git clone --quiet --depth 1 --filter=blob:none --sparse https://github.com/w3c/rdf-tests "$work/rdf-tests"
# shellcheck disable=SC2086
git -C "$work/rdf-tests" sparse-checkout set $suites ns

rm -rf "$destination"
for suite in $suites; do
    (cd "$work/rdf-tests" && find "$suite" -type f \
        \( -name '*.ttl' -o -name '*.nt' -o -name '*.rdf' -o -name 'LICENSE' \) \
        -not -path '*/reports/*') |
    while read -r file; do
        mkdir -p "$destination/$(dirname "$file")"
        cp "$work/rdf-tests/$file" "$destination/$file"
    done
done

cp "$work/rdf-tests/ns/test-manifest.ttl" "$vocabularies/TestManifest/test-manifest.ttl"
cp "$work/rdf-tests/ns/rdftest.ttl" "$vocabularies/RDFTest/rdftest.ttl"

echo "Fetched $(find "$destination" -type f | wc -l | tr -d ' ') files into $destination"
