import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport
import Testing
@testable import RDFKitMacros

@Suite struct ClassGeneratorTests {
    /// rdfs:Resource is the root protocol, and rdfs:Class inherits it.
    @Test func rdfsClassesBecomeProtocols() {
        assertMacroExpansion(
            """
            @Ontology
            public struct RDFS: Ontology {
                public var body: some Content {
                    Namespace("http://www.w3.org/2000/01/rdf-schema#")

                    RDFCore.Class("Resource") {
                        Type(RDFS.Class.self)
                        Label("Resource")
                        Comment("The class resource, everything.")
                    }

                    RDFCore.Class("Class") {
                        Type(RDFS.Class.self)
                        SubClassOf(RDFS.Resource.self)
                        Label("Class")
                        Comment("The class of classes.")
                    }
                }
            }
            """,
            expandedSource: """
            public struct RDFS: Ontology {
                public var body: some Content {
                    Namespace("http://www.w3.org/2000/01/rdf-schema#")

                    RDFCore.Class("Resource") {
                        Type(RDFS.Class.self)
                        Label("Resource")
                        Comment("The class resource, everything.")
                    }

                    RDFCore.Class("Class") {
                        Type(RDFS.Class.self)
                        SubClassOf(RDFS.Resource.self)
                        Label("Class")
                        Comment("The class of classes.")
                    }
                }

                /// The class resource, everything.
                ///
                /// Label: Resource
                public protocol Resource: AnyObject {
                }

                /// The class of classes.
                ///
                /// Label: Class
                public protocol Class: RDFS.Resource {
                }
            }
            """,
            macroSpecs: ["Ontology": MacroSpec(type: OntologyMacro.self)],
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

                    RDFCore.Class("Class") {
                        Type(RDFS.Class.self)
                        SubClassOf(RDFS.Class.self)
                        Label("Class")
                        Comment("The class of OWL classes.")
                    }
                }
            }
            """,
            expandedSource: """
            public struct OWL: Ontology {
                public var body: some Content {
                    Namespace("http://www.w3.org/2002/07/owl#")

                    RDFCore.Class("Class") {
                        Type(RDFS.Class.self)
                        SubClassOf(RDFS.Class.self)
                        Label("Class")
                        Comment("The class of OWL classes.")
                    }
                }

                /// The class of OWL classes.
                ///
                /// Label: Class
                public protocol Class: RDFS.Class {
                }
            }
            """,
            macroSpecs: ["Ontology": MacroSpec(type: OntologyMacro.self)],
            failureHandler: { Issue.record("\($0.message)") }
        )
    }
}
