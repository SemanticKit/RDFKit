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
}
