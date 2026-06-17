# AGENTS.md

## Tools
- Use Xcode tools (xcode_*) for building, testing, and project navigation
- Use XcodeBuildMCP skill before calling XcodeBuildMCP tools
- Do not use shell commands for build/test operations

## Architecture Documentation
- All architecture docs live in `docs/` folder
- Do not modify docs without user approval
- Current docs: ARCHITECTURE_SPEC.md, ContentModifierDesign.md, DSL_INVARIANTS.md, MACRO_DESIGN.md, VocabularyPlan.md

## Testing
- Each protocol gets its own test file
- Always use `@Suite` for test organization
- Use Tags from `Tests/Tags.swift` for grouping
- Use `@testable import` for internal types
- Do not test scaffolding types or metadata
- Test actual usage and behavior

## Code Changes
- Do not commit without user approval
- Do not make changes without understanding the architecture first
- Document processes as we go for repeatability
- Ask questions before implementing

## File Organization (RDFCore)
- One file per protocol
- Special protocols carry conforming types in the same file
- One test file per protocol
- Tags defined in `Tests/Tags.swift`

## Protocols
- Protocols carry behaviors from RDF/RDFS/OWL standards
- Each protocol has a clear purpose from the standards
- Do not rename protocols (e.g., `Class` not `ClassDeclaration`)
- Generated types conform to protocols, not use enums

## Code Generation
- Macro reads protocol conformance to determine what to generate
- `Class` in DSL generates a Swift class
- `Property` in DSL generates a property
- Annotation protocols (Label, Comment) generate DocC documentation
- Property characteristic protocols generate appropriate behaviors
