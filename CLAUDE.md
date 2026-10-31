# CLAUDE.md

The project instructions are in [AGENTS.md](AGENTS.md). The rules below come on top of them.

## Swift 6.4 sources of truth

Before you write or change any Swift, read [SWIFT-6.4.md](https://github.com/SemanticKit/SemanticKit/blob/main/docs/SWIFT-6.4.md), the SemanticKit Swift 6.4 reference built from the 6.4 CHANGELOG, swift-evolution and swift.org. Every item cites its SE proposal. Where it disagrees with your memory, it wins; where the toolchain's `.swiftinterface` files disagree with it, the toolchain wins.

Before you write or change Swift, read the Swift 6.4 sources for every language feature and standard library API you use. Use what they say, not what you remember.

- **The standard library API**, in the toolchain's module interfaces:
  - `/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib/swift/Swift.swiftmodule/arm64e-apple-macos.swiftinterface` for the standard library. Its header names the compiler, `swiftlang-6.4.2.1.9`.
  - The `.swiftinterface` files in the other `*.swiftmodule` directories next to it, such as `_Concurrency.swiftmodule` and `_StringProcessing.swiftmodule`.
  - `xcrun --show-sdk-path` prints the SDK path these live under.
- **The language**: *The Swift Programming Language*, for Swift 6.4 (https://docs.swift.org/swift-book/).
- **Evolution**: the accepted proposals up to Swift 6.4, in swift-evolution/proposals (https://github.com/swiftlang/swift-evolution/tree/main/proposals).

When a commit uses a feature, cite its SE proposal in the commit message.

## No copies of results

Never wrap a result in a new collection. That rules out `Set(...)`, `Array(...)`, a `.map` or `.filter` into a fresh array, and returning a concrete copy, unless ownership truly needs one: a stored property, a value that is mutated, or generated output.

Instead:
- Query the index directly.
- Return the stored collection as it is.
- Return a lazy view or an opaque `some Sequence<Element>` (SE-0341, SE-0346).
- Use `contains`, `first(where:)` and `count(where:)` (SE-0220) rather than building a collection to test.

Sort only where the output order needs it, and only once.
