# RDFKit

RDF vocabularies as Swift types, generated from their published documents.

## What This Is

Give RDFKit an ontology's documents (Turtle or RDF/XML) and it generates the Swift they describe:

- each class becomes a protocol in the class hierarchy
- each property becomes a requirement on its domain's protocol
- each individual in the data becomes an instance of a generated class

The published semantics decide what each term is: the RDFS entailment patterns, the OWL 2 RL rules and the OWL 2 RDF-Based Semantics, read from the W3C documents.

```swift
// FOAF, translated from index.rdf
public protocol Person: FOAF.SpatialThing, FOAF.Agent, AnyObject {
    var firstName: Values<any RDFS.Literal> { get set }
}

// alice.ttl, translated to FOAF individuals
alice.knows.contains { $0 === bob }   // true
```

## Translating an Ontology

Put the documents in a target and add the plugin:

```swift
.target(
    name: "MyVocabulary",
    dependencies: ["IRIKit", "RDFKit", "RDFCore"],
    plugins: ["RDFTranslatorPlugin"]
)
```

Or run the translator yourself:

```
swift run RDFTranslator <output.swift> <module> <namespace|-> <document>... [--layer <module> <namespace|-> <document>...]...
```

Each `--layer` is a vocabulary this one builds on. RDF, RDFS and OWL are always available from `RDFKit`.

## Design

The design decisions D1 to D8 come from the standards:

- **D1.** A class is a protocol, and `rdfs:subClassOf` is protocol inheritance.
- **D2.** An individual conforms to the protocols of all its classes.
- **D3.** An individual's identity is the object's, `===`.
- **D4.** A property is a requirement on its domain's protocol.
- **D5.** A many-valued property is `Values`, a set. A functional property is an `Optional`.
- **D6.** A datatype is a Swift value type built from its lexical form (`XSD`), and `Literal` stays at the boundary.
- **D7.** RDF-Based Semantics: `rdfs:Resource` and `owl:Thing` are one root protocol, and `owl:Nothing` is `Never`.
- **D8.** Annotations become DocC.

See [docs/CodeGeneration.md](docs/CodeGeneration.md) for how the Swift is generated.

## Package Structure

```
RDFKit/
├── Package.swift
├── AGENTS.md, CLAUDE.md          # Agent instructions
├── docs/                         # Architecture docs
├── Plugins/                      # RDFTranslatorPlugin, SemanticsEmitterPlugin, XSDEmitterPlugin
├── Sources/
│   ├── RDFCore/                  # The RDF 1.2 data model at the boundary, Values, Ontology
│   ├── RDFKit/                   # RDF, RDFS, OWL from rdf.ttl, rdfs.ttl, owl.ttl; @Ontology
│   ├── RDFKitMacros/             # @Ontology
│   ├── OntologyGeneration/       # Schema, the published semantics, the generators
│   ├── SemanticsEmitter/         # Reads the W3C semantics tables
│   ├── RDFTranslator/            # RDF documents → Swift
│   ├── RDFFormats/               # N-Triples, Turtle, RDF/XML; GraphEncoder
│   ├── XSD/                      # XML Schema datatypes as Swift value types
│   └── XSDDefinitions/, XSDEmitter/
└── Tests/
    └── ParallelTests/            # FOAF and an Alice profile, translated and used
```

See [docs/OrganizationPattern.md](docs/OrganizationPattern.md) for what each target holds.
