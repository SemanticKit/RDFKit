# RDFKit

RDF and Swift, as one runtime, both ways.

## What This Is

RDF goes in, you build, and Swift comes out as the things the RDF describes. FOAF's `index.rdf` gives the protocols `Person` and `Agent`, the property `knows`, and Alice's profile gives `alice`, a `Person`:

```swift
import AliceProfile
import FOAF

alice is Person                      // :alice a foaf:Person
alice is Agent                       // foaf:Person rdfs:subClassOf foaf:Agent
alice.knows.contains { $0 === bob }  // the values are the individuals themselves
```

`rdf.ttl`, `rdfs.ttl` and `owl.ttl` go through the same translation, into the modules `RDF` and `OWL`. Swift goes back to RDF through the same encoders for every individual:

```swift
let document = try TurtleEncoder().encode([alice, bob])
```

Vocabularies can also be written in Swift with the DSL. `@Ontology` generates the same Swift the translator writes, on the same runtime, and builds on the translated vocabularies:

```swift
import FOAF
import IRIKit
import RDF
import RDFCore
import RDFKit

@Ontology
public struct Club: Ontology {
    public var body: some Content {
        Namespace("https://club.example.org/#")
        Class("Member") {
            Type(RDF.Class)
            SubClassOf(FOAF.Person)
            Comment("A person who belongs to the club.")
        }
        Property("joined") {
            Domain(Club.Member)
            Range(RDF.Literal)
        }
    }
}
```

Related terms are written as their types: `SubClassOf(FOAF.Person)`, `Range(RDF.Literal)`. A class is a protocol, a storing protocol and a final class whose instances are its members (`Club.MemberIndividual`); a property is a requirement of its domain's protocol, typed by the `Member` of its range's class.

## Targets

- **RDFCore** — the RDF 1.2 data model at the boundary (`Graph`, `Triple`, `Literal`, `BlankNode`, `Dataset`, isomorphism), the runtime every individual uses (`Resource`, `ResourceClass`, `IndividualStorage`, `PropertyValue`, `PropertyKey`), and the DSL forms (`Class`, `Property`, `Label`, ...).
- **RDFFormats** — the coders: `NTriplesDecoder`/`NTriplesEncoder`, `TurtleDecoder`/`TurtleEncoder`, `RDFXMLDecoder`/`RDFXMLEncoder`, and `GraphEncoder`, which turns individuals into a `Graph` through their `Encodable` conformance. Checked against the W3C RDF 1.2 test suites (`Scripts/fetch-w3c-rdf-tests.sh` refreshes them), decoding and round-tripping by isomorphism.
- **RDFTranslatorPlugin** — a build tool plugin that runs **RDFTranslator** over a target's RDF documents (`.ttl`, `.nt`, `.rdf`) and writes the Swift they describe. A target's dependencies are the layers it builds on.
- **RDF** and **OWL** — rdf.ttl with rdfs.ttl, and owl.ttl, translated by the plugin.
- **RDFKit** — the `@Ontology` macro and the RDFKit vocabulary, declared with it.

## Design Rules

`docs/DslInvariants.md` holds the rules of the DSL. The essential ones:

- **The type is the identity.** Inside the runtime, terms refer to each other as Swift types; an individual is an object. IRIs exist only at the boundary: the encoders and decoders.
- **One runtime.** DSL-declared and translated individuals are the same kind of `Resource`, keep their values in an `IndividualStorage` as typed Swift values, and encode through the same encoders.
- **A named individual is a module-level value** (`alice`), never a static member of an ontology type.
- **`var body`, as in SwiftUI**, and related terms by inference: `Domain(Fauna.Animal)`.
