# The W3C documents the XSD datatypes are translated from

`XSDTranslatorPlugin` translates these documents into the Swift value types of
the `XSD` module on every build. Each is stored byte for byte as the W3C serves
it, unedited.

| File | What it is | Source | Retrieved | sha256 |
|---|---|---|---|---|
| `datatypes.xsd` | XML Schema 1.1 Part 2, Appendix A, "Schema for Schema Documents (Datatypes) (normative)": the schema of a simple type definition's XML representation, which declares the constraining facets. The translator reads its facet elements (the substitution group of `xs:facet`) and the kind of value each takes. | <https://www.w3.org/2009/XMLSchema/datatypes.xsd>, the undated copy the Recommendation names (`version="datatypes.xsd (rec-20120405)"`, Last-Modified Wed, 04 Apr 2012 04:57:41 GMT) | 2026-10-30, with curl | `21c9f4d7618d5ba46002df7dc602d4dec86e7009fc2594168e84916564912ed1` |
| `primitives.nxsd` | XML Schema 1.1 Part 2, Appendix C.1, "Illustrative XML representations for the built-in primitive type definitions": `string` to `NOTATION`, each a restriction of `anyAtomicType` with its `whiteSpace` and `explicitTimezone` facets. | <https://www.w3.org/2009/XMLSchema/primitives.nxsd> (Last-Modified Wed, 20 Jul 2011 21:02:05 GMT); its schema element and content are those of Appendix C.1 of <https://www.w3.org/TR/xmlschema11-2/> | 2026-10-30, with curl | `a320b83164f5b4e3547b26fe1a4db42a64243de69102353ad5b68998bac405e6` |
| `derived.nxsd` | XML Schema 1.1 Part 2, Appendix C.2, "Illustrative XML representations for the built-in ordinary type definitions": `normalizedString` to `dateTimeStamp`, each a restriction of its base type with the facets that define it. | <https://www.w3.org/2009/XMLSchema/derived.nxsd> (Last-Modified Mon, 29 Nov 2010 23:47:19 GMT); its schema element and content are those of Appendix C.2 of <https://www.w3.org/TR/xmlschema11-2/> | 2026-10-30, with curl | `bdebe2c480710a2765c34bc7f92c68f76a3bf1602cab40847b11dd300e057358` |
| `rdf12-concepts.html` | RDF 1.2 Concepts and Abstract Data Model, W3C Candidate Recommendation Snapshot, 7 April 2026. The translator reads the table `tab-xsd-datatypes` of §5.1, "the RDF-compatible XSD types", for the datatypes it translates, and the table `tab-vocab-ns` of §1.4 for the namespace of the prefix `xsd`. | <https://www.w3.org/TR/rdf12-concepts/> (Last-Modified Fri, 03 Apr 2026 14:37:02 GMT) | 2026-10-30, with curl | `2e67fd5c732edf127f711c75c4a4ce35e9cbca936b3dfe25386383b92f683365` |

In XML Schema 1.1 the built-in datatype definitions are not part of
`datatypes.xsd`, as they were in XML Schema 1.0: Part 2 gives them in
Appendix C, which the W3C publishes next to `datatypes.xsd` as
`primitives.nxsd` and `derived.nxsd`.

The value spaces and the lexical and canonical mappings of the primitive
datatypes are the algorithms of Part 2 (§3.3 and Appendix E), implemented in
`Sources/XSD/Primitives` and `Sources/XSD/ValueSpaces`; the derived datatypes
are their restrictions by the facets these documents give.

Check the documents with:

    cd Sources/XSD/W3C
    shasum -a 256 datatypes.xsd primitives.nxsd derived.nxsd rdf12-concepts.html

The documents are © World Wide Web Consortium, under the W3C licenses
(<https://www.w3.org/copyright/>).
