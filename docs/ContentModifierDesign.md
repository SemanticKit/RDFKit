# ContentModifier Design

## Pattern (like SwiftUI's ViewModifier)

In SwiftUI:
```swift
Text("Hello")
    .padding()
    .foregroundColor(.red)
    .background(.blue)
```

Each modifier is a method on the view that returns a modified view.

For RDFKit, modifiers are methods on the target that return modified targets:
```swift
Class("Foo")
    .addLabel("Foo")
    .addComment("Bar")
    .deprecated()
    .isDeclaredBy(namespace: OWL.namespace)
```

## Protocol

`ContentModifier` — defines how NEW modifiers can be created externally.

```swift
protocol ContentModifier {
    associatedtype Target
    func apply(to target: Target) -> Target
}
```

## Rules

- Modifiers are methods on the target type (like SwiftUI)
- `ContentModifier` protocol allows external code to define new modifiers
- Modifiers return modified targets (not void)
- Modifiers have zero knowledge of aggregation mechanics
- Modifiers only decorate things they can apply to
