import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport
import Testing
@testable import RDFKitMacros

@Suite("@ClassProperties default implementations", .tags(.generated))
struct ClassPropertiesMacroTests {
    private let specs = ["ClassProperties": MacroSpec(type: ClassPropertiesMacro.self)]

    private func assertProperties(
        _ source: String,
        expandedSource: String,
        diagnostics: [DiagnosticSpec] = [],
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        assertMacroExpansion(
            source,
            expandedSource: expandedSource,
            diagnostics: diagnostics,
            macroSpecs: specs,
            failureHandler: { failure in
                Issue.record(Comment(rawValue: failure.message), sourceLocation: sourceLocation)
            }
        )
    }

    @Test("Each requirement keeps its values under its property term")
    func requirementsKeepValuesUnderTheirTerm() {
        assertProperties(
            """
            struct Zoo {
                @ClassProperties
                public protocol Keeper: RDFCore.Resource {
                    var feeds: [any Zoo.Animal] { get set }
                    var `default`: String? { get set }
                }
            }
            """,
            expandedSource: """
            struct Zoo {
                public protocol Keeper: RDFCore.Resource {
                    var feeds: [any Zoo.Animal] { get set }
                    var `default`: String? { get set }
                }
            }

            extension Zoo.Keeper {
                public var feeds: [any Zoo.Animal] {
                    get {
                        propertyValues[Zoo.feeds()]
                    }
                    set {
                        propertyValues[Zoo.feeds()] = newValue
                    }
                }

                public var `default`: String? {
                    get {
                        propertyValues[Zoo.`default`()]
                    }
                    set {
                        propertyValues[Zoo.`default`()] = newValue
                    }
                }
            }
            """
        )
    }

    @Test("rdfs:subClassOf is kept under its own key, because its term is an RDFCore alias")
    func aliasPropertyUsesItsKey() {
        assertProperties(
            """
            struct RDFS {
                @ClassProperties
                public protocol Class: RDFCore.Resource {
                    var subClassOf: [any RDFS.Class] { get set }
                }
            }
            """,
            expandedSource: """
            struct RDFS {
                public protocol Class: RDFCore.Resource {
                    var subClassOf: [any RDFS.Class] { get set }
                }
            }

            extension RDFS.Class {
                public var subClassOf: [any RDFS.Class] {
                    get {
                        propertyValues[RDFS._subClassOfValues()]
                    }
                    set {
                        propertyValues[RDFS._subClassOfValues()] = newValue
                    }
                }
            }
            """
        )
    }

    @Test("A class with no requirements gets no extension")
    func noRequirementsNoExtension() {
        assertProperties(
            """
            struct Zoo {
                @ClassProperties
                public protocol Vet: RDFCore.Resource {}
            }
            """,
            expandedSource: """
            struct Zoo {
                public protocol Vet: RDFCore.Resource {}
            }
            """
        )
    }

    @Test("Only class protocols take @ClassProperties")
    func onlyProtocols() {
        assertProperties(
            """
            @ClassProperties
            struct Keeper {}
            """,
            expandedSource: """
            struct Keeper {}
            """,
            diagnostics: [
                DiagnosticSpec(message: "@ClassProperties applies to the class protocols @Ontology generates", line: 1, column: 1)
            ]
        )
    }
}
