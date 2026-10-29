# AGENTS.md

## Tools
- Use Xcode tools (xcode_*) for building, testing, and project navigation
- Use XcodeBuildMCP skill before calling XcodeBuildMCP tools
- Do not use shell commands for build/test operations

## Architecture Documentation
- All architecture docs live in `docs/` folder
- Do not modify docs without user approval
- Current docs: ArchitectureSpec.md, CodeGeneration.md, ContentModifierDesign.md, DslInvariants.md, MacroDesign.md, OrganizationPattern.md, Rdf12Concepts.md, Swift.md, VocabularyPlan.md

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
- Macro reads the DSL content to determine what to generate (see docs/MacroDesign.md)
- `Class` in DSL generates a protocol (requirements are the properties with it as `Domain`; `SubClassOf` is refinement) and a final-class individual type
- `Individual` in DSL generates a static constant, the one instance of a final class conforming to its classes
- `Datatype` in DSL generates a value type that stores the literal
- `Property` in DSL generates a requirement on its domain's protocol, many-valued unless functional, and a property term type
- Annotation protocols (Label, Comment) generate DocC documentation
- Property characteristic protocols generate appropriate behaviors
