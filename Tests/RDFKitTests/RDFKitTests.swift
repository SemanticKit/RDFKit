import Testing
import IRIKit
import FOAF
import RDF
import RDFCore
import RDFFormats
import RDFKit

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
            Range(RDF.Literal)
        }
        Property("sponsor") {
            Domain(Club.Member)
            Range(FOAF.Person)
        }
    }
}

@Suite("One runtime for the DSL and the translator", .tags(.ontology, .generated))
struct RDFKitTests {
    /// `Club.Member rdfs:subClassOf foaf:Person`: a member of the DSL class is
    /// a member of the translated class, with its properties, and its
    /// values are the individuals themselves.
    @Test func dslClassesRefineTranslatedClasses() {
        let carol = Club.MemberIndividual(iri: "https://club.example.org/#carol")
        let dave = Club.MemberIndividual(iri: "https://club.example.org/#dave")
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
        let carol = Club.MemberIndividual(iri: "https://club.example.org/#carol")
        carol.name = ["Carol"]
        carol.joined = [try Literal("2026", datatype: "http://www.w3.org/2001/XMLSchema#gYear")]
        let person = FOAF.PersonIndividual(iri: "https://club.example.org/#erin")
        person.name = ["Erin"]
        carol.knows = [person]
        let stored: [any RDFCore.PropertyValueStoring] = [carol, person]
        #expect(stored.count == 2)

        let output = try NTriplesDecoder().decode(try NTriplesEncoder().encode([carol, person]))
        let expected = try TurtleDecoder().decode("""
            @prefix foaf: <http://xmlns.com/foaf/0.1/> .
            @prefix club: <https://club.example.org/#> .
            @prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
            club:carol a club:Member ; foaf:name "Carol" ; club:joined "2026"^^xsd:gYear ; foaf:knows club:erin .
            club:erin a foaf:Person ; foaf:name "Erin" .
            """)
        #expect(output == expected, "\(output)")
    }

    /// An individual with no IRI is a blank node at the boundary: the encoder
    /// gives it one, and describes it where it is reached.
    @Test func individualsWithoutIRIAreBlankNodes() throws {
        let carol = Club.MemberIndividual(iri: "https://club.example.org/#carol")
        let anonymous = Club.MemberIndividual()
        anonymous.name = ["Someone"]
        carol.knows = [anonymous]
        let output = try NTriplesDecoder().decode(try NTriplesEncoder().encode([carol]))
        let expected = try TurtleDecoder().decode("""
            @prefix foaf: <http://xmlns.com/foaf/0.1/> .
            @prefix club: <https://club.example.org/#> .
            club:carol a club:Member ; foaf:knows [ a club:Member ; foaf:name "Someone" ] .
            """)
        #expect(output.isIsomorphic(to: expected), "\(output)")
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

    /// The RDFKit vocabulary is declared in the DSL on the same runtime: a
    /// prefix is a resource with `rdfs:label`, since every class refines
    /// `rdfs:Resource`.
    @Test func rdfKitVocabularyIsOnTheSameRuntime() throws {
        let prefix = RDFKit.PrefixIndividual()
        prefix.id = ["foaf"]
        prefix.label = ["FOAF"]
        let output = try GraphEncoder().encode(prefix)
        #expect(output.count == 3)
        #expect(output.contains { $0.predicate == "http://semantickit.io/o/2026/06/rdfkit#id" && $0.object == .literal("foaf") })
    }
}
