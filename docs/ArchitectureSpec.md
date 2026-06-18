# RDFKit Architecture Spec

## Vision

Define an ontology once in Swift using a DSL. The DSL maps 1:1 to RDF/RDFS/OWL standards. At compile time, a macro reads the ontology and generates real Swift types. Those types are what users build with.

Swift becomes the new OWL-like language. Protocols carry behaviors. The type system does the work.

---

## Architecture Layers (Ordered by Necessity)

### Layer 1: Standards (Source of Truth)

The RDF/RDFS/OWL standards define everything. We don't invent — we implement.

| Standard | Namespace | Purpose |
|----------|-----------|---------|
| RDF 1.2 | `http://www.w3.org/1999/02/22-rdf-syntax-ns#` | Core data model — what things ARE |
| RDFS 1.2 | `http://www.w3.org/2000/01/rdf-schema#` | Schema vocabulary — how things RELATE |
| OWL 2 | `http://www.w3.org/2002/07/owl#` | Ontology language — how things BEHAVE |

### Layer 2: RDFCore (Swift API for Standards)

Implements the standards in Swift. This is the foundation everything builds on.

**Infrastructure:**
- `Node` — base type for everything in RDF
- `IRI` — identity system (from IRIKit)
- `Ontology` — protocol for building ontologies (like SwiftUI's View)

**Declaration Protocols — what gets generated:**
- `Class` — generates a Swift class
- `Property` — generates a property on a type
- `Individual` — generates an individual instance
- `Datatype` — generates a datatype

**Relationship Protocols — what modifies generated types:**
- `Domain` — adds domain property
- `Range` — adds range property
- `SubClassOf` — generates class inheritance
- `SubPropertyOf` — generates property inheritance
- `Type` — declares what something IS

**Annotation Protocols — metadata on generated types:**
- `Label` — display name (how something is named) → DocC documentation
- `Comment` — documentation comment (DocC) → DocC documentation
- `SeeAlso` — related information → DocC documentation
- `IsDefinedBy` — definition source → DocC documentation

**Property Characteristic Protocols — behaviors from OWL:**
- `FunctionalProperty` — at most one value per subject
- `TransitiveProperty` — if A→B and B→C, then A→C
- `InverseFunctionalProperty` — at most one subject per value
- `SymmetricProperty` — if A→B, then B→A
- `AsymmetricProperty` — if A→B, then not B→A
- `ReflexiveProperty` — every individual relates to itself
- `IrreflexiveProperty` — no individual relates to itself

### Layer 3: RDFKit (DSL for Defining Ontologies)

Users write ontologies using the DSL. The DSL maps 1:1 to the standards.

**Components:**
- ContentBuilder — result builder for content
- DSL functions — Class(), Property(), Individual(), Datatype()
- Content modifiers — .deprecated(), .isDeclaredBy()

### Layer 4: Code Generation (Macro)

Reads the DSL and generates Swift types. Reads protocol conformance to determine what to generate.

**How it works:**
1. User writes `Class("Animal")` → returns `TermDeclaration` conforming to `Class`
2. Macro reads `Class` conformance → knows to generate a Swift class
3. User writes `Domain(Fauna.Animal)` → macro reads `Domain` conformance → adds domain property
4. Generated type conforms to protocols → has behaviors from standards

### Layer 5: Generated Types (What Users Interact With)

**Consumer types** — real Swift types with properties:
- Generated at module level, not nested
- Properties derived from Domain/Range annotations
- Conform to standard Swift protocols (Equatable, Codable, etc.)

**Nested Term** — metadata carrier (like CodingKeys):
- Each type has a nested `Term` that carries RDF metadata
- `Term` protocol unifies them

---

## Protocol-Oriented Architecture

Every term in the standards has meaning — that meaning IS the behavior.

### How It Works
1. The standard declares what each term means
2. That meaning becomes a protocol in RDFCore
3. Types conform to the protocol to get that behavior
4. The macro reads protocol conformance to generate code
5. Types that conform share behavior, even if they differ in other ways

### Extensibility

Common behaviors go in RDFCore — the shared API consumed by the macro. These are "different but identical" — same interface, different implementations. Extensibility comes through content modifiers or other means, allowing custom behaviors without changing the core.

---

## Core API Surface (RDFCore)

### What RDFCore Must Provide

**1. Declaration Protocols — what gets generated**
- `Class` — generates a Swift class
- `Property` — generates a property on a type
- `Individual` — generates an individual instance
- `Datatype` — generates a datatype

**2. Relationship Protocols — what modifies generated types**
- `Domain` — adds domain property
- `Range` — adds range property
- `SubClassOf` — generates class inheritance
- `SubPropertyOf` — generates property inheritance
- `Type` — declares what something IS

**3. Annotation Protocols — metadata on generated types**
- `Label` — display name (how something is named) → DocC documentation
- `Comment` — documentation comment (DocC) → DocC documentation
- `SeeAlso` — related information → DocC documentation
- `IsDefinedBy` — definition source → DocC documentation

These are metadata about the types. They should be generated as DocC comments on the generated types, not as stored properties.

**4. Property Characteristic Protocols — behaviors from OWL**
- `FunctionalProperty` — at most one value per subject
- `TransitiveProperty` — if A→B and B→C, then A→C
- `InverseFunctionalProperty` — at most one subject per value
- `SymmetricProperty` — if A→B, then B→A
- `AsymmetricProperty` — if A→B, then not B→A
- `ReflexiveProperty` — every individual relates to itself
- `IrreflexiveProperty` — no individual relates to itself

**5. Infrastructure**
- `Node` — base type for all RDF nodes
- `IRI` — internationalized resource identifier (from IRIKit)
- `Term` — metadata carrier (like CodingKeys)
- `Ontology` — what ontologies conform to

### What RDFCore Does NOT Provide

- Code generation logic (that's the macro)
- DSL functions (that's RDFKit)
- Concrete implementations (that's the generated code)

### Type Conformances

All types should conform to standard Swift protocols where applicable. This makes them work everywhere — in collections, as dictionary keys, for serialization, etc.

**Minimum conformance set:**
- `Sendable` — for concurrency
- `Equatable` — for comparison
- `Hashable` — for collections
- `Codable` — for serialization
- `CustomStringConvertible` — for display

**Example from `Namespace`:**
```swift
public struct Namespace: Node, RawRepresentable, Equatable, Hashable,
    Sendable, Codable, Comparable, LosslessStringConvertible,
    CustomStringConvertible, ExpressibleByStringLiteral {
    // ...
}
```

### Swift API Design Guidelines

Follow Swift API Design Guidelines strictly:

- **Clarity at point of use** — APIs should be clear where they're used
- **Clarity over brevity** — Don't sacrifice clarity for shorter code
- **Fluent usage** — Methods should read naturally in context
- **Proper naming** — Use Swift naming conventions (lowerCamelCase for methods/properties, UpperCamelCase for types)
- **Documentation** — Begin with a summary, describe what it does and returns

**Naming examples:**
- `func domain() -> Node?` — not `func getDomain() -> Node?`
- `var label: String?` — not `func getLabel() -> String?`
- `func subClassOf() -> Node?` — not `func getSuperclass() -> Node?`

### Swift Language Features

Leverage modern Swift features for clean, expressive code:

**Protocol-Oriented Design:**
- Protocols define behaviors, not implementations
- Protocol extensions provide default implementations
- Protocol conformance drives code generation

**Value Types:**
- Structs for immutable data (terms, annotations)
- Enums for fixed sets (term kinds, if needed)
- Avoid classes unless reference semantics are required

**Result Builders:**
- `@ContentBuilder` for composing ontology content
- `@TermContentBuilder` for composing term annotations
- Parameter packs for variadic content

**Opaque Return Types:**
- `some Node` for type-safe return values
- Preserve type information through the call chain

**Property Wrappers:**
- Consider for computed properties that need storage control

**Macros:**
- `@Vocabulary` for code generation
- Compile-time processing of DSL declarations

**Sendable/Concurrency:**
- All types should be `Sendable` for safe concurrent access
- Immutable value types are naturally sendable

**Pattern Matching:**
- `switch` statements for handling different term types
- `if let` for optional unwrapping

**Extensions:**
- Add functionality to existing types without modification
- Protocol extensions for shared behavior

**Rule:** If a type can reasonably conform to a standard Swift protocol, it should. This makes the type usable everywhere without extra work.

### File Organization

Each protocol gets its own clean file. Special protocols carry conforming types in the same file. Each protocol gets its own test file.

| Protocol | File | Test File | Notes |
|----------|------|-----------|-------|
| `Node` | `Node.swift` | `NodeTests.swift` | Carries `IRI` conformance |
| `Ontology` | `Ontology.swift` | `OntologyTests.swift` | |
| `Class` | `Class.swift` | `ClassTests.swift` | |
| `Property` | `Property.swift` | `PropertyTests.swift` | |
| `Individual` | `Individual.swift` | `IndividualTests.swift` | |
| `Datatype` | `Datatype.swift` | `DatatypeTests.swift` | |
| `Domain` | `Domain.swift` | `DomainTests.swift` | |
| `Range` | `Range.swift` | `RangeTests.swift` | |
| `SubClassOf` | `SubClassOf.swift` | `SubClassOfTests.swift` | |
| `SubPropertyOf` | `SubPropertyOf.swift` | `SubPropertyOfTests.swift` | |
| `Type` | `Type.swift` | `TypeTests.swift` | |
| `Label` | `Label.swift` | `LabelTests.swift` | |
| `Comment` | `Comment.swift` | `CommentTests.swift` | |
| `SeeAlso` | `SeeAlso.swift` | `SeeAlsoTests.swift` | |
| `IsDefinedBy` | `IsDefinedBy.swift` | `IsDefinedByTests.swift` | |
| `FunctionalProperty` | `FunctionalProperty.swift` | `FunctionalPropertyTests.swift` | |
| `TransitiveProperty` | `TransitiveProperty.swift` | `TransitivePropertyTests.swift` | |
| `InverseFunctionalProperty` | `InverseFunctionalProperty.swift` | `InverseFunctionalPropertyTests.swift` | |
| `SymmetricProperty` | `SymmetricProperty.swift` | `SymmetricPropertyTests.swift` | |
| `AsymmetricProperty` | `AsymmetricProperty.swift` | `AsymmetricPropertyTests.swift` | |
| `ReflexiveProperty` | `ReflexiveProperty.swift` | `ReflexivePropertyTests.swift` | |
| `IrreflexiveProperty` | `IrreflexiveProperty.swift` | `IrreflexivePropertyTests.swift` | |

---

## What Describes vs What Defines

**Ontology side (describes):**
- `Class("Animal")` — declares a class named "Animal"
- `Type(RDFS.Class)` — describes that Animal IS a class
- `SubClassOf(RDFS.Resource)` — describes that Animal inherits from Resource
- `Domain(Fauna.Animal)` — describes that hasHabitat has Animal as domain
- `Range(Fauna.Habitat)` — describes that hasHabitat has Habitat as range

**Swift side (defines):**
- `class Animal` — defines a Swift class
- `Type` → generates class declaration
- `SubClassOf` → generates class inheritance
- `Domain` → generates property with domain type
- `Range` → generates property with range type

---

## Protocol Conformances

Generated types should conform to standard Swift protocols:
- `Equatable` — for comparison
- `Codable` — for serialization
- `Hashable` — for hashing
- `Sendable` — for concurrency
- `CustomStringConvertible` — for display

---

## Module Split

- **RDFCore** = API / building blocks (Node, IRI, protocols, generated type APIs)
- **RDFKit** = DSL support (Ontology protocol, ContentBuilder, DSL functions, annotation types, macro)

---

## RDF/RDFS/OWL Lookup Table

### RDF 1.2 (Resource Description Framework)
Namespace: `http://www.w3.org/1999/02/22-rdf-syntax-ns#`

| Name | Type | Description |
|------|------|-------------|
| Property | Class | The class of RDF properties |
| Statement | Class | A class used in old-style reification to represent reified triples |
| List | Class | Used to build descriptions of lists and other list-like structures |
| HTML | Datatype | The class of HTML literal values |
| JSON | Datatype | The class of JSON literal values |
| langString | Datatype | The class of language-tagged string values |
| dirLangString | Datatype | The class of directional language-tagged string values |
| XMLLiteral | Datatype | The class of XML literal values |
| type | Property | Used to state that a resource is an instance of a class. Domain: rdfs:Resource, range: rdfs:Class |
| value | Property | May be used in describing structured values. Domain: rdfs:Resource, range: rdfs:Resource |
| first | Property | Used to build descriptions of lists. Domain: rdf:List, range: rdfs:Resource |
| rest | Property | Used to build descriptions of lists. Domain: rdf:List, range: rdf:List |
| subject | Property | Used in old-style reification. Domain: rdf:Statement, range: rdfs:Resource |
| predicate | Property | Used in old-style reification. Domain: rdf:Statement, range: rdfs:Resource |
| object | Property | Used in old-style reification. Domain: rdf:Statement, range: rdfs:Resource |
| reifies | Property | Used to associate a resource with a proposition. Domain: rdfs:Resource, range: rdfs:Proposition |
| direction | Property | The direction of a compound literal |
| language | Property | The language of a compound literal |
| nil | Individual | An instance of rdf:List representing an empty list |

### RDFS 1.2 (RDF Schema)
Namespace: `http://www.w3.org/2000/01/rdf-schema#`

| Name | Type | Description |
|------|------|-------------|
| Resource | Class | The class of everything. All things described by RDF are called resources and are instances of rdfs:Resource. All other classes are subclasses of this class. Instance of rdfs:Class |
| Class | Class | The class of resources that are RDF classes. Instance of rdfs:Class |
| Literal | Class | The class of literal values such as strings and integers. Instance of rdfs:Class. Subclass of rdfs:Resource |
| Datatype | Class | The class of datatypes. Both an instance of and a subclass of rdfs:Class. Each instance is a subclass of rdfs:Literal |
| Container | Class | A super-class of the RDF container classes (rdf:Bag, rdf:Seq, rdf:Alt) |
| ContainerMembershipProperty | Class | The class whose instances are the properties rdf:_1, rdf:_2, rdf:_3, ... used to state container membership. Subclass of rdf:Property |
| Proposition | Class | The class of propositions, simple logical expressions describing a relationship between two entities. Instance of rdfs:Class and subclass of rdfs:Resource |
| subClassOf | Property | Used to state that all instances of one class are instances of another. Domain: rdfs:Class, range: rdfs:Class. Transitive |
| subPropertyOf | Property | Used to state that all resources related by one property are also related by another. Domain: rdf:Property, range: rdf:Property. Transitive |
| domain | Property | Used to state that any resource that has a given property is an instance of one or more classes. Domain: rdf:Property, range: rdfs:Class |
| range | Property | Used to state that the values of a property are instances of one or more classes. Domain: rdf:Property, range: rdfs:Class |
| label | Property | Used to provide a human-readable version of a resource's name. Domain: rdfs:Resource, range: rdfs:Literal |
| comment | Property | Used to provide a human-readable description of a resource. Domain: rdfs:Resource, range: rdfs:Literal |
| seeAlso | Property | Used to indicate a resource that might provide additional information about the subject resource. Domain: rdfs:Resource, range: rdfs:Resource |
| isDefinedBy | Property | Used to indicate a resource defining the subject resource. Domain: rdfs:Resource, range: rdfs:Resource. Subproperty of rdfs:seeAlso |
| member | Property | A super-property of all container membership properties. Domain: rdfs:Resource, range: rdfs:Resource |

### OWL 2 (Web Ontology Language)
Namespace: `http://www.w3.org/2002/07/owl#`

| Name | Type | Description |
|------|------|-------------|
| Thing | Class | The class of all individuals. Top class in the OWL 2 class hierarchy. Every OWL 2 class is a subclass of owl:Thing |
| Nothing | Class | The class that contains no individuals. Bottom class (equivalent to the empty set) |
| Class | Class | The class of OWL 2 classes (equivalent to rdfs:Class) |
| NamedIndividual | Class | The class of all named individuals |
| Annotation | Class | The class of all annotations |
| AnnotationProperty | Class | The class of all annotation properties |
| Ontology | Class | The class of all ontologies |
| OntologyProperty | Class | The class of all ontology properties |
| ObjectProperty | Class | The class of all object properties |
| DatatypeProperty | Class | The class of all datatype properties |
| FunctionalProperty | Class | The class of functional properties (at most one value per subject) |
| InverseFunctionalProperty | Class | The class of inverse-functional properties (at most one subject per value) |
| TransitiveProperty | Class | The class of transitive properties |
| SymmetricProperty | Class | The class of symmetric properties |
| AsymmetricProperty | Class | The class of asymmetric properties |
| ReflexiveProperty | Class | The class of reflexive properties |
| IrreflexiveProperty | Class | The class of irreflexive properties |
| Restriction | Class | The class of property restrictions |
| NegativePropertyAssertion | Class | Assertion that an individual does NOT have a specific property value |
| AllDifferent | Class | A group of individuals that are pairwise different |
| AllDisjointClasses | Class | A group of class expressions that are pairwise disjoint |
| AllDisjointProperties | Class | A group of property expressions that are pairwise disjoint |
| DataRange | Class | The class of all data ranges (deprecated in OWL 2, use rdfs:Datatype) |
| sameAs | Property | Relates two individuals that are the same |
| differentFrom | Property | Relates two individuals that are different |
| disjointWith | Property | Relates a class expression to another class expression with no common instances |
| equivalentClass | Property | Relates a class expression to another class expression that has the same instances |
| equivalentProperty | Property | Relates two properties that have the same domain and range |
| imports | Property | Used for importing other ontologies into a given ontology |
| backwardCompatibleWith | Property | Points to a prior version that is backward compatible |
| incompatibleWith | Property | Points to a version that is incompatible |
| versionInfo | Property | A string indicating version information |
| priorVersion | Property | Points to a prior version of the ontology |
| deprecated | Property | Indicates that an entity is deprecated |
| hasKey | Property | Defines a set of properties whose values uniquely identify an individual within a class |
| propertyChainAxiom | Property | Defines a property as a chain (composition) of other properties |
| propertyDisjointWith | Property | Relates two properties with no common domain-range pairs |
| unionOf | Property | Relates a class to a set of class expressions whose union forms the class |
| intersectionOf | Property | Relates a class to a set of class expressions whose intersection forms the class |
| complementOf | Property | Relates a class to the class of all individuals not in the given class |
| oneOf | Property | Relates a class to a set of individuals that exhausts the class |
| hasValue | Property | Value restriction: relates a property to a specific individual or literal |
| someValuesFrom | Property | Existential restriction: relates a property to a class such that at least one value must be an instance of that class |
| allValuesFrom | Property | Universal restriction: relates a property to a class such that all values must be instances of that class |
| hasSelf | Property | Self-restriction: indicates a class of individuals that are related to themselves via the property |
| onProperty | Property | Relates a restriction to the property it constrains |
| onClass | Property | Relates a cardinality restriction to the class restricting the values |
| onDataRange | Property | Relates a cardinality restriction to the data range restricting the values |
| onDatatype | Property | Relates a datatype restriction to the datatype |
| onProperties | Property | Relates a restriction to multiple properties |
| cardinality | Property | Exact cardinality restriction on a property |
| minCardinality | Property | Minimum cardinality restriction on a property |
| maxCardinality | Property | Maximum cardinality restriction on a property |
| qualifiedCardinality | Property | Qualified exact cardinality restriction |
| minQualifiedCardinality | Property | Qualified minimum cardinality restriction |
| maxQualifiedCardinality | Property | Qualified maximum cardinality restriction |
| inverseOf | Property | Relates a property to its inverse |
| annotatedProperty | Property | The property that determines the predicate of an annotated axiom or annotated annotation |
| annotatedSource | Property | The property that determines the subject of an annotated axiom or annotated annotation |
| annotatedTarget | Property | The property that determines the object of an annotated axiom or annotated annotation |
| assertionProperty | Property | The property that determines the predicate of a negative property assertion |
| sourceIndividual | Property | The subject of a positive or negative property assertion |
| targetIndividual | Property | The object (individual) in an object property assertion |
| targetValue | Property | The object (literal) in a data property assertion |
| topObjectProperty | Property | The property that relates each individual to every individual |
| bottomObjectProperty | Property | The property that no individual participates in |
| topDataProperty | Property | The property that relates each individual to every data value |
| bottomDataProperty | Property | The property that no individual is related to via any data value |
| members | Property | The property that determines the collection of members |
| distinctMembers | Property | The property that determines the collection of pairwise different individuals |
| withRestrictions | Property | The property that determines the set of facet-value pairs that define a datatype restriction |
| DataRange | Class | The class of all data ranges (deprecated in OWL 2, use rdfs:Datatype) |
