import Testing
import IRIKit
import AliceProfile
import FOAF
import OWL
import RDF
import RDFCore
import RDFFormats
import RDFKit
import XSD

/// A club whose members are FOAF people: a class declared in the DSL that
/// refines a class translated from RDF.
@Ontology
struct Club: Ontology {
    var body: some Content {
        Namespace("https://club.example.org/#")
        Class("Member") {
            Type(RDF.Class)
            SubClassOf(FOAF.Person)
            Label("Member")
            Comment("A person who belongs to the club.")
        }
        Property("joined") {
            Domain(Club.Member)
            Range(XSD.gYear)
        }
        Property("nickname") {
            Domain(Club.Member)
            Range(XSD.string)
            Deprecated()
        }
        Property("sponsor") {
            Type(RDF.Property)
            Domain(Club.Member)
            Range(FOAF.Person)
            Label("sponsor")
            Comment("The person who sponsored the member.")
        }
    }
}

/// The club's members: named individuals (`owl:NamedIndividual`) of the
/// club's and FOAF's classes, declared in the DSL.
@Ontology
struct ClubMembers: Ontology {
    var body: some Content {
        Namespace("https://club.example.org/#")
        Individual("carol") { Type(Club.Member) }
        Individual("dave") { Type(Club.Member) }
        Individual("frank") { Type(Club.Member) }
        Individual("erin") { Type(FOAF.Person) }
        Individual("grace") { Type(Club.Member) }
        Individual("heidi") { Type(Club.Member) }
    }
}

@Suite("One runtime for the DSL and the translator", .tags(.ontology, .generated))
struct RDFKitTests {
    /// `Club.Member rdfs:subClassOf foaf:Person`: a member of the DSL class is
    /// a member of the translated class, with its properties, and its
    /// values are the individuals themselves.
    @Test func dslClassesRefineTranslatedClasses() {
        let carol = ClubMembers().carol
        let dave = ClubMembers().dave
        carol.name = ["Carol"]
        carol.knows = [dave]
        carol.sponsor = [dave]
        #expect((carol as AnyObject) is any FOAF.Person)
        #expect((carol as AnyObject) is any FOAF.Agent)
        #expect(carol.knows.contains { $0 === dave })
        #expect(carol.sponsor.first === dave)
        #expect(carol.name == ["Carol"])
    }

    /// A DSL individual and a translated one are the same kind of resource:
    /// each keeps its values in an ``RDFCore/IndividualStorage``, and each
    /// encodes through the same encoder.
    @Test func dslAndTranslatedIndividualsEncodeTheSameWay() throws {
        let expected = try TurtleDecoder().decode("""
            @prefix foaf: <http://xmlns.com/foaf/0.1/> .
            @prefix club: <https://club.example.org/#> .
            @prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
            club:frank a club:Member ; foaf:name "Frank" ; club:joined "2026"^^xsd:gYear ; foaf:knows club:erin .
            club:erin a foaf:Person ; foaf:name "Erin" .
            """)
        let frank = ClubMembers().frank
        frank.name = ["Frank"]
        // `Range(XSD.gYear)`: the values are `xsd:gYear` values, decoded
        // from the document's literal at the boundary.
        let joined: [XSD.gYear] = try expected.compactMap { triple in
            guard triple.predicate == IRI(Club.joined.key), case .literal(let literal) = triple.object else { return nil }
            return try XSD.gYear(literal)
        }
        frank.joined = joined
        #expect(frank.joined.count == 1)
        #expect(frank.joined.first?.value.year?.int == 2026)
        let person = ClubMembers().erin
        person.name = ["Erin"]
        frank.knows = [person]
        let stored: [any RDFCore.PropertyValueStoring] = [frank, person]
        #expect(stored.count == 2)

        let output = try NTriplesDecoder().decode(try NTriplesEncoder().encode([frank, person]))
        #expect(output == expected, "\(output)")
    }

    /// An individual made in Swift that no declaration names is a blank node
    /// at the boundary: the encoder gives it one, and describes it where it
    /// is reached.
    @Test func undeclaredIndividualsAreBlankNodes() throws {
        let grace = ClubMembers().grace
        let anonymous = Club.MemberIndividual()
        anonymous.name = ["Someone"]
        grace.knows = [anonymous]
        let output = try NTriplesDecoder().decode(try NTriplesEncoder().encode([grace]))
        let expected = try TurtleDecoder().decode("""
            @prefix foaf: <http://xmlns.com/foaf/0.1/> .
            @prefix club: <https://club.example.org/#> .
            club:grace a club:Member ; foaf:knows [ a club:Member ; foaf:name "Someone" ] .
            """)
        #expect(output.isIsomorphic(to: expected), "\(output)")
    }

