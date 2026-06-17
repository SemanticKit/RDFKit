# ContentModifier API

Implemented in `Sources/RDFCore/ContentModifier.swift`.

## Protocol

`ContentModifier<ContentType>` — associated type constrains target node type. `shouldApply(to:)` for selective dispatch (default: true). `apply(to:)` returns same concrete type.

Content modifiers are type-safe: they only decorate things they can apply to, and they bring something TO their target. They have zero knowledge of aggregation mechanics.

## Composition-Time

- `.modifier(M)` — trailing syntax on any `Node`
- `.with(A(), B(), C())` — variadic multi-modifier application

## Post-Processing

- `applyRecursively(to:)` — walks content tree depth-first (recurse into `TermDeclaration.children`)
- `applyModifier(_:to:)` — free function entry point

## Rules

- Modifiers must be type-safe via protocols/conformances
- Modifiers must only decorate things they can apply to (associated type constraint)
- Modifiers must bring something TO their target (like SwiftUI `ViewModifier`)
- Modifiers must have zero knowledge of aggregation mechanics
