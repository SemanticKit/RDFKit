import SwiftSyntaxMacrosGenericTestSupport
import Testing

@Suite("@Ontology member expansion", .tags(.generated))
struct OntologyMacroTests {
    @Test("Classes become protocols with individual types, a named individual a constant")
    func classesAndIndividuals() {
        assertExpansion(
            """
            @Ontology
            struct Zoo: Ontology {
                func content() -> Content {
                    Namespace("https://zoo.example.org/#")
                    Class("Animal") {
                        Comment("An animal.")
                    }
                    Class("Keeper") {
                        SubClassOf(Zoo.Animal)
                    }
                    Individual("rex") {
                        Type(Zoo.Keeper)
                    }
                    Property("feeds") {
                        Domain(Zoo.Keeper)
                        Range(Zoo.Animal)
                    }
                    Property("name") {
                        Type(OWL.FunctionalProperty)
                        Domain(Zoo.Animal)
                        Range(RDFS.Literal)
                    }
                }
            }
            """,
            expandedSource: """
            struct Zoo: Ontology {
                func content() -> Content {
                    Namespace("https://zoo.example.org/#")
                    RDFCore.Class("Animal") {
                                Comment("An animal.")
                            }
                    RDFCore.Class("Keeper") {
                                SubClassOf(Zoo.Animal)
                            }
                    RDFCore.Individual("rex") {
                                Type(Zoo.Keeper)
                            }
                    RDFCore.Property("feeds") {
                                Domain(Zoo.Keeper)
                                Range(Zoo.Animal)
                            }
                    RDFCore.Property("name") {
                                Type(OWL.FunctionalProperty)
                                Domain(Zoo.Animal)
                                Range(RDFS.Literal)
                            }
                }

                /// An animal.
                public protocol Animal: RDFCore.Resource {
                    var name: String? {
                        get
                        set
                    }
                }

                /// An individual of ``Zoo/Animal``.
                public final class AnimalIndividual: Zoo.Animal {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#Animal", name: "Animal", comment: "An animal.")

                    private struct Values: Sendable {
                        var name: String?
                    }

                    private let storage: RDFCore.IndividualStorage<Values>

                    /// Creates an individual with these property values.
                    public init(name: String? = nil) {
                        storage = RDFCore.IndividualStorage(Values(name: name))
                    }

                    public var name: String? {
                        get {
                            storage.withLock {
                                $0.name
                            }
                        }
                        set {
                            storage.withLock {
                                $0.name = newValue
                            }
                        }
                    }
                }

                public protocol Keeper: Zoo.Animal {
                    var feeds: [any Zoo.Animal] {
                        get
                        set
                    }
                }

                /// An individual of ``Zoo/Keeper``.
                public final class KeeperIndividual: Zoo.Keeper {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#Keeper", name: "Keeper")

                    private struct Values: Sendable {
                        var name: String?
                        var feeds: [any Zoo.Animal]
                    }

                    private let storage: RDFCore.IndividualStorage<Values>

                    /// Creates an individual with these property values.
                    public init(name: String? = nil, feeds: [any Zoo.Animal] = []) {
                        storage = RDFCore.IndividualStorage(Values(name: name, feeds: feeds))
                    }

                    public var name: String? {
                        get {
                            storage.withLock {
                                $0.name
                            }
                        }
                        set {
                            storage.withLock {
                                $0.name = newValue
                            }
                        }
                    }

                    public var feeds: [any Zoo.Animal] {
                        get {
                            storage.withLock {
                                $0.feeds
                            }
                        }
                        set {
                            storage.withLock {
                                $0.feeds = newValue
                            }
                        }
                    }
                }

                public static let rex: any Zoo.Keeper = _rexIndividual()

                private final class _rexIndividual: Zoo.Keeper {
                    fileprivate static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#rex", name: "rex")

                    private struct Values: Sendable {
                        var name: String?
                        var feeds: [any Zoo.Animal]
                    }

                    private let storage: RDFCore.IndividualStorage<Values>

                    /// Creates an individual with these property values.
                    fileprivate init(name: String? = nil, feeds: [any Zoo.Animal] = []) {
                        storage = RDFCore.IndividualStorage(Values(name: name, feeds: feeds))
                    }

                    fileprivate var name: String? {
                        get {
                            storage.withLock {
                                $0.name
                            }
                        }
                        set {
                            storage.withLock {
                                $0.name = newValue
                            }
                        }
                    }

                    fileprivate var feeds: [any Zoo.Animal] {
                        get {
                            storage.withLock {
                                $0.feeds
                            }
                        }
                        set {
                            storage.withLock {
                                $0.feeds = newValue
                            }
                        }
                    }
                }

                public struct feeds: RDFCore.Entity {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#feeds", name: "feeds")

                    /// The type this property applies to.
                    public typealias Domain = any Zoo.Keeper

                    /// The type of this property's values.
                    public typealias Range = any Zoo.Animal
                }

                public struct name: RDFCore.Entity {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#name", name: "name")

                    /// The type this property applies to.
                    public typealias Domain = any Zoo.Animal

                    /// The type of this property's values.
                    public typealias Range = String
                }
            }
            """
        )
    }

