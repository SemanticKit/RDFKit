import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport
import Testing
@testable import RDFKitMacros
import OntologyGeneration

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

                            RDFKit.Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#")

                            RDFKit.Class("List") {
                                RDFKit.Type(RDFS.Class.self)
                                RDFKit.SubClassOf(RDFS.Resource.self)
                                RDFKit.Label("List")
                                RDFKit.Comment("The class of RDF Lists.")
                            }

                            RDFKit.Property("first") {
                                RDFKit.Type(RDF.Property.self)
                                RDFKit.Domain(RDF.List.self)
                                RDFKit.Range(RDFS.Resource.self)
                                RDFKit.Label("first")
                                RDFKit.Comment("The first item in the subject RDF list.")
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

                            RDFKit.Namespace("http://www.w3.org/2000/01/rdf-schema#")

                            RDFKit.Property("label") {
                                RDFKit.Type(RDF.Property.self)
                                RDFKit.Domain(RDFS.Resource.self)
                                RDFKit.Range(RDFS.Literal.self)
                                RDFKit.Label("label")
                                RDFKit.Comment("A human-readable name for the subject.")
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

                            RDFKit.Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#")

                            RDFKit.Property("type") {
                                RDFKit.Type(RDF.Property.self)
                                RDFKit.Domain(RDFS.Resource.self)
                                RDFKit.Range(RDFS.Class.self)
                                RDFKit.Label("type")
                                RDFKit.Comment("The subject is an instance of a class.")
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

    /// A property whose subjects are classes has no stored requirement:
    /// rdfs:subClassOf is protocol inheritance.
    @Test func schemaDomainHasNoRequirement() {
        assertMacroExpansion(
            """
            @Ontology
            public struct RDFS: Ontology {
                public var body: some Content {
                    Namespace("http://www.w3.org/2000/01/rdf-schema#")

                    Property("subClassOf") {
                        Type(RDF.Property)
                        Domain(RDFS.Class)
                        Range(RDFS.Class)
                        Label("subClassOf")
                        Comment("The subject is a subclass of a class.")
                    }
                }
            }
            """,
            expandedSource: """
            public struct RDFS: Ontology {
                public var body: some Content {
                    @RDFCore.ContentBuilder func declarations() -> [any RDFCore.Content] {

                            RDFKit.Namespace("http://www.w3.org/2000/01/rdf-schema#")

                            RDFKit.Property("subClassOf") {
                                RDFKit.Type(RDF.Property.self)
                                RDFKit.Domain(RDFS.Class.self)
                                RDFKit.Range(RDFS.Class.self)
                                RDFKit.Label("subClassOf")
                                RDFKit.Comment("The subject is a subclass of a class.")
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
