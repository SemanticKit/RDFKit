# SHACLTranslationTests fixtures

The RDF documents these tests translate to Swift. Each one is stored byte for
byte as its source gives it, unedited. The `.swift` file in each directory is
the Swift source file SwiftPM needs for the target the documents build into;
it is not a fixture.

| File | Source | sha256 |
|---|---|---|
| `SHACL/shacl.ttl` | [`shacl12-vocabularies/shacl.ttl`](https://github.com/w3c/data-shapes/blob/a6ed26f7385d6e03eeb8441d72d3c172d27657c7/shacl12-vocabularies/shacl.ttl) in github.com/w3c/data-shapes at commit a6ed26f (2026-10-25), copied from SemanticKit/SHACLKit `Sources/SHACL/shacl.ttl` | `f210919274934710e9bef6b59b2409df4fe7cdaff25b5708e428e3e186763857` |

Check it with:

    cd Tests/SHACLTranslationTests/Fixtures
    shasum -a 256 SHACL/shacl.ttl
