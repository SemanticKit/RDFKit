# RDFCore Organization Pattern

## File Structure

Each RDF/RDFS/OWL term gets its own file. The file contains all layers for that term:

```
Sources/RDFCore/
├── Core/
│   ├── Node.swift
│   ├── Ontology.swift
│   ├── OntologyTerm.swift
│   ├── Term.swift
│   ├── TermDeclaration.swift
│   └── ...
├── RDF/
│   ├── Individual.swift      # Protocol + DSL
│   ├── Property.swift        # Protocol + DSL
│   ├── Type.swift            # Protocol + Concrete Type + DSL
│   └── ...
├── RDFS/
│   ├── Class.swift           # Protocol + DSL
│   ├── Comment.swift         # Protocol + Concrete Type + DSL
│   ├── Datatype.swift        # Protocol + DSL
│   ├── Domain.swift          # Protocol + Concrete Type + DSL
│   ├── IsDefinedBy.swift     # Protocol + Concrete Type + DSL
│   ├── Label.swift           # Protocol + Concrete Type + DSL
│   ├── Range.swift           # Protocol + Concrete Type + DSL
│   ├── SeeAlso.swift         # Protocol + Concrete Type + DSL
│   ├── SubClassOf.swift      # Protocol + Concrete Type + DSL
│   ├── SubPropertyOf.swift   # Protocol + Concrete Type + DSL
│   └── ...
├── OWL/
│   └── OWLDeprecated.swift   # Protocol + Concrete Type + DSL
├── Builders/
│   ├── ContentBuilder.swift
│   └── TermContentBuilder.swift
└── Modifiers/
    ├── ContentModifier.swift
    ├── Node+Modifiers.swift
    └── ApplyModifier.swift
```

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

1. Each term gets its own file
2. Files contain all layers (Protocol, Concrete Type, DSL)
3. Use `// MARK:` sections to organize content
4. Follow Swift API Design Guidelines
5. Document with DocC-style comments
