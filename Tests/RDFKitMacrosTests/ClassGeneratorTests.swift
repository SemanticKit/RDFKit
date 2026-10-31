import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport
import Testing
@testable import RDFKitMacros
import OntologyGeneration

@Suite(.tags(.codeGeneration))
struct ClassGeneratorTests {
    let specs: [String: MacroSpec] = [
        "Ontology": MacroSpec(type: OntologyMacro.self),
        "OntologyBody": MacroSpec(type: OntologyBodyMacro.self),
    ]

    /// rdfs:Resource is the root protocol, and rdfs:Class inherits it. The
    /// body is written as authored, `Type(RDFS.Class)` and `Class(...)`, and
    /// read before it is type-checked.
    @Test func rdfsClassesBecomeProtocols() {
        assertMacroExpansion(
            """
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
            """,
            expandedSource: """
            public struct RDFS: Ontology {
                public var body: some Content {
                    @RDFCore.ContentBuilder func declarations() -> [any RDFCore.Content] {

                            RDFKit.Namespace("http://www.w3.org/2000/01/rdf-schema#")

                            RDFKit.Class("Resource") {
                                RDFKit.Type(RDFS.Class.self)
                                RDFKit.Label("Resource")
                                RDFKit.Comment("The class resource, everything.")
                            }

                            RDFKit.Class("Class") {
                                RDFKit.Type(RDFS.Class.self)
                                RDFKit.SubClassOf(RDFS.Resource.self)
                                RDFKit.Label("Class")
                                RDFKit.Comment("The class of classes.")
                            }
                    }
                    return declarations()
                }

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
            }
            """,
            macroSpecs: specs,
            failureHandler: { Issue.record("\($0.message)") }
        )
    }

    /// owl:Class inherits rdfs:Class.
    @Test func owlClassInheritsRDFSClass() {
        assertMacroExpansion(
            """
            @Ontology
            public struct OWL: Ontology {
                public var body: some Content {
                    Namespace("http://www.w3.org/2002/07/owl#")

                    Class("Class") {
                        Type(RDFS.Class)
                        SubClassOf(RDFS.Class)
                        Label("Class")
                        Comment("The class of OWL classes.")
                    }
                }
            }
            """,
            expandedSource: """
            public struct OWL: Ontology {
                public var body: some Content {
                    @RDFCore.ContentBuilder func declarations() -> [any RDFCore.Content] {

                            RDFKit.Namespace("http://www.w3.org/2002/07/owl#")

                            RDFKit.Class("Class") {
                                RDFKit.Type(RDFS.Class.self)
                                RDFKit.SubClassOf(RDFS.Class.self)
                                RDFKit.Label("Class")
                                RDFKit.Comment("The class of OWL classes.")
                            }
                    }
                    return declarations()
                }

                /// The class of OWL classes.
                ///
                /// Label: Class
                public protocol Class: RDFS.Class, AnyObject {
                }
            }
            """,
            macroSpecs: specs,
            failureHandler: { Issue.record("\($0.message)") }
        )
    }

    /// owl:Thing names the root protocol (D7).
    @Test func owlThingIsTheRoot() {
        assertMacroExpansion(
            """
            @Ontology
            public struct OWL: Ontology {
                public var body: some Content {
                    Namespace("http://www.w3.org/2002/07/owl#")

                    Class("Thing") {
                        Type(OWL.Class)
                        Label("Thing")
                        Comment("The class of OWL individuals.")
                    }
                }
            }
            """,
            expandedSource: """
            public struct OWL: Ontology {
                public var body: some Content {
                    @RDFCore.ContentBuilder func declarations() -> [any RDFCore.Content] {

                            RDFKit.Namespace("http://www.w3.org/2002/07/owl#")

                            RDFKit.Class("Thing") {
                                RDFKit.Type(OWL.Class.self)
                                RDFKit.Label("Thing")
                                RDFKit.Comment("The class of OWL individuals.")
                            }
                    }
                    return declarations()
                }

                /// The class of OWL individuals.
                ///
                /// Label: Thing
                public typealias Thing = RDFS.Resource
            }
            """,
            macroSpecs: specs,
            failureHandler: { Issue.record("\($0.message)") }
        )
    }

    /// owl:Nothing, the empty class, names Never (D7).
    @Test func owlNothingIsNever() {
        assertMacroExpansion(
            """
            @Ontology
            public struct OWL: Ontology {
                public var body: some Content {
                    Namespace("http://www.w3.org/2002/07/owl#")

                    Class("Nothing") {
                        Type(OWL.Class)
                        SubClassOf(OWL.Thing)
                        Label("Nothing")
                        Comment("This is the empty class.")
                    }
                }
            }
            """,
            expandedSource: """
            public struct OWL: Ontology {
                public var body: some Content {
                    @RDFCore.ContentBuilder func declarations() -> [any RDFCore.Content] {

                            RDFKit.Namespace("http://www.w3.org/2002/07/owl#")

                            RDFKit.Class("Nothing") {
                                RDFKit.Type(OWL.Class.self)
                                RDFKit.SubClassOf(OWL.Thing.self)
                                RDFKit.Label("Nothing")
                                RDFKit.Comment("This is the empty class.")
                            }
                    }
                    return declarations()
                }

                /// This is the empty class.
                ///
                /// Label: Nothing
                public typealias Nothing = Never
            }
            """,
            macroSpecs: specs,
            failureHandler: { Issue.record("\($0.message)") }
        )
    }
}