    @Test("Several superclasses become several refinements")
    func multipleSuperclasses() {
        assertExpansion(
            """
            @Ontology
            struct Zoo: Ontology {
                func content() -> Content {
                    Namespace("https://zoo.example.org/#")
                    Class("Keeper")
                    Class("Vet")
                    Class("KeeperVet") {
                        SubClassOf(Zoo.Keeper)
                        SubClassOf(Zoo.Vet)
                    }
                    Individual("rex") {
                        Type(Zoo.Keeper)
                        Type(Zoo.Vet)
                    }
                }
            }
            """,
            expandedSource: """
            struct Zoo: Ontology {
                func content() -> Content {
                    Namespace("https://zoo.example.org/#")
                    RDFCore.Class("Keeper")
                    RDFCore.Class("Vet")
                    RDFCore.Class("KeeperVet") {
                                SubClassOf(Zoo.Keeper)
                                SubClassOf(Zoo.Vet)
                            }
                    RDFCore.Individual("rex") {
                                Type(Zoo.Keeper)
                                Type(Zoo.Vet)
                            }
                }

                public protocol Keeper: RDFCore.Resource {
                }

                /// An individual of ``Zoo/Keeper``.
                public final class KeeperIndividual: Zoo.Keeper {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#Keeper", name: "Keeper")

                    private struct Values: Sendable {
                    }

                    private let storage: RDFCore.IndividualStorage<Values>

                    /// Creates an individual with these property values.
                    public init() {
                        storage = RDFCore.IndividualStorage(Values())
                    }
                }

                public protocol Vet: RDFCore.Resource {
                }

                /// An individual of ``Zoo/Vet``.
                public final class VetIndividual: Zoo.Vet {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#Vet", name: "Vet")

                    private struct Values: Sendable {
                    }

                    private let storage: RDFCore.IndividualStorage<Values>

                    /// Creates an individual with these property values.
                    public init() {
                        storage = RDFCore.IndividualStorage(Values())
                    }
                }

                public protocol KeeperVet: Zoo.Keeper, Zoo.Vet {
                }

                /// An individual of ``Zoo/KeeperVet``.
                public final class KeeperVetIndividual: Zoo.KeeperVet {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#KeeperVet", name: "KeeperVet")

                    private struct Values: Sendable {
                    }

                    private let storage: RDFCore.IndividualStorage<Values>

                    /// Creates an individual with these property values.
                    public init() {
                        storage = RDFCore.IndividualStorage(Values())
                    }
                }

                public static let rex: any Zoo.Keeper & Zoo.Vet = _rexIndividual()

                private final class _rexIndividual: Zoo.Keeper, Zoo.Vet {
                    fileprivate static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#rex", name: "rex")

                    private struct Values: Sendable {
                    }

                    private let storage: RDFCore.IndividualStorage<Values>

                    /// Creates an individual with these property values.
                    fileprivate init() {
                        storage = RDFCore.IndividualStorage(Values())
                    }
                }
            }
            """
        )
    }

    @Test("Datatypes stay value types; a class refining another ontology's class is a protocol only")
    func datatypesAndForeignSuperclasses() {
        assertExpansion(
            """
            @Ontology
            struct Units: Ontology {
                func content() -> Content {
                    Namespace("https://units.example.org/#")
                    Datatype("Kilograms") {
                        SubClassOf(RDFS.Literal)
                    }
                    Class("Animal") {
                        SubClassOf(OWL.Thing)
                    }
                    Property("weight") {
                        Type(OWL.FunctionalProperty)
                        Domain(Units.Animal)
                        Range(Units.Kilograms)
                    }
                }
            }
            """,
            expandedSource: """
            struct Units: Ontology {
                func content() -> Content {
                    Namespace("https://units.example.org/#")
                    RDFCore.Datatype("Kilograms") {
                                SubClassOf(RDFS.Literal)
                            }
                    RDFCore.Class("Animal") {
                                SubClassOf(OWL.Thing)
                            }
                    RDFCore.Property("weight") {
                                Type(OWL.FunctionalProperty)
                                Domain(Units.Animal)
                                Range(Units.Kilograms)
                            }
                }

                public struct Kilograms: RDFCore.Entity {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://units.example.org/#Kilograms", name: "Kilograms")

                    public init() {
                    }
                }

                public protocol Animal: OWL.Thing {
                    var weight: Units.Kilograms? {
                        get
                        set
                    }
                }

                public struct weight: RDFCore.Entity {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://units.example.org/#weight", name: "weight")

                    /// The type this property applies to.
                    public typealias Domain = any Units.Animal

                    /// The type of this property's values.
                    public typealias Range = Units.Kilograms
                }
            }
            """
        )
    }

