import SwiftSyntaxMacrosGenericTestSupport
import Testing

@Suite("@Ontology named individuals", .tags(.generated))
struct IndividualMacroTests {
    @Test("An Individual becomes the one instance of a class of its own that conforms to its classes' storing protocols and carries its declared key")
    func individualBecomesAnInstanceOfItsClasses() {
        assertExpansion(
            """
            @Ontology
            public struct Zoo: Ontology {
                public var body: some Content {
                    Namespace("https://zoo.example.org/#")
                    Class("Animal")
                    Individual("tweety") {
                        Type(Zoo.Animal)
                        Type(FOAF.Agent)
                    }
                }
            }
            """,
            expandedSource: """

            public struct Zoo: Ontology {
                public var body: some Content {
                    #sourceLocation(file: "test.swift", line: 4)
                    RDFCore.Namespace("https://zoo.example.org/#")
                    #sourceLocation(file: "test.swift", line: 5)
                    RDFCore.Class("Animal")
                    #sourceLocation(file: "test.swift", line: 6)
                    RDFCore.Individual("tweety") {


                            }
                    #sourceLocation()
                }

                public protocol Animal: RDF.Resource {
                }

                /// A member of ``Zoo/Animal`` that keeps its property values in an
                /// ``RDFCore/IndividualStorage``. An individual typed with the class, in
                /// any module, conforms to it.
                public protocol AnimalStoring: Zoo.Animal, RDF.ResourceStoring {
                }

                public final class AnimalIndividual: Zoo.AnimalStoring, RDFCore.ResourceClass {
                    public static let classKey: RDFCore.TermKey? = RDFCore.TermKey("Animal", in: Zoo.self)

                    public static let classes: [any RDFCore.ResourceClass.Type] = [Zoo.AnimalIndividual.self]

                    /// A member of the class as a property value.
                    public typealias Member = any Zoo.Animal

                    public let storage = RDFCore.IndividualStorage()

                    /// A member of the class that no declaration names: a blank node at the boundary.
                    public init() {
                    }

                    public static func encodeDescription(to encoder: any Encoder) throws {
                        _ = encoder.container(keyedBy: RDFCore.PropertyKey.self)
                    }
                }

                public var tweety: Zoo.tweetyIndividual {
                    Zoo.tweetyIndividual.individual
                }

                /// The class of the named individual ``Zoo/tweety``.
                public final class tweetyIndividual: Zoo.AnimalStoring, FOAF.AgentStoring, RDFCore.PropertyValueStoring {
                    public static let key: RDFCore.TermKey? = RDFCore.TermKey("tweety", in: Zoo.self)

                    public static let classes: [any RDFCore.ResourceClass.Type] = [Zoo.AnimalIndividual.self, FOAF.AgentIndividual.self]

                    public let storage = RDFCore.IndividualStorage()

                    /// The individual, the one instance of its class.
                    static let individual = Zoo.tweetyIndividual()

                    private init() {
                    }
                }

                /// The descriptions of the terms this ontology declares.
                ///
                /// Encoding them gives the ontology's graph:
                ///
                ///     let document = try TurtleEncoder().encode(Zoo().ontology)
                public var ontology: [any RDFCore.Description] {
                    [
                        RDFCore.ClassDescription(Zoo.AnimalIndividual.self),
                        tweety,
                    ]
                }

                /// The namespace this ontology's terms are declared in, from which an
                /// encoder derives each term's IRI.
                public static let namespace = "https://zoo.example.org/#"
            }
            """
        )
    }

    /// The expansion of an ontology whose one declaration is `Individual("tweety")` with no `Type`.
    static let withoutType = """

        struct Zoo: Ontology {
            var body: some Content {
                #sourceLocation(file: "test.swift", line: 4)
                RDFCore.Namespace("https://zoo.example.org/#")
                #sourceLocation(file: "test.swift", line: 5)
                RDFCore.Individual("thing")
                #sourceLocation()
            }

            var thing: Zoo.thingIndividual {
                Zoo.thingIndividual.individual
            }

            /// The class of the named individual ``Zoo/thing``.
            final class thingIndividual: RDFCore.PropertyValueStoring {
                static let key: RDFCore.TermKey? = RDFCore.TermKey("thing", in: Zoo.self)

                static let classes: [any RDFCore.ResourceClass.Type] = []

                let storage = RDFCore.IndividualStorage()

                /// The individual, the one instance of its class.
                static let individual = Zoo.thingIndividual()

                private init() {
                }
            }

            /// The descriptions of the terms this ontology declares.
            ///
            /// Encoding them gives the ontology's graph:
            ///
            ///     let document = try TurtleEncoder().encode(Zoo().ontology)
            var ontology: [any RDFCore.Description] {
                [
                    thing,
                ]
            }

            /// The namespace this ontology's terms are declared in, from which an
            /// encoder derives each term's IRI.
            static let namespace = "https://zoo.example.org/#"
        }
        """

