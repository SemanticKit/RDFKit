# RDFKit

A protocol-oriented RDF ontology DSL for Swift.

## What This Is

RDFKit is a Swift library for defining RDF ontologies using a declarative DSL. You write ontologies the way you think about them — classes, properties, relationships — and the Swift compiler validates the structure.

```swift
public struct OWL: Ontology {
    public var content: Content {
        Namespace("http://www.w3.org/2002/07/owl#")

        Class("Thing") {
            Type(RDFSTerm.Class)
            Label("Thing")
            Comment("The class of OWL individuals.")
        }

        Property("sameAs") {
            Type(RDFTerm.Property)
            Domain(OWLTerm.Thing)
            Range(OWLTerm.Thing)
            Label("sameAs")
        }
    }
}
```

This reads like RDF. It IS RDF. The compiler enforces the structure.

## Architecture

### Two Targets

- **RDFCore** — the DSL machinery: protocols, result builders, node types
- **RDFKit** — the standard ontologies: RDF, RDFS, OWL defined using the DSL

### Protocol Hierarchy

```
Node
  ├─ Term
  │    ├─ Subject
  │    ├─ Predicate
  │    └─ Object
  ├─ TermContent (can appear as child of a term declaration)
  │    ├─ ClassDeclaration
  │    ├─ PropertyDeclaration
  │    ├─ IndividualDeclaration
  │    ├─ DatatypeDeclaration
  │    ├─ TypeAnnotation
  │    ├─ SubClassOfAnnotation
  │    ├─ SubPropertyOfAnnotation
  │    ├─ DomainAnnotation
  │    ├─ RangeAnnotation
  │    ├─ LabelProtocol
  │    ├─ CommentProtocol
  │    ├─ SeeAlsoProtocol
  │    └─ OWLDeprecatedProtocol
  ├─ Namespace
  └─ Prefix
```

### How It Works

1. **Protocols define what something IS** — `ClassDeclaration`, `TypeAnnotation`, etc.
2. **Extensions provide behavior** — `Ontology` gets `Class()`, `Property()` etc. for free via protocol extension
3. **Structs hold data** — `TermDeclaration`, `LabelAnnotationValue` etc.
4. **Result builders compose content** — `@ContentBuilder` and `@TermContentBuilder` use parameter packs

### The Content Tree

An ontology's `content` property produces a `[any Node]` — an ordered list of declarations, prefixes, and namespaces. Consumers walk this tree to find terms, annotations, and namespace context.

```swift
// The content tree contains:
// - Prefix declarations (alias + namespace IRI)
// - Namespace declaration (the ontology's own namespace IRI)
// - Term declarations (class, property, individual, datatype)
//   └─ Each term has children (annotations: Type, SubClassOf, Label, etc.)
```

### Key Design Rules

See `DSL_INVARIANTS.md` for the full set. The essential ones:

- **DSL terms match RDF/RDFS/OWL vocabulary names 1:1** — `Class` = `rdfs:Class`, `Label` = `rdfs:label`
- **Ontology declarations are the source of truth** — not generated types
- **Child declarations do not know parent context** — consumers walking the tree determine namespace, aliases, parent ontology
- **Term identity is RDF IRI identity** — Swift type identity is never term identity
- **Protocol-oriented, not class-per-term** — protocols define roles, structs conform

## Package Structure

```
RDFKit/
├── Package.swift
├── AGENTS.md                    # Agent instructions
├── DSL_INVARIANTS.md            # DSL design rules
├── Sources/
│   ├── RDFCore/                 # DSL machinery
│   │   ├── API/
│   │   │   ├── DefinedBy.swift
│   │   │   └── Namespaced.swift
│   │   ├── Node.swift           # Node, Subject, Predicate, Object protocols
│   │   ├── Term.swift           # Term protocol
│   │   ├── Ontology.swift       # Ontology protocol + DSL methods
│   │   ├── Vocabulary.swift     # Protocols, concrete types, free functions
│   │   ├── ContentBuilder.swift # @resultBuilder with parameter packs
│   │   ├── ContentModifier.swift # Modifier protocol + tree walker
│   │   ├── Namespace.swift      # Namespace type
│   │   ├── Prefix.swift         # Prefix type
│   │   ├── IRI+Identifiable.swift
│   │   ├── IRI+Term.swift
│   │   ├── Literal.swift
│   │   ├── BlankNode.swift
│   │   ├── Triple.swift
│   │   └── ...
│   └── RDFKit/                  # Standard ontologies
│       ├── RDFKit.swift         # @_exported import RDFCore
│       ├── RDF/                 # RDF ontology
│       ├── RDFS/                # RDFS ontology
│       └── OWL/                 # OWL ontology
└── Tests/
    └── RDFKitTests/             # Consumer-driven tests
```

## Status

### Done
- Protocol hierarchy and concrete types
- Parameter pack result builders (no manual arity overloads)
- Content modifier system (type-safe, target-specific)
- RDF, RDFS, OWL ontologies defined using the DSL
- Namespace extraction from content tree

### In Progress
- Eliminating scaffolding via compiler-generated types
- Consumer test library

### Next
- Macros that read ontology metadata and generate type-safe term references
- Self-describing loop: DSL defines ontology → compiler generates types → types ARE the DSL