    @Test("owl:Nothing has no individual type")
    func nothingHasNoIndividuals() {
        assertExpansion(
            """
            @Ontology
            struct OWL: Ontology {
                func content() -> Content {
                    Namespace("http://www.w3.org/2002/07/owl#")
                    Class("Thing")
                    Class("Nothing") {
                        SubClassOf(OWL.Thing)
                    }
                }
            }
            """,
            expandedSource: """
            struct OWL: Ontology {
                func content() -> Content {
                    Namespace("http://www.w3.org/2002/07/owl#")
                    RDFCore.Class("Thing")
                    RDFCore.Class("Nothing") {
                                SubClassOf(OWL.Thing)
                            }
                }

                public protocol Thing: RDFCore.Resource {
                }

                /// An individual of ``OWL/Thing``.
                public final class ThingIndividual: OWL.Thing {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "http://www.w3.org/2002/07/owl#Thing", name: "Thing")

                    private struct Values: Sendable {
                    }

                    private let storage: RDFCore.IndividualStorage<Values>

                    /// Creates an individual with these property values.
                    public init() {
                        storage = RDFCore.IndividualStorage(Values())
                    }
                }

                public protocol Nothing: OWL.Thing {
                }
            }
            """
        )
    }

    @Test("Term mistakes are reported at the authored annotation")
    func diagnostics() {
        assertExpansion(
            """
            @Ontology
            struct Zoo: Ontology {
                func content() -> Content {
                    Namespace("https://zoo.example.org/#")
                    Class("Animal")
                    Class("Keeper") {
                        SubClassOf(Zoo.Animl)
                    }
                    Class("AnimalIndividual")
                    Individual("rex") {
                        Type(OWL.Thing)
                    }
                    Datatype("Weight")
                    Property("heavier") {
                        Type(OWL.FunctionalProperty)
                        Domain(Zoo.Weight)
                        Range(Zoo.Weight)
                    }
                }
            }
            """,
            expandedSource: """
            struct Zoo: Ontology {
                func content() -> Content {
                    Namespace("https://zoo.example.org/#")
                    RDFCore.Class("Animal")
                    RDFCore.Class("Keeper") {
                                SubClassOf(Zoo.Animl)
                            }
                    RDFCore.Class("AnimalIndividual")
                    RDFCore.Individual("rex") {
                                Type(OWL.Thing)
                            }
                    RDFCore.Datatype("Weight")
                    RDFCore.Property("heavier") {
                                Type(OWL.FunctionalProperty)
                                Domain(Zoo.Weight)
                                Range(Zoo.Weight)
                            }
                }

                public protocol Animal: RDFCore.Resource {
                }

                public protocol Keeper: RDFCore.Resource {
                }

                public protocol AnimalIndividual: RDFCore.Resource {
                }

                /// An individual of ``Zoo/AnimalIndividual``.
                public final class AnimalIndividualIndividual: Zoo.AnimalIndividual {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#AnimalIndividual", name: "AnimalIndividual")

                    private struct Values: Sendable {
                    }

                    private let storage: RDFCore.IndividualStorage<Values>

                    /// Creates an individual with these property values.
                    public init() {
                        storage = RDFCore.IndividualStorage(Values())
                    }
                }

                public struct Weight: RDFCore.Entity {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#Weight", name: "Weight")

                    public var heavier: Zoo.Weight?

                    public init(heavier: Zoo.Weight? = nil) {
                        self.heavier = heavier
                    }
                }

                public struct heavier: RDFCore.Entity {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#heavier", name: "heavier")

                    /// The type this property applies to.
                    public typealias Domain = Zoo.Weight

                    /// The type of this property's values.
                    public typealias Range = Zoo.Weight
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "'Zoo.Animl' is not declared in Zoo", line: 7, column: 13),
                DiagnosticSpec(message: "'AnimalIndividual' is declared in this ontology, so the individual type of 'Animal' cannot use that name", line: 5, column: 9),
                DiagnosticSpec(message: "@Ontology generates the properties of individuals whose classes and superclasses are declared in this ontology (or are RDFS.Resource); 'OWL.Thing' is not", line: 11, column: 13),
                DiagnosticSpec(message: "'heavier' has at most one 'Weight', which would make the value type 'Weight' contain itself; make the property many-valued", line: 14, column: 9),
            ]
        )
    }
}
