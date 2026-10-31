import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport
import Testing
@testable import RDFKitMacros

@Suite(.tags(.codeGeneration, .property))
struct PropertyGeneratorTests {
    let specs: [String: MacroSpec] = [
        "Ontology": MacroSpec(type: OntologyMacro.self),
        "OntologyBody": MacroSpec(type: OntologyBodyMacro.self),
    ]

    /// A property whose domain is a class of the same ontology is a
    /// requirement of that class's protocol.
    @Test func sameOntologyDomainIsAMember() {
        assertMacroExpansion(
            """
            @Ontology
            public struct RDF: Ontology {
                public var body: some Content {
                    Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#")

                    Class("List") {
                        Type(RDFS.Class)
                        SubClassOf(RDFS.Resource)
                        Label("List")
                        Comment("The class of RDF Lists.")
                    }

                    Property("first") {
                        Type(RDF.Property)
                        Domain(RDF.List)
                        Range(RDFS.Resource)
                        Label("first")
                        Comment("The first item in the subject RDF list.")
                    }
                }
            }
            """,
            expandedSource: """
            public struct RDF: Ontology {
                public var body: some Content {
                    @RDFCore.ContentBuilder func declarations() -> [any RDFCore.Content] {

                            RDFCore.Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#")

                            RDFCore.Class("List") {
                                RDFCore.Type(RDFS.Class.self)
                                RDFCore.SubClassOf(RDFS.Resource.self)
                                RDFCore.Label("List")
                                RDFCore.Comment("The class of RDF Lists.")
                            }

                            RDFCore.Property("first") {
                                RDFCore.Type(RDF.Property.self)
                                RDFCore.Domain(RDF.List.self)
                                RDFCore.Range(RDFS.Resource.self)
                                RDFCore.Label("first")
                                RDFCore.Comment("The first item in the subject RDF list.")
                            }
                    }
                    return declarations()
                }

                /// The class of RDF Lists.
                ///
                /// Label: List
                public protocol List: RDFS.Resource, AnyObject {
                    /// The first item in the subject RDF list.
                    ///
                    /// Label: first
                    var first: Values<any RDFS.Resource> {
                        get
                        set
                    }
                }
            }
            """,
            macroSpecs: specs,
            failureHandler: { Issue.record("\($0.message)") }
        )
    }

    /// A property whose domain is the root is its own protocol, inheriting
    /// its domain.
    @Test func rootDomainIsItsOwnProtocol() {
        assertMacroExpansion(
            """
            @Ontology
            public struct RDFS: Ontology {
                public var body: some Content {
                    Namespace("http://www.w3.org/2000/01/rdf-schema#")

                    Property("label") {
                        Type(RDF.Property)
                        Domain(RDFS.Resource)
                        Range(RDFS.Literal)
                        Label("label")
                        Comment("A human-readable name for the subject.")
                    }
                }
            }
            """,
            expandedSource: """
            public struct RDFS: Ontology {
                public var body: some Content {
                    @RDFCore.ContentBuilder func declarations() -> [any RDFCore.Content] {

                            RDFCore.Namespace("http://www.w3.org/2000/01/rdf-schema#")

                            RDFCore.Property("label") {
                                RDFCore.Type(RDF.Property.self)
                                RDFCore.Domain(RDFS.Resource.self)
                                RDFCore.Range(RDFS.Literal.self)
                                RDFCore.Label("label")
                                RDFCore.Comment("A human-readable name for the subject.")
                            }
                    }
                    return declarations()
                }

                /// A human-readable name for the subject.
                ///
                /// Label: label
                public protocol Label: RDFS.Resource {
                    /// A human-readable name for the subject.
                    ///
                    /// Label: label
                    var label: Values<any RDFS.Literal> {
                        get
                        set
                    }
                }
            }
            """,
            macroSpecs: specs,
            failureHandler: { Issue.record("\($0.message)") }
        )
    }

    /// rdf:type is the individual's conformance to its classes' protocols
    /// (D2), so it generates no requirement.
    @Test func rdfTypeIsConformance() {
        assertMacroExpansion(
            """
            @Ontology
            public struct RDF: Ontology {
                public var body: some Content {
                    Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#")

                    Property("type") {
                        Type(RDF.Property)
                        Domain(RDFS.Resource)
                        Range(RDFS.Class)
                        Label("type")
                        Comment("The subject is an instance of a class.")
                    }
                }
            }
            """,
            expandedSource: """
            public struct RDF: Ontology {
                public var body: some Content {
                    @RDFCore.ContentBuilder func declarations() -> [any RDFCore.Content] {

                            RDFCore.Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#")

                            RDFCore.Property("type") {
                                RDFCore.Type(RDF.Property.self)
                                RDFCore.Domain(RDFS.Resource.self)
                                RDFCore.Range(RDFS.Class.self)
                                RDFCore.Label("type")
                                RDFCore.Comment("The subject is an instance of a class.")
                            }
                    }
                    return declarations()
                }
            }
            """,
            macroSpecs: specs,
            failureHandler: { Issue.record("\($0.message)") }
        )
    }
}
