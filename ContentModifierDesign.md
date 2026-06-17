# ContentModifier API

Implemented in `Sources/RDFCore/ContentModifier.swift`.

## Protocol

`ContentModifier<ContentType>` — associated type constrains target node type. `shouldApply(to:)` for selective dispatch (default: true). `apply(to:)` returns same concrete type.

## Composition-Time

- `.modifier(M)` — trailing syntax on any `Node`
- `.with(A(), B(), C())` — variadic multi-modifier application

## Post-Processing

- `applyRecursively(to:)` — walks `ContentGroup` tree depth-first
- `applyModifier(_:to:)` — free function entry point
