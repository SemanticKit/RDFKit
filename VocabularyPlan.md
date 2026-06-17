# The Self-Describing Loop

## Current State

The DSL works. You can write ontologies:

```swift
public struct OWL: Ontology {
    public var content: Content {
        Namespace("http://www.w3.org/2002/07/owl#")
        Class("Thing") { Type(RDFSTerm.Class) ... }
        Property("sameAs") { Type(RDFTerm.Property) ... }
    }
}
```

But the term references (`OWLTerm.Class`, `RDFSTerm.Class`) are hand-written enums. That's scaffolding.

## The Loop

The ontology content tree already contains everything needed:
- Term names (`"Thing"`, `"sameAs"`)
- Term types (via `Type(RDFSTerm.Class)`)
- Relationships (`SubClassOf`, `Domain`, `Range`)
- Namespace (`"http://www.w3.org/2002/07/owl#"`)

A macro reads this metadata at compile time and generates the type-safe term references. The hand-written `+Terms.swift` files come down.

## What the Macro Generates

From the ontology content, the macro produces static properties with IRI values:

```swift
// Auto-generated from OWL ontology content
extension OWL {
    /// owl:Thing — The class of OWL individuals.
    public static let Thing: IRI = "http://www.w3.org/2002/07/owl#Thing"
    
    /// owl:sameAs — The property that determines that two given individuals are equal.
    public static let sameAs: IRI = "http://www.w3.org/2002/07/owl#sameAs"
}
```

## What This Eliminates

- Hand-written `OWL+Terms.swift`, `RDF+Terms.swift`, `RDFS+Terms.swift`
- Generic `TermDeclaration` scaffolding (the DSL methods still return it, but it's internal)
- Runtime string concatenation for IRI resolution
- Resolver structs (the type system provides identity via `Identifiable` on `IRI`)

## What Stays

- The DSL syntax (unchanged)
- The protocol hierarchy (defines what something IS)
- The result builders (compose content)
- The content tree (the ontology IS the tree)
- `IRI: Identifiable` (identity is the IRI)

## Testing Approach

Don't test scaffolding types. Build a new ontology using the DSL. Prove it works end-to-end. The consumer test library depends on RDFKit, declares new ontologies, and verifies the DSL is self-describing.