    @Test("An Individual with no Type is a member of no stated class")
    func individualWithoutTypeHasNoClasses() {
        assertExpansion(
            """
            @Ontology
            struct Zoo: Ontology {
                var body: some Content {
                    Namespace("https://zoo.example.org/#")
                    Individual("thing")
                }
            }
            """,
            expandedSource: Self.withoutType
        )
    }

    @Test("An Individual whose class name a declared term already has is reported where it was written")
    func individualTypeCollisionIsReported() {
        assertExpansion(
            """
            @Ontology
            struct Zoo: Ontology {
                var body: some Content {
                    Namespace("https://zoo.example.org/#")
                    Class("tweetyIndividual")
                    Individual("tweety")
                }
            }
            """,
            expandedSource: """

            struct Zoo: Ontology {
                var body: some Content {
                    #sourceLocation(file: "test.swift", line: 4)
                    RDFCore.Namespace("https://zoo.example.org/#")
                    #sourceLocation(file: "test.swift", line: 5)
                    RDFCore.Class("tweetyIndividual")
                    #sourceLocation(file: "test.swift", line: 6)
                    RDFCore.Individual("tweety")
                    #sourceLocation()
                }

                protocol tweetyIndividual: RDF.Resource {
                }

                /// A member of ``Zoo/tweetyIndividual`` that keeps its property values in an
                /// ``RDFCore/IndividualStorage``. An individual typed with the class, in
                /// any module, conforms to it.
                protocol tweetyIndividualStoring: Zoo.tweetyIndividual, RDF.ResourceStoring {
                }

                final class tweetyIndividualIndividual: Zoo.tweetyIndividualStoring, RDFCore.ResourceClass {
                    static let classKey: RDFCore.TermKey? = RDFCore.TermKey("tweetyIndividual", in: Zoo.self)

                    static let classes: [any RDFCore.ResourceClass.Type] = [Zoo.tweetyIndividualIndividual.self]

                    /// A member of the class as a property value.
                    typealias Member = any Zoo.tweetyIndividual

                    let storage = RDFCore.IndividualStorage()

                    /// A member of the class that no declaration names: a blank node at the boundary.
                    init() {
                    }

                    static func encodeDescription(to encoder: any Encoder) throws {
                        _ = encoder.container(keyedBy: RDFCore.PropertyKey.self)
                    }
                }

                /// The descriptions of the terms this ontology declares.
                ///
                /// Encoding them gives the ontology's graph:
                ///
                ///     let document = try TurtleEncoder().encode(Zoo().ontology)
                var ontology: [any RDFCore.Description] {
                    [
                        RDFCore.ClassDescription(Zoo.tweetyIndividualIndividual.self),
                    ]
                }

                /// The namespace this ontology's terms are declared in, from which an
                /// encoder derives each term's IRI.
                static let namespace = "https://zoo.example.org/#"
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "'tweetyIndividual' is declared in this ontology, so the individual type of 'tweety' cannot use that name", line: 6, column: 9),
            ]
        )
    }

    @Test("An Individual's expansion holds no IRI: its key is its declared name in its ontology")
    func individualExpansionHoldsNoIRI() {
        let source = """
            @Ontology
            struct Zoo: Ontology {
                var body: some Content {
                    Namespace("https://zoo.example.org/#")
                    Individual("thing")
                }
            }
            """
        assertExpansion(source, expandedSource: Self.withoutType)
        #expect(!Self.withoutType.contains("iri"))
        #expect(Self.withoutType.contains("RDFCore.TermKey(\"thing\", in: Zoo.self)"))
    }
}
