# RDFKit Architecture Spec

## Vision

Define an ontology once, in its published RDF documents or in the Swift DSL. At build time, RDFKit translates it into real Swift types under the published semantics of RDF and OWL. Those types are what users build with.

Swift becomes the new OWL-like language. Protocols carry the class hierarchy. The type system does the work.

---

## Architecture Layers (Ordered by Necessity)

### Layer 1: Standards (Source of Truth)

The RDF/RDFS/OWL standards define everything. We don't invent — we implement.

| Standard | Namespace | Purpose |
|----------|-----------|---------|
| RDF 1.2 | `http://www.w3.org/1999/02/22-rdf-syntax-ns#` | Core data model — what things ARE |
| RDFS 1.2 | `http://www.w3.org/2000/01/rdf-schema#` | Schema vocabulary — how things RELATE |
| OWL 2 | `http://www.w3.org/2002/07/owl#` | Ontology language — how things BEHAVE |

The vocabularies are their published documents (`rdf.ttl`, `rdfs.ttl`, `owl.ttl`), stored unedited. Their semantics are read from the W3C documents themselves: the RDFS entailment patterns of RDF 1.2 Semantics, the OWL 2 RL rules of OWL 2 Profiles, and the parts and class extensions of OWL 2 RDF-Based Semantics.

### Layer 2: RDFCore (The Data Model at the Boundary)

- `Graph`, `Dataset`, `Triple`, `SubjectTerm`, `ObjectTerm`, `Literal`, `BlankNode` — the RDF 1.2 abstract syntax, with isomorphism
- `IRI` — identity of terms (from IRIKit)
- `Values` — the set of a many-valued property's values (D5)
- `Ontology`, `Content`, `ContentBuilder` — what a vocabulary declared in Swift conforms to

`Literal` is used only at the boundary, where documents are read and written (rule 20).

### Layer 3: Semantics (OntologyGeneration)

`Schema` closes a vocabulary's statements, and those of the vocabularies it builds on, under the published semantics. What each term is comes from what they entail: a class, a property, the root, an empty class, a literal class, a functional property or an annotation property. Nothing in the generators names a term.

### Layer 4: Code Generation (RDFTranslator and @Ontology)

`RDFTranslatorPlugin` runs `RDFTranslator` over a target's `.ttl` and `.rdf` documents. `@Ontology` reads a Swift ontology's `body` as syntax. Both use `ClassGenerator` and `PropertyGenerator`:

1. Each class generates a protocol, and `rdfs:subClassOf` is protocol inheritance (D1).
2. Each property generates a requirement on its domain's protocol, typed by its range (D4). A many-valued property is `Values<any Range>`, and a functional one is `(any Range)?` (D5).
3. Annotations generate DocC (D8).
4. The individuals in the data generate one final class per set of classes they belong to, which conforms to those classes' protocols (D2). The individuals are its instances, and their identity is the object's (D3).

### Layer 5: Generated Types (What Users Interact With)

- Protocols for classes, such as `FOAF.Person`, nested in a namespace when a module holds several vocabularies (`RDFS.Class`)
- Requirements for properties, such as `alice.knows`
- Individuals, such as `alice` and `bob`, instances of `PersonIndividual`
- `ontology`, which encodes the vocabulary's statements back to RDF, with IRIs derived from the declarations (rule 17)

---

## Protocol-Oriented Architecture

Every class in the standards has meaning, and that meaning is a protocol.

### How It Works
1. The documents declare a class and what it is a subclass of.
2. The class becomes a protocol that inherits its superclasses' protocols, so a class with several superclasses inherits several protocols.
3. The root, `rdfs:Resource`, which `owl:Thing` equals, is the protocol every other one inherits (D7). `owl:Nothing` is `Never`.
4. Classes whose members are individuals inherit `AnyObject`, so `===` is identity. Literal classes don't, because their members are Swift value types (D6).
5. An individual's class conforms to the protocols of all its classes (D2).

---

## Core API Surface

### What RDFCore Provides

- The RDF 1.2 data model: `Graph`, `Dataset`, `Triple`, `SubjectTerm`, `ObjectTerm`, `Literal`, `BlankNode`
- `Values`, set semantics with `===` identity for individuals and `==` for literal values
- `Ontology`, `Content`, `ContentBuilder`, for vocabularies declared in Swift

### What RDFCore Does NOT Provide

- Code generation (that's OntologyGeneration, RDFTranslator and RDFKitMacros)
- The vocabularies (that's RDFKit, generated from their documents)
- Formats (that's RDFFormats)

### Type Conformances

The data model's types conform to the standard Swift protocols that fit them:

- `Graph`: `SetAlgebra`, `RandomAccessCollection`, `Hashable`, `Sendable`, `CustomStringConvertible`
- `Literal`, `BlankNode`: `Hashable`, `Sendable`, `Comparable`, `CustomStringConvertible`

A generated individual's class is `Encodable`. It is not `Hashable` or `Equatable`, because its identity is the object's (D3).

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

Use the Swift 6.4 features the sources of truth in `CLAUDE.md` give, where they fit:

- **Protocols and protocol inheritance** for classes and the class hierarchy (D1)
- **Existentials** (`any FOAF.Person`) for the range of a property
- **Classes** (`final class`) for individuals, whose identity is the object's (D3)
- **Value types** for literals: the XSD datatypes (D6)
- **Macros** (`@Ontology`) for vocabularies declared in Swift
- **Build tool plugins** for vocabularies in RDF documents (`RDFTranslatorPlugin`)
- **SwiftSyntaxBuilder** for all generated Swift (rule 16)
- **`Sendable`** throughout

---

## What Describes vs What Defines

**RDF side (describes):**
- `foaf:Person rdf:type rdfs:Class` — Person is a class
- `foaf:Person rdfs:subClassOf foaf:Agent` — Person is a subclass of Agent
- `foaf:knows rdfs:domain foaf:Person` — knows has Person as domain
- `foaf:knows rdfs:range foaf:Person` — knows has Person as range

**Swift side (defines):**
- `protocol Person: FOAF.Agent` — the class and its superclass
- `var knows: Values<any FOAF.Person>` on `Person` — the property, its domain and its range
- `final class PersonIndividual: FOAF.Person` — the individuals' class

---

## Module Split

- **RDFCore** = the data model at the boundary, `Values`, `Ontology`
- **RDFKit** = RDF, RDFS, OWL, and the `@Ontology` DSL
- **OntologyGeneration** = the semantics and the generators
- **RDFTranslator** = RDF documents to Swift
- **RDFFormats** = N-Triples, Turtle, RDF/XML
- **XSD** = the XML Schema datatypes

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
