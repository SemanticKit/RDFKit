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

    @Test("Each requirement keeps its values under its property term, and has a named member")
    func requirementsKeepValuesUnderTheirTerm() {
        assertProperties(
            """
            struct Zoo {
                @ClassProperties
                public protocol Keeper: RDFCore.Resource {
                    /// The animals a keeper feeds.
                    subscript(property: Zoo.feeds) -> [any Zoo.Animal] { get set }
                    subscript(property: Zoo.`default`) -> String? { get set }
                }
            }
            """,
            expandedSource: """
            struct Zoo {
                public protocol Keeper: RDFCore.Resource {
                    /// The animals a keeper feeds.
                    subscript(property: Zoo.feeds) -> [any Zoo.Animal] { get set }
                    subscript(property: Zoo.`default`) -> String? { get set }
                }
            }

            extension Zoo.Keeper {
                public subscript(property: Zoo.feeds) -> [any Zoo.Animal] {
                    get {
                        propertyValues[property]
                    }
                    set {
                        propertyValues[property] = newValue
                    }
                }

                /// The animals a keeper feeds.
                public var feeds: [any Zoo.Animal] {
                    get {
                        self[Zoo.feeds()]
                    }
                    set {
                        self[Zoo.feeds()] = newValue
                    }
                }

                public subscript(property: Zoo.`default`) -> String? {
                    get {
                        propertyValues[property]
                    }
                    set {
                        propertyValues[property] = newValue
                    }
                }

                public var `default`: String? {
                    get {
                        self[Zoo.`default`()]
                    }
                    set {
                        self[Zoo.`default`()] = newValue
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
                    subscript(property: RDFS._subClassOfValues) -> [any RDFS.Class] { get set }
                }
            }
            """,
            expandedSource: """
            struct RDFS {
                public protocol Class: RDFCore.Resource {
                    subscript(property: RDFS._subClassOfValues) -> [any RDFS.Class] { get set }
                }
            }

            extension RDFS.Class {
                public subscript(property: RDFS._subClassOfValues) -> [any RDFS.Class] {
                    get {
                        propertyValues[property]
                    }
                    set {
                        propertyValues[property] = newValue
                    }
                }

                public var subClassOf: [any RDFS.Class] {
                    get {
                        self[RDFS._subClassOfValues()]
                    }
                    set {
                        self[RDFS._subClassOfValues()] = newValue
                    }
                }
            }
            """
        )
    }

    @Test("Same-named properties of two ontologies get members keyed by their own terms")
    func sameNamedPropertiesOfTwoOntologies() {
        assertProperties(
            """
            struct Fauna {
                @ClassProperties
                public protocol Animal: RDFCore.Resource {
                    subscript(property: Fauna.commonName) -> [String] { get set }
                }
            }
            struct Zoo {
                @ClassProperties
                public protocol Resident: Fauna.Animal {
                    subscript(property: Zoo.commonName) -> [String] { get set }
                }
            }
            """,
            expandedSource: """
            struct Fauna {
                public protocol Animal: RDFCore.Resource {
                    subscript(property: Fauna.commonName) -> [String] { get set }
                }
            }
            struct Zoo {
                public protocol Resident: Fauna.Animal {
                    subscript(property: Zoo.commonName) -> [String] { get set }
                }
            }

            extension Fauna.Animal {
                public subscript(property: Fauna.commonName) -> [String] {
                    get {
                        propertyValues[property]
                    }
                    set {
                        propertyValues[property] = newValue
                    }
                }

                public var commonName: [String] {
                    get {
                        self[Fauna.commonName()]
                    }
                    set {
                        self[Fauna.commonName()] = newValue
                    }
                }
            }

            extension Zoo.Resident {
                public subscript(property: Zoo.commonName) -> [String] {
                    get {
                        propertyValues[property]
                    }
                    set {
                        propertyValues[property] = newValue
                    }
                }

                public var commonName: [String] {
                    get {
                        self[Zoo.commonName()]
                    }
                    set {
                        self[Zoo.commonName()] = newValue
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
