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
                                RDFS.comment("An animal.")
                            }
                    RDFCore.Class("Keeper") {
                                RDFS.subClassOf<Zoo.Animal>()
                            }
                    RDFCore.Individual("rex") {
                                RDF.type<Zoo.Keeper>()
                            }
                    RDFCore.Property("feeds") {
                                RDFS.domain<Zoo.Keeper>()
                                RDFS.range<Zoo.Animal>()
                            }
                    RDFCore.Property("name") {
                                RDF.type<OWL.FunctionalProperty>()
                                RDFS.domain<Zoo.Animal>()
                                RDFS.range<RDFS.Literal>()
                            }
                }

                /// An animal.
                protocol Animal: RDFS.Resource {
                    var name: String? {
                        get
                        set
                    }

                    /// Reads or changes the stored values of this class's properties.
                    func _withZoo_AnimalValues<Result: Sendable>(_ body: (inout Zoo.AnimalValues) -> Result) -> Result

                    /// Reads or changes the stored values of ``RDFS/Resource``.
                    func _withRDFS_ResourceValues<Result: Sendable>(_ body: (inout RDFS.ResourceValues) -> Result) -> Result
                }

                /// The stored property values of an individual of ``Zoo/Animal``.
                public struct AnimalValues: Sendable {
                    var name: String? = nil
                    var _RDFS_Resource = RDFS.ResourceValues()

                    /// No values.
                    public init() {
                    }
                }

                /// An individual of ``Zoo/Animal``.
                public final class AnimalIndividual: Zoo.Animal {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#Animal", name: "Animal", comment: "An animal.")

                    private let storage: RDFCore.IndividualStorage<Zoo.AnimalValues>

                    /// Creates an individual with these property values.
                    public init(name: String? = nil) {
                        var values = Zoo.AnimalValues()
                        values.name = name
                        storage = RDFCore.IndividualStorage(values)
                    }

                    /// Reads or changes this individual's property values while holding its lock.
                    public func _withZoo_AnimalValues<Result: Sendable>(_ body: (inout Zoo.AnimalValues) -> Result) -> Result {
                        storage.withLock(body)
                    }
                }
                protocol Keeper: Zoo.Animal {
                    var feeds: [any Zoo.Animal] {
                        get
                        set
                    }

                    /// Reads or changes the stored values of this class's properties.
                    func _withZoo_KeeperValues<Result: Sendable>(_ body: (inout Zoo.KeeperValues) -> Result) -> Result

                    /// Reads or changes the stored values of ``Zoo/Animal``.
                    func _withZoo_AnimalValues<Result: Sendable>(_ body: (inout Zoo.AnimalValues) -> Result) -> Result

                    /// Reads or changes the stored values of ``RDFS/Resource``.
                    func _withRDFS_ResourceValues<Result: Sendable>(_ body: (inout RDFS.ResourceValues) -> Result) -> Result
                }

                /// The stored property values of an individual of ``Zoo/Keeper``.
                public struct KeeperValues: Sendable {
                    var feeds: [any Zoo.Animal] = []
                    var _Zoo_Animal = Zoo.AnimalValues()
                    var _RDFS_Resource = RDFS.ResourceValues()

                    /// No values.
                    public init() {
                    }
                }

                /// An individual of ``Zoo/Keeper``.
                public final class KeeperIndividual: Zoo.Keeper {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#Keeper", name: "Keeper")

                    private let storage: RDFCore.IndividualStorage<Zoo.KeeperValues>

                    /// Creates an individual with these property values.
                    public init(name: String? = nil, feeds: [any Zoo.Animal] = []) {
                        var values = Zoo.KeeperValues()
                        values._Zoo_Animal.name = name
                        values.feeds = feeds
                        storage = RDFCore.IndividualStorage(values)
                    }

                    /// Reads or changes this individual's property values while holding its lock.
                    public func _withZoo_KeeperValues<Result: Sendable>(_ body: (inout Zoo.KeeperValues) -> Result) -> Result {
                        storage.withLock(body)
                    }
                }

                public static let rex: any Zoo.Keeper = _rexIndividual()

                private final class _rexIndividual: Zoo.Keeper {
                    fileprivate static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#rex", name: "rex")

                    private struct Values: Sendable {
                        var _Zoo_Keeper = Zoo.KeeperValues()
                        var _Zoo_Animal = Zoo.AnimalValues()
                        var _RDFS_Resource = RDFS.ResourceValues()
                    }

                    private let storage = RDFCore.IndividualStorage(Values())

                    fileprivate init() {
                    }

                    fileprivate func _withZoo_KeeperValues<Result: Sendable>(_ body: (inout Zoo.KeeperValues) -> Result) -> Result {
                        storage.withLock {
                            body(&$0._Zoo_Keeper)
                        }
                    }

                    fileprivate func _withZoo_AnimalValues<Result: Sendable>(_ body: (inout Zoo.AnimalValues) -> Result) -> Result {
                        storage.withLock {
                            body(&$0._Zoo_Animal)
                        }
                    }

                    fileprivate func _withRDFS_ResourceValues<Result: Sendable>(_ body: (inout RDFS.ResourceValues) -> Result) -> Result {
                        storage.withLock {
                            body(&$0._RDFS_Resource)
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

            extension Animal {
                var name: String? {
                    get {
                        _withZoo_AnimalValues {
                            $0.name
                        }
                    }
                    set {
                        _withZoo_AnimalValues {
                            $0.name = newValue
                        }
                    }
                }

                func _withRDFS_ResourceValues<Result: Sendable>(_ body: (inout RDFS.ResourceValues) -> Result) -> Result {
                    _withZoo_AnimalValues {
                        body(&$0._RDFS_Resource)
                    }
                }
            }

            extension Keeper {
                var feeds: [any Zoo.Animal] {
                    get {
                        _withZoo_KeeperValues {
                            $0.feeds
                        }
                    }
                    set {
                        _withZoo_KeeperValues {
                            $0.feeds = newValue
                        }
                    }
                }

                func _withZoo_AnimalValues<Result: Sendable>(_ body: (inout Zoo.AnimalValues) -> Result) -> Result {
                    _withZoo_KeeperValues {
                        body(&$0._Zoo_Animal)
                    }
                }

                func _withRDFS_ResourceValues<Result: Sendable>(_ body: (inout RDFS.ResourceValues) -> Result) -> Result {
                    _withZoo_KeeperValues {
                        body(&$0._RDFS_Resource)
                    }
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
                                RDFS.subClassOf<Zoo.Keeper>()
                                RDFS.subClassOf<Zoo.Vet>()
                            }
                    RDFCore.Individual("rex") {
                                RDF.type<Zoo.Keeper>()
                                RDF.type<Zoo.Vet>()
                            }
                }
                protocol Keeper: RDFS.Resource {
                    /// Reads or changes the stored values of this class's properties.
                    func _withZoo_KeeperValues<Result: Sendable>(_ body: (inout Zoo.KeeperValues) -> Result) -> Result

                    /// Reads or changes the stored values of ``RDFS/Resource``.
                    func _withRDFS_ResourceValues<Result: Sendable>(_ body: (inout RDFS.ResourceValues) -> Result) -> Result
                }

                /// The stored property values of an individual of ``Zoo/Keeper``.
                public struct KeeperValues: Sendable {
                    var _RDFS_Resource = RDFS.ResourceValues()

                    /// No values.
                    public init() {
                    }
                }

                /// An individual of ``Zoo/Keeper``.
                public final class KeeperIndividual: Zoo.Keeper {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#Keeper", name: "Keeper")

                    private let storage: RDFCore.IndividualStorage<Zoo.KeeperValues>

                    /// Creates an individual with these property values.
                    public init() {
                        storage = RDFCore.IndividualStorage(Zoo.KeeperValues())
                    }

                    /// Reads or changes this individual's property values while holding its lock.
                    public func _withZoo_KeeperValues<Result: Sendable>(_ body: (inout Zoo.KeeperValues) -> Result) -> Result {
                        storage.withLock(body)
                    }
                }
                protocol Vet: RDFS.Resource {
                    /// Reads or changes the stored values of this class's properties.
                    func _withZoo_VetValues<Result: Sendable>(_ body: (inout Zoo.VetValues) -> Result) -> Result

                    /// Reads or changes the stored values of ``RDFS/Resource``.
                    func _withRDFS_ResourceValues<Result: Sendable>(_ body: (inout RDFS.ResourceValues) -> Result) -> Result
                }

                /// The stored property values of an individual of ``Zoo/Vet``.
                public struct VetValues: Sendable {
                    var _RDFS_Resource = RDFS.ResourceValues()

                    /// No values.
                    public init() {
                    }
                }

                /// An individual of ``Zoo/Vet``.
                public final class VetIndividual: Zoo.Vet {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#Vet", name: "Vet")

                    private let storage: RDFCore.IndividualStorage<Zoo.VetValues>

                    /// Creates an individual with these property values.
                    public init() {
                        storage = RDFCore.IndividualStorage(Zoo.VetValues())
                    }

                    /// Reads or changes this individual's property values while holding its lock.
                    public func _withZoo_VetValues<Result: Sendable>(_ body: (inout Zoo.VetValues) -> Result) -> Result {
                        storage.withLock(body)
                    }
                }
                protocol KeeperVet: Zoo.Keeper, Zoo.Vet {
                    /// Reads or changes the stored values of this class's properties.
                    func _withZoo_KeeperVetValues<Result: Sendable>(_ body: (inout Zoo.KeeperVetValues) -> Result) -> Result

                    /// Reads or changes the stored values of ``Zoo/Keeper``.
                    func _withZoo_KeeperValues<Result: Sendable>(_ body: (inout Zoo.KeeperValues) -> Result) -> Result

                    /// Reads or changes the stored values of ``Zoo/Vet``.
                    func _withZoo_VetValues<Result: Sendable>(_ body: (inout Zoo.VetValues) -> Result) -> Result

                    /// Reads or changes the stored values of ``RDFS/Resource``.
                    func _withRDFS_ResourceValues<Result: Sendable>(_ body: (inout RDFS.ResourceValues) -> Result) -> Result
                }

                /// The stored property values of an individual of ``Zoo/KeeperVet``.
                public struct KeeperVetValues: Sendable {
                    var _Zoo_Keeper = Zoo.KeeperValues()
                    var _Zoo_Vet = Zoo.VetValues()
                    var _RDFS_Resource = RDFS.ResourceValues()

                    /// No values.
                    public init() {
                    }
                }

                /// An individual of ``Zoo/KeeperVet``.
                public final class KeeperVetIndividual: Zoo.KeeperVet {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#KeeperVet", name: "KeeperVet")

                    private let storage: RDFCore.IndividualStorage<Zoo.KeeperVetValues>

                    /// Creates an individual with these property values.
                    public init() {
                        storage = RDFCore.IndividualStorage(Zoo.KeeperVetValues())
                    }

                    /// Reads or changes this individual's property values while holding its lock.
                    public func _withZoo_KeeperVetValues<Result: Sendable>(_ body: (inout Zoo.KeeperVetValues) -> Result) -> Result {
                        storage.withLock(body)
                    }
                }

                public static let rex: any Zoo.Keeper & Zoo.Vet = _rexIndividual()

                private final class _rexIndividual: Zoo.Keeper, Zoo.Vet {
                    fileprivate static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#rex", name: "rex")

                    private struct Values: Sendable {
                        var _Zoo_Keeper = Zoo.KeeperValues()
                        var _RDFS_Resource = RDFS.ResourceValues()
                        var _Zoo_Vet = Zoo.VetValues()
                    }

                    private let storage = RDFCore.IndividualStorage(Values())

                    fileprivate init() {
                    }

                    fileprivate func _withZoo_KeeperValues<Result: Sendable>(_ body: (inout Zoo.KeeperValues) -> Result) -> Result {
                        storage.withLock {
                            body(&$0._Zoo_Keeper)
                        }
                    }

                    fileprivate func _withRDFS_ResourceValues<Result: Sendable>(_ body: (inout RDFS.ResourceValues) -> Result) -> Result {
                        storage.withLock {
                            body(&$0._RDFS_Resource)
                        }
                    }

                    fileprivate func _withZoo_VetValues<Result: Sendable>(_ body: (inout Zoo.VetValues) -> Result) -> Result {
                        storage.withLock {
                            body(&$0._Zoo_Vet)
                        }
                    }
                }
            }

            extension Keeper {
                func _withRDFS_ResourceValues<Result: Sendable>(_ body: (inout RDFS.ResourceValues) -> Result) -> Result {
                    _withZoo_KeeperValues {
                        body(&$0._RDFS_Resource)
                    }
                }
            }

            extension Vet {
                func _withRDFS_ResourceValues<Result: Sendable>(_ body: (inout RDFS.ResourceValues) -> Result) -> Result {
                    _withZoo_VetValues {
                        body(&$0._RDFS_Resource)
                    }
                }
            }

            extension KeeperVet {
                func _withZoo_KeeperValues<Result: Sendable>(_ body: (inout Zoo.KeeperValues) -> Result) -> Result {
                    _withZoo_KeeperVetValues {
                        body(&$0._Zoo_Keeper)
                    }
                }

                func _withZoo_VetValues<Result: Sendable>(_ body: (inout Zoo.VetValues) -> Result) -> Result {
                    _withZoo_KeeperVetValues {
                        body(&$0._Zoo_Vet)
                    }
                }

                func _withRDFS_ResourceValues<Result: Sendable>(_ body: (inout RDFS.ResourceValues) -> Result) -> Result {
                    _withZoo_KeeperVetValues {
                        body(&$0._RDFS_Resource)
                    }
                }
            }
            """
        )
    }

    @Test("Datatypes stay value types; a class refining another ontology's class keeps that class's values in a slot")
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
                                RDFS.subClassOf<RDFS.Literal>()
                            }
                    RDFCore.Class("Animal") {
                                RDFS.subClassOf<OWL.Thing>()
                            }
                    RDFCore.Property("weight") {
                                RDF.type<OWL.FunctionalProperty>()
                                RDFS.domain<Units.Animal>()
                                RDFS.range<Units.Kilograms>()
                            }
                }

                public struct Kilograms: RDFCore.Entity {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://units.example.org/#Kilograms", name: "Kilograms")

                    public init() {
                    }
                }
                protocol Animal: OWL.Thing {
                    var weight: Units.Kilograms? {
                        get
                        set
                    }

                    /// Reads or changes the stored values of this class's properties.
                    func _withUnits_AnimalValues<Result: Sendable>(_ body: (inout Units.AnimalValues) -> Result) -> Result

                    /// Reads or changes the stored values of ``OWL/Thing``.
                    func _withOWL_ThingValues<Result: Sendable>(_ body: (inout OWL.ThingValues) -> Result) -> Result
                }

                /// The stored property values of an individual of ``Units/Animal``.
                public struct AnimalValues: Sendable {
                    var weight: Units.Kilograms? = nil
                    var _OWL_Thing = OWL.ThingValues()

                    /// No values.
                    public init() {
                    }
                }

                /// An individual of ``Units/Animal``.
                public final class AnimalIndividual: Units.Animal {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://units.example.org/#Animal", name: "Animal")

                    private let storage: RDFCore.IndividualStorage<Units.AnimalValues>

                    /// Creates an individual with these property values.
                    public init(weight: Units.Kilograms? = nil) {
                        var values = Units.AnimalValues()
                        values.weight = weight
                        storage = RDFCore.IndividualStorage(values)
                    }

                    /// Reads or changes this individual's property values while holding its lock.
                    public func _withUnits_AnimalValues<Result: Sendable>(_ body: (inout Units.AnimalValues) -> Result) -> Result {
                        storage.withLock(body)
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

            extension Animal {
                var weight: Units.Kilograms? {
                    get {
                        _withUnits_AnimalValues {
                            $0.weight
                        }
                    }
                    set {
                        _withUnits_AnimalValues {
                            $0.weight = newValue
                        }
                    }
                }

                func _withOWL_ThingValues<Result: Sendable>(_ body: (inout OWL.ThingValues) -> Result) -> Result {
                    _withUnits_AnimalValues {
                        body(&$0._OWL_Thing)
                    }
                }
            }
            """
        )
    }

    @Test("The properties the DSL is written with become annotation types")
    func bootstrapAnnotations() {
        assertExpansion(
            """
            @Ontology
            struct RDFS: Ontology {
                func content() -> Content {
                    Namespace("http://www.w3.org/2000/01/rdf-schema#")
                    Class("Resource")
                    Class("Class") {
                        SubClassOf(RDFS.Resource)
                    }
                    Class("Literal") {
                        SubClassOf(RDFS.Resource)
                    }
                    Property("label") {
                        Domain(RDFS.Resource)
                        Range(RDFS.Literal)
                    }
                    Property("seeAlso") {
                        Domain(RDFS.Resource)
                        Range(RDFS.Resource)
                    }
                    Property("subClassOf") {
                        Domain(RDFS.Class)
                        Range(RDFS.Class)
                    }
                }
            }
            """,
            expandedSource: """
            struct RDFS: Ontology {
                func content() -> Content {
                    Namespace("http://www.w3.org/2000/01/rdf-schema#")
                    RDFCore.Class("Resource")
                    RDFCore.Class("Class") {
                                RDFS.subClassOf<RDFS.Resource>()
                            }
                    RDFCore.Class("Literal") {
                                RDFS.subClassOf<RDFS.Resource>()
                            }
                    RDFCore.Property("label") {
                                RDFS.domain<RDFS.Resource>()
                                RDFS.range<RDFS.Literal>()
                            }
                    RDFCore.Property("seeAlso") {
                                RDFS.domain<RDFS.Resource>()
                                RDFS.range<RDFS.Resource>()
                            }
                    RDFCore.Property("subClassOf") {
                                RDFS.domain<RDFS.Class>()
                                RDFS.range<RDFS.Class>()
                            }
                }
                protocol Resource: AnyObject, RDFCore.Entity {
                    var label: [String] {
                        get
                        set
                    }

                    var seeAlso: [any RDFS.Resource] {
                        get
                        set
                    }

                    /// Reads or changes the stored values of this class's properties.
                    func _withRDFS_ResourceValues<Result: Sendable>(_ body: (inout RDFS.ResourceValues) -> Result) -> Result
                }

                /// The stored property values of an individual of ``RDFS/Resource``.
                public struct ResourceValues: Sendable {
                    var label: [String] = []
                    var seeAlso: [any RDFS.Resource] = []

                    /// No values.
                    public init() {
                    }
                }

                /// An individual of ``RDFS/Resource``.
                public final class ResourceIndividual: RDFS.Resource {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "http://www.w3.org/2000/01/rdf-schema#Resource", name: "Resource")

                    private let storage: RDFCore.IndividualStorage<RDFS.ResourceValues>

                    /// Creates an individual with these property values.
                    public init(label: [String] = [], seeAlso: [any RDFS.Resource] = []) {
                        var values = RDFS.ResourceValues()
                        values.label = label
                        values.seeAlso = seeAlso
                        storage = RDFCore.IndividualStorage(values)
                    }

                    /// Reads or changes this individual's property values while holding its lock.
                    public func _withRDFS_ResourceValues<Result: Sendable>(_ body: (inout RDFS.ResourceValues) -> Result) -> Result {
                        storage.withLock(body)
                    }
                }
                protocol Class: RDFS.Resource {
                    var subClassOf: [any RDFS.Class] {
                        get
                        set
                    }

                    /// Reads or changes the stored values of this class's properties.
                    func _withRDFS_ClassValues<Result: Sendable>(_ body: (inout RDFS.ClassValues) -> Result) -> Result

                    /// Reads or changes the stored values of ``RDFS/Resource``.
                    func _withRDFS_ResourceValues<Result: Sendable>(_ body: (inout RDFS.ResourceValues) -> Result) -> Result
                }

                /// The stored property values of an individual of ``RDFS/Class``.
                public struct ClassValues: Sendable {
                    var subClassOf: [any RDFS.Class] = []
                    var _RDFS_Resource = RDFS.ResourceValues()

                    /// No values.
                    public init() {
                    }
                }

                /// An individual of ``RDFS/Class``.
                public final class ClassIndividual: RDFS.Class {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "http://www.w3.org/2000/01/rdf-schema#Class", name: "Class")

                    private let storage: RDFCore.IndividualStorage<RDFS.ClassValues>

                    /// Creates an individual with these property values.
                    public init(label: [String] = [], seeAlso: [any RDFS.Resource] = [], subClassOf: [any RDFS.Class] = []) {
                        var values = RDFS.ClassValues()
                        values._RDFS_Resource.label = label
                        values._RDFS_Resource.seeAlso = seeAlso
                        values.subClassOf = subClassOf
                        storage = RDFCore.IndividualStorage(values)
                    }

                    /// Reads or changes this individual's property values while holding its lock.
                    public func _withRDFS_ClassValues<Result: Sendable>(_ body: (inout RDFS.ClassValues) -> Result) -> Result {
                        storage.withLock(body)
                    }
                }

                public struct Literal: RDFCore.Entity {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "http://www.w3.org/2000/01/rdf-schema#Literal", name: "Literal")

                    public init() {
                    }
                }

                public struct label: RDFCore.Annotation {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "http://www.w3.org/2000/01/rdf-schema#label", name: "label")

                    /// The annotation text.
                    public let text: String

                    public init(_ text: String) {
                        self.text = text
                    }

                    /// The type this property applies to.
                    public typealias Domain = any RDFS.Resource

                    /// The type of this property's values.
                    public typealias Range = String
                }

                public struct seeAlso: RDFCore.Annotation {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "http://www.w3.org/2000/01/rdf-schema#seeAlso", name: "seeAlso")

                    /// The address of the document, which readers dereference.
                    public let document: IRIKit.IRI

                    public init(_ document: IRIKit.IRI) {
                        self.document = document
                    }

                    /// The type this property applies to.
                    public typealias Domain = any RDFS.Resource

                    /// The type of this property's values.
                    public typealias Range = any RDFS.Resource
                }

                public struct subClassOf<Term>: RDFCore.TermAnnotation {
                    public static var metadata: any RDFCore.ContentMetadata {
                        RDFCore.RDFMetadata(id: "http://www.w3.org/2000/01/rdf-schema#subClassOf", name: "subClassOf")
                    }

                    public init() {
                    }

                    /// The type this property applies to.
                    public typealias Domain = any RDFS.Class

                    /// The type of this property's values.
                    public typealias Range = any RDFS.Class
                }
            }

            extension Resource {
                var label: [String] {
                    get {
                        _withRDFS_ResourceValues {
                            $0.label
                        }
                    }
                    set {
                        _withRDFS_ResourceValues {
                            $0.label = newValue
                        }
                    }
                }

                var seeAlso: [any RDFS.Resource] {
                    get {
                        _withRDFS_ResourceValues {
                            $0.seeAlso
                        }
                    }
                    set {
                        _withRDFS_ResourceValues {
                            $0.seeAlso = newValue
                        }
                    }
                }
            }

            extension Class {
                var subClassOf: [any RDFS.Class] {
                    get {
                        _withRDFS_ClassValues {
                            $0.subClassOf
                        }
                    }
                    set {
                        _withRDFS_ClassValues {
                            $0.subClassOf = newValue
                        }
                    }
                }

                func _withRDFS_ResourceValues<Result: Sendable>(_ body: (inout RDFS.ResourceValues) -> Result) -> Result {
                    _withRDFS_ClassValues {
                        body(&$0._RDFS_Resource)
                    }
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
                                RDFS.subClassOf<OWL.Thing>()
                            }
                }
                protocol Thing: RDFS.Resource {
                    /// Reads or changes the stored values of this class's properties.
                    func _withOWL_ThingValues<Result: Sendable>(_ body: (inout OWL.ThingValues) -> Result) -> Result

                    /// Reads or changes the stored values of ``RDFS/Resource``.
                    func _withRDFS_ResourceValues<Result: Sendable>(_ body: (inout RDFS.ResourceValues) -> Result) -> Result
                }

                /// The stored property values of an individual of ``OWL/Thing``.
                public struct ThingValues: Sendable {
                    var _RDFS_Resource = RDFS.ResourceValues()

                    /// No values.
                    public init() {
                    }
                }

                /// An individual of ``OWL/Thing``.
                public final class ThingIndividual: OWL.Thing {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "http://www.w3.org/2002/07/owl#Thing", name: "Thing")

                    private let storage: RDFCore.IndividualStorage<OWL.ThingValues>

                    /// Creates an individual with these property values.
                    public init() {
                        storage = RDFCore.IndividualStorage(OWL.ThingValues())
                    }

                    /// Reads or changes this individual's property values while holding its lock.
                    public func _withOWL_ThingValues<Result: Sendable>(_ body: (inout OWL.ThingValues) -> Result) -> Result {
                        storage.withLock(body)
                    }
                }
                protocol Nothing: OWL.Thing {
                    /// Reads or changes the stored values of this class's properties.
                    func _withOWL_NothingValues<Result: Sendable>(_ body: (inout OWL.NothingValues) -> Result) -> Result

                    /// Reads or changes the stored values of ``OWL/Thing``.
                    func _withOWL_ThingValues<Result: Sendable>(_ body: (inout OWL.ThingValues) -> Result) -> Result

                    /// Reads or changes the stored values of ``RDFS/Resource``.
                    func _withRDFS_ResourceValues<Result: Sendable>(_ body: (inout RDFS.ResourceValues) -> Result) -> Result
                }

                /// The stored property values of an individual of ``OWL/Nothing``.
                public struct NothingValues: Sendable {
                    var _OWL_Thing = OWL.ThingValues()
                    var _RDFS_Resource = RDFS.ResourceValues()

                    /// No values.
                    public init() {
                    }
                }
            }

            extension Thing {
                func _withRDFS_ResourceValues<Result: Sendable>(_ body: (inout RDFS.ResourceValues) -> Result) -> Result {
                    _withOWL_ThingValues {
                        body(&$0._RDFS_Resource)
                    }
                }
            }

            extension Nothing {
                func _withOWL_ThingValues<Result: Sendable>(_ body: (inout OWL.ThingValues) -> Result) -> Result {
                    _withOWL_NothingValues {
                        body(&$0._OWL_Thing)
                    }
                }

                func _withRDFS_ResourceValues<Result: Sendable>(_ body: (inout RDFS.ResourceValues) -> Result) -> Result {
                    _withOWL_NothingValues {
                        body(&$0._RDFS_Resource)
                    }
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
                        Type(OWL.Nothing)
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
                                RDFS.subClassOf<Zoo.Animl>()
                            }
                    RDFCore.Class("AnimalIndividual")
                    RDFCore.Individual("rex") {
                                RDF.type<OWL.Nothing>()
                            }
                    RDFCore.Datatype("Weight")
                    RDFCore.Property("heavier") {
                                RDF.type<OWL.FunctionalProperty>()
                                RDFS.domain<Zoo.Weight>()
                                RDFS.range<Zoo.Weight>()
                            }
                }
                protocol Animal: RDFS.Resource {
                    /// Reads or changes the stored values of this class's properties.
                    func _withZoo_AnimalValues<Result: Sendable>(_ body: (inout Zoo.AnimalValues) -> Result) -> Result

                    /// Reads or changes the stored values of ``RDFS/Resource``.
                    func _withRDFS_ResourceValues<Result: Sendable>(_ body: (inout RDFS.ResourceValues) -> Result) -> Result
                }

                /// The stored property values of an individual of ``Zoo/Animal``.
                public struct AnimalValues: Sendable {
                    var _RDFS_Resource = RDFS.ResourceValues()

                    /// No values.
                    public init() {
                    }
                }
                protocol Keeper: RDFS.Resource {
                    /// Reads or changes the stored values of this class's properties.
                    func _withZoo_KeeperValues<Result: Sendable>(_ body: (inout Zoo.KeeperValues) -> Result) -> Result

                    /// Reads or changes the stored values of ``RDFS/Resource``.
                    func _withRDFS_ResourceValues<Result: Sendable>(_ body: (inout RDFS.ResourceValues) -> Result) -> Result
                }

                /// The stored property values of an individual of ``Zoo/Keeper``.
                public struct KeeperValues: Sendable {
                    var _RDFS_Resource = RDFS.ResourceValues()

                    /// No values.
                    public init() {
                    }
                }

                /// An individual of ``Zoo/Keeper``.
                public final class KeeperIndividual: Zoo.Keeper {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#Keeper", name: "Keeper")

                    private let storage: RDFCore.IndividualStorage<Zoo.KeeperValues>

                    /// Creates an individual with these property values.
                    public init() {
                        storage = RDFCore.IndividualStorage(Zoo.KeeperValues())
                    }

                    /// Reads or changes this individual's property values while holding its lock.
                    public func _withZoo_KeeperValues<Result: Sendable>(_ body: (inout Zoo.KeeperValues) -> Result) -> Result {
                        storage.withLock(body)
                    }
                }
                protocol AnimalIndividual: RDFS.Resource {
                    /// Reads or changes the stored values of this class's properties.
                    func _withZoo_AnimalIndividualValues<Result: Sendable>(_ body: (inout Zoo.AnimalIndividualValues) -> Result) -> Result

                    /// Reads or changes the stored values of ``RDFS/Resource``.
                    func _withRDFS_ResourceValues<Result: Sendable>(_ body: (inout RDFS.ResourceValues) -> Result) -> Result
                }

                /// The stored property values of an individual of ``Zoo/AnimalIndividual``.
                public struct AnimalIndividualValues: Sendable {
                    var _RDFS_Resource = RDFS.ResourceValues()

                    /// No values.
                    public init() {
                    }
                }

                /// An individual of ``Zoo/AnimalIndividual``.
                public final class AnimalIndividualIndividual: Zoo.AnimalIndividual {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#AnimalIndividual", name: "AnimalIndividual")

                    private let storage: RDFCore.IndividualStorage<Zoo.AnimalIndividualValues>

                    /// Creates an individual with these property values.
                    public init() {
                        storage = RDFCore.IndividualStorage(Zoo.AnimalIndividualValues())
                    }

                    /// Reads or changes this individual's property values while holding its lock.
                    public func _withZoo_AnimalIndividualValues<Result: Sendable>(_ body: (inout Zoo.AnimalIndividualValues) -> Result) -> Result {
                        storage.withLock(body)
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

            extension Animal {
                func _withRDFS_ResourceValues<Result: Sendable>(_ body: (inout RDFS.ResourceValues) -> Result) -> Result {
                    _withZoo_AnimalValues {
                        body(&$0._RDFS_Resource)
                    }
                }
            }

            extension Keeper {
                func _withRDFS_ResourceValues<Result: Sendable>(_ body: (inout RDFS.ResourceValues) -> Result) -> Result {
                    _withZoo_KeeperValues {
                        body(&$0._RDFS_Resource)
                    }
                }
            }

            extension AnimalIndividual {
                func _withRDFS_ResourceValues<Result: Sendable>(_ body: (inout RDFS.ResourceValues) -> Result) -> Result {
                    _withZoo_AnimalIndividualValues {
                        body(&$0._RDFS_Resource)
                    }
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "'Zoo.Animl' is not declared in Zoo", line: 7, column: 13),
                DiagnosticSpec(message: "'AnimalIndividual' is declared in this ontology, so the type @Ontology generates for 'Animal' cannot use that name", line: 5, column: 9),
                DiagnosticSpec(message: "'OWL.Nothing' is not a class with individuals; write a class protocol with its ontology, such as OWL.Thing, and not owl:Nothing or a datatype", line: 11, column: 13),
                DiagnosticSpec(message: "'heavier' has at most one 'Weight', which would make the value type 'Weight' contain itself; make the property many-valued", line: 14, column: 9),
            ]
        )
    }
}
