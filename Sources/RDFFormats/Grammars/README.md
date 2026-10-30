# Grammars

The grammars RDFFormats reads documents with, as the W3C specifications
publish them, byte for byte:

| Document | Published at | Grammar |
|---|---|---|
| `turtle.bnf` | <https://www.w3.org/TR/2026/WD-rdf12-turtle-20261023/turtle.bnf> | RDF 1.2 Turtle §6.5 |
| `ntriples.bnf` | <https://www.w3.org/TR/2026/WD-rdf12-n-triples-20261023/ntriples.bnf> | RDF 1.2 N-Triples §5.3 |
| `xml-names.html` | <https://www.w3.org/TR/2009/REC-xml-names-20091208/> | Namespaces in XML 1.0, `NCName` |
| `xml.html` | <https://www.w3.org/TR/2008/REC-xml-20081126/> | XML 1.0, `Name`, `Char` and `S` |

Each `<Name>.grammar.json` names its documents with the URL, the day they were
retrieved and the SHA-256 digest of their bytes. On every build
EBNFTranslatorPlugin (from EBNFKit) checks each document against its digest and
translates the grammar into `<Name>Grammar`: one Swift type for each
production. The translation is not checked in.

RDF/XML (RDF 1.2 XML Syntax) states its grammar over XML events rather than in
EBNF; the productions it takes from XML, `NCName` for `rdf:ID` and
`rdf:nodeID`, `Char` and `S`, are read from the scrap tables of the XML
Recommendations.

What the specifications state in prose rather than in EBNF is in the decoders:
white space and comments between terminals (`TurtleGrammar.trivia`,
`NTriplesGrammar.trivia`), the case-insensitive keywords of Turtle
(`"caseInsensitiveStrings"` in `Turtle.grammar.json`), and the actions that turn
the productions into triples.

To take a newer publication, download the document, replace the file, and
update its `url`, `retrieved` and `sha256` in the configuration:

```sh
curl -sSL -o turtle.bnf https://www.w3.org/TR/rdf12-turtle/turtle.bnf
shasum -a 256 turtle.bnf
```
