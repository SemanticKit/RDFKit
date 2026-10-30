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
- **RDFFormats** — the coders: `NTriplesDecoder`/`NTriplesEncoder`, `TurtleDecoder`/`TurtleEncoder`, `RDFXMLDecoder`/`RDFXMLEncoder`, `GraphEncoder`, which turns individuals into a `Graph` through their `Encodable` conformance, and `GraphDecoder`, which turns a `Graph` back into the individuals it describes, typed by the Swift classes it is given. A `DocumentContext` holds each decoded individual's IRI, never the individual, so encoding with it gives back the document's IRIs. Checked against the W3C RDF 1.2 test suites (`Scripts/fetch-w3c-rdf-tests.sh` refreshes them), decoding and round-tripping by isomorphism.
- **RDFTranslatorPlugin** — a build tool plugin that runs **RDFTranslator** over a target's RDF documents (`.ttl`, `.nt`, `.rdf`) and writes the Swift they describe. A target's dependencies are the layers it builds on.
- **XSD** — the XSD datatypes RDF uses (RDF 1.2 Concepts §5.1), each a Swift value type built from its lexical form, with the value space, lexical-to-value mapping and canonical mapping of XML Schema 1.1 Part 2: `XSD.integer`, `XSD.dateTime`, `XSD.duration`. **XSDTranslatorPlugin** runs **XSDTranslator** over the W3C documents in `Sources/XSD/W3C` (the datatypes schema, the built-in definitions and RDF 1.2 Concepts) for the datatypes, their hierarchy (`typealias Base`) and facets; **XSDDefinitions** reads the documents for both translators, and the generated Swift is built with swift-syntax. A property whose range is one of them holds its value type: the value each literal denotes in the range, in whatever form and related datatype it is written, which writes back as that literal. A literal that denotes none (ill-typed, of a datatype with no Swift type, or outside the range) stays a literal (`PropertyLiterals`) until Swift sets the property.
- **RDF** and **OWL** — rdf.ttl with rdfs.ttl, and owl.ttl, translated by the plugin.
- **RDFKit** — the `@Ontology` macro and the RDFKit vocabulary, declared with it.

## Design Rules

The rules of the DSL:

- **The type is the identity.** Inside the runtime, terms refer to each other as Swift types; an individual is an object. IRIs exist only at the boundary: the encoders and decoders.
- **One runtime.** DSL-declared and translated individuals are the same kind of `Resource`, keep their values in an `IndividualStorage` as typed Swift values, and encode through the same encoders.
- **No stored or declared IRI.** Each class, property and named individual carries its declared key (`TermKey`: its declared name and its vocabulary), as a `Codable` type carries its `CodingKeys`. The encoders derive the IRI from the key and the vocabulary's namespace; an individual made in Swift that no declaration names is a blank node, and one decoded from a document is written with its document's IRI only by an encoder given the decoder's `DocumentContext`. A property is never a module-level value: it is a requirement on its domains' protocols, a member of the individuals that have it, and a term type that carries its key (`FOAF.knows.key`).
- **A named individual is never a static member of an ontology type.** A translated one is a module-level value (`alice`); `Individual("tweety") { Type(Fauna.Bird) }` in an `@Ontology` body (`owl:NamedIndividual`) is the ontology member `Fauna().tweety`.
- **`var body`, as in SwiftUI**, and related terms by inference: `Domain(Fauna.Animal)`.
