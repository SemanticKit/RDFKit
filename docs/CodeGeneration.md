# Code Generation Architecture

## The Fundamental Rule

Every class becomes a Swift protocol, and `rdfs:subClassOf` becomes protocol inheritance (D1). Every property becomes a requirement on its domain's protocol (D4). Individuals are not declared in Swift. They come from the RDF data and are instances of a generated final class that conforms to the protocols of their classes (D2, D3). No declaration becomes a struct, and there is no `Entity` type or `Metadata` descriptor.

The Swift is generated in two ways, from the same generators in `OntologyGeneration`:

- **From RDF documents.** `RDFTranslatorPlugin` runs `RDFTranslator` over a target's `.ttl` and `.rdf` files. This is how `RDFKit` gets RDF, RDFS and OWL (`Sources/RDFKit/{RDF,RDFS,OWL}`), and how FOAF and the Alice profile in `Tests/ParallelTests/Fixtures` are built.
- **From the DSL.** `@Ontology` reads the declarations in an ontology's `body` as syntax and generates the same protocols:

```swift
@Ontology
public struct RDFS: Ontology {
    public var body: some Content {
        Namespace("http://www.w3.org/2000/01/rdf-schema#")

        Class("Resource") {
            Type(RDFS.Class)
            Label("Resource")
            Comment("The class resource, everything.")
        }

        Class("Class") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Resource)
            Label("Class")
            Comment("The class of classes.")
        }
    }
}
```

generates

```swift
/// The class resource, everything.
///
/// Label: Resource
public protocol Resource {
}

/// The class of classes.
///
/// Label: Class
public protocol Class: RDFS.Resource, AnyObject {
}
```

The declarations carry no data at run time. `Content` is an empty protocol, and `Class`, `Property`, `Type`, `SubClassOf`, `Domain`, `Range`, `Label` and `Comment` exist only to be read by the macro.

## What the Semantics Decide

Nothing in the generators names a term. What each term is comes from the published semantics. `SemanticsEmitterPlugin` reads them from the W3C documents in `Sources/OntologyGeneration/W3C`:

- the RDFS entailment patterns of RDF 1.2 Semantics
- the OWL 2 RL rules
- the parts and class-extension tables of OWL 2 RDF-Based Semantics

`Schema` closes the statements under them, and `SwiftSchema` names the results in Swift:

- A term is a class when it is an instance of the class of classes. It is a property when it is an instance of the class of properties.
- The root is the class whose extension is the universe: `rdfs:Resource`, which `owl:Thing` equals. A class whose extension is empty, such as `owl:Nothing`, is `Never` (D7).
- `rdfs:Literal` and its subclasses are literal classes. Their members are Swift value types (D6), so their protocols do not inherit `AnyObject`. Every other class's protocol does, because its members are individuals.
- A property is functional when it is an instance of `owl:FunctionalProperty` (OWL 2 RL prp-fp).
- A property is an annotation property when it is an instance of `owl:AnnotationProperty`.
- A subproperty has its superproperty's domain and range (OWL 2 RL scm-dom2 and scm-rng2).

## Code Generation Flow

1. `RDFTranslator` reads a target's documents and those of the vocabularies it builds on (`--layer`). `@Ontology` reads the declarations in `body` instead.
2. `Schema` closes the statements under the published semantics.
3. For each class, `ClassGenerator` generates a protocol that inherits the protocols of its superclasses, or the root's when it states none (rdfs8).
4. For each property, `PropertyGenerator` generates a requirement typed by its range: `Values<any Range>` when it is many-valued, and `(any Range)?` when it is functional (D5).
   - When the domain is a class of the same ontology, the requirement is a member of that class's protocol.
   - When the domain is the root or a class of another ontology, the property gets its own protocol, which inherits its domain.
   - A property whose subjects are classes or properties, such as `rdfs:subClassOf` and `rdfs:domain`, has no requirement. Those triples come from the Swift declarations themselves.
5. Labels, comments and every other annotation property become DocC on the declaration (D8).
6. For each set of classes the data's individuals belong to, `RDFTranslator` generates one final class, such as `PersonIndividual: FOAF.Person, FOAF.Name, Encodable`. Its stored properties are the requirements of those protocols. The individuals are instances of it, created and linked once, so identity is `===` (D3).
7. A vocabulary also gets `ontology`, an `OntologyDescription` that encodes every statement of its documents back to RDF. The IRIs are derived from the declarations, not stored (rule 17).

## Example

FOAF's `foaf:Person` and `foaf:Agent` become:

```swift
public protocol Person: FOAF.SpatialThing, FOAF.Agent, AnyObject {
    var firstName: Values<any RDFS.Literal> { get set }
}

public protocol Agent: RDFS.Resource, AnyObject {
    var mbox: Values<any OWL.Thing> { get set }
    var gender: (any RDFS.Literal)? { get set }
}
```

Alice and Bob in `alice.ttl` become instances:

```swift
public final class PersonIndividual: FOAF.Person, FOAF.Name, Encodable { … }

nonisolated(unsafe) public let (alice, bob): (PersonIndividual, PersonIndividual) = {
    let alice = PersonIndividual()
    let bob = PersonIndividual()
    alice.knows = [bob]
    bob.knows = [alice]
    return (alice, bob)
}()
```