    /// A declared individual is one individual: every value of the ontology
    /// type gives the same instance.
    @Test func declaredIndividualsAreOneInstance() {
        #expect(ClubMembers().dave === ClubMembers().dave)
    }

    /// A declared individual whose key does not give an IRI is an encoding
    /// error, in subject and in object position, never a blank node.
    @Test func invalidDeclaredKeysAreEncodingErrors() throws {
        let misnamed = MisnamedIndividual()
        #expect(throws: EncodingError.self) { try GraphEncoder().encode(misnamed) }
        #expect(throws: EncodingError.self) { try GraphEncoder().encode(Referrer(value: misnamed)) }
    }

    /// A DSL class writes its own description, as a translated class does.
    @Test func dslClassesDescribeThemselves() throws {
        let output = try GraphEncoder().encode(ClassDescription(Club.MemberIndividual.self))
        let expected = try TurtleDecoder().decode("""
            @prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
            @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
            @prefix foaf: <http://xmlns.com/foaf/0.1/> .
            <https://club.example.org/#Member> a rdfs:Class ;
                rdfs:subClassOf foaf:Person ;
                rdfs:label "Member" ;
                rdfs:comment "A person who belongs to the club." .
            """)
        #expect(output == expected, "\(output)")
    }

    /// A DSL vocabulary encodes back to RDF, as a translated one does: its
    /// classes and properties write what they are declared with, and the
    /// Turtle decodes to the equivalent graph.
    @Test func dslVocabularyRoundTrips() throws {
        let turtle = try TurtleEncoder().encode(Club().ontology)
        let output = try TurtleDecoder().decode(turtle)
        let expected = try TurtleDecoder().decode("""
            @prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
            @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
            @prefix owl: <http://www.w3.org/2002/07/owl#> .
            @prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
            @prefix foaf: <http://xmlns.com/foaf/0.1/> .
            @prefix club: <https://club.example.org/#> .
            club:Member a rdfs:Class ;
                rdfs:subClassOf foaf:Person ;
                rdfs:label "Member" ;
                rdfs:comment "A person who belongs to the club." .
            club:joined rdfs:domain club:Member ; rdfs:range xsd:gYear .
            club:nickname rdfs:domain club:Member ; rdfs:range xsd:string ; owl:deprecated true .
            club:sponsor a rdf:Property ;
                rdfs:domain club:Member ;
                rdfs:range foaf:Person ;
                rdfs:label "sponsor" ;
                rdfs:comment "The person who sponsored the member." .
            """)
        #expect(output.isIsomorphic(to: expected), "\(turtle)")
    }

    /// The RDFKit vocabulary is declared in the DSL on the same runtime: a
    /// prefix is a resource with `rdfs:label`, since every class refines
    /// `rdfs:Resource`.
    @Test func rdfKitVocabularyIsOnTheSameRuntime() throws {
        let prefix = RDFKit.PrefixIndividual()
        prefix.id = ["foaf"]
        prefix.label = ["FOAF"]
        let output = try GraphEncoder().encode(prefix)
        #expect(output.count == 3)
        #expect(output.contains { $0.predicate == IRI(RDFKit.id.key) && $0.object == .literal("foaf") })
    }

    /// Every individual, declared in the DSL, typed across vocabularies or
    /// translated from RDF, encodes through each format's encoder, and the
    /// documents decode to the same graph.
    @Test func everyIndividualEncodesThroughEveryFormat() throws {
        let heidi = ClubMembers().heidi
        heidi.name = ["Heidi"]
        heidi.knows = [FOAF.PersonIndividual()]
        let individuals: [any RDFCore.Description] = [heidi, alice, bob]
        let graph = try GraphEncoder().encode(individuals)
        let nTriples = try NTriplesDecoder().decode(try NTriplesEncoder().encode(individuals))
        let turtle = try TurtleDecoder().decode(try TurtleEncoder().encode(individuals))
        let rdfXML = try RDFXMLDecoder().decode(try RDFXMLEncoder().encode(individuals))
        #expect(graph.count == 10)
        #expect(nTriples.isIsomorphic(to: graph))
        #expect(turtle.isIsomorphic(to: graph))
        #expect(rdfXML.isIsomorphic(to: graph))
    }
}

/// An individual declared with a name that is not an IRI in its namespace.
private final class MisnamedIndividual: RDFCore.Resource {
    static var key: TermKey? { TermKey("my bob", in: Club.self) }
    func encode(to encoder: any Encoder) throws {}
}

/// An undeclared individual whose one value is `value`.
private final class Referrer: RDFCore.Resource {
    let value: any RDFCore.Resource
    init(value: any RDFCore.Resource) { self.value = value }
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: PropertyKey.self)
        try container.encode([value], for: PropertyKey(FOAF.knowsValue.key))
    }
}
