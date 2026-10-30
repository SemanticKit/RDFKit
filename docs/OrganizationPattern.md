# RDFCore Organization Pattern

## File Structure

Each DSL declaration form gets its own file. The file contains all layers for that form:

```
Sources/RDFCore/
├── Core/
│   ├── Declarations/
│   │   ├── Class.swift       # DSL form for owl:Class; generates a Swift class
│   │   ├── Datatype.swift    # DSL form for rdfs:Datatype
│   │   ├── Individual.swift  # DSL form for owl:NamedIndividual
│   │   └── Property.swift    # DSL form for rdf:Property
│   ├── Annotations/
│   │   ├── Comment.swift     # rdfs:comment; generates DocC documentation
│   │   ├── Deprecated.swift  # owl:deprecated; Deprecated("reason") generates @available
│   │   ├── Label.swift       # rdfs:label; generates DocC documentation
│   │   └── SeeAlso.swift     # rdfs:seeAlso
│   ├── Entity.swift
│   ├── Ontology.swift
│   └── ...
├── Builders/
│   └── ContentBuilder.swift
└── Runtime/
    ├── Resource.swift
    ├── ResourceClass.swift
    ├── TermKey.swift
    └── ...
```

There is no `Modifiers/` layer: a declaration is never modified by chained methods (`add*`, `isDeclaredBy`). What a declaration states is written as declaration forms in its trailing closure, in the ontology's `var body`. The rdf, rdfs and owl terms themselves are not typed here; they come from translating rdf.ttl, rdfs.ttl and owl.ttl.

## MARK Convention

Each file uses `// MARK:` sections to organize content:

```swift
import Foundation

// MARK: - Protocol

/// A human-readable label.
///
/// From RDFS: Used to provide a human-readable version of a resource's name.
public protocol LabelProtocol: TermContent {
    /// The label text.
    var text: String { get }
}

// MARK: - Concrete Type

/// A human-readable label.
public struct LabelAnnotationValue: LabelProtocol, ContributionAnnotation {
    public let text: String
    public let contributionProtocolName: String = "LabeledTerm"
    public let contributionTypeName: String = "LabelAnnotationValue"

    public init(_ text: String) {
        self.text = text
    }
}

// MARK: - DSL

/// A human-readable label for a term.
///
///     Label("Resource")
public func Label(_ text: String) -> LabelAnnotationValue {
    LabelAnnotationValue(text)
}
```

## Naming Conventions

- **Protocols**: `{TermName}Protocol` (e.g., `LabelProtocol`, `CommentProtocol`)
- **Concrete types**: `{TermName}AnnotationValue` (e.g., `LabelAnnotationValue`)
- **DSL functions**: `{TermName}` (e.g., `Label()`, `Comment()`)
- **File names**: `{TermName}.swift` (e.g., `Label.swift`, `Comment.swift`)

## Rules

1. Each declaration form gets its own file
2. Files contain all layers (Protocol, Concrete Type, DSL)
3. Use `// MARK:` sections to organize content
4. Follow Swift API Design Guidelines
5. Document with DocC-style comments
