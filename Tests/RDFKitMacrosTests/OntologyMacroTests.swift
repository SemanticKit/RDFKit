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
                var body: some Content {
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
                var body: some Content {
                    #sourceLocation(file: "test.swift", line: 4)
                    Namespace("https://zoo.example.org/#")
                    #sourceLocation(file: "test.swift", line: 5)
                    RDFCore.Class("Animal") {
                                Comment("An animal.")
                            }
                    #sourceLocation(file: "test.swift", line: 8)
                    RDFCore.Class("Keeper") {

                            }
                    #sourceLocation(file: "test.swift", line: 11)
                    RDFCore.Individual("rex") {

                            }
                    #sourceLocation(file: "test.swift", line: 14)
                    RDFCore.Property("feeds") {


                            }
                    #sourceLocation(file: "test.swift", line: 18)
                    RDFCore.Property("name") {



                            }
                    #sourceLocation()
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

                /// The values of the properties of ``Zoo/Animal`` that an individual stores.
                public struct AnimalValues: RDFCore.ClassValues {
                    public var name: String? = nil

                    public init() {
                    }
                }

                /// An individual of ``Zoo/Animal`` that stores the values of its
                /// classes in an ``RDFCore/IndividualStorage`` of ``RDFCore/IndividualValues``.
                /// An individual of another ontology typed with the class conforms to it.
                public protocol AnimalStoring: Zoo.Animal, RDFCore.ClassValuesStoring {
                    var name: String? {
                        get
                        set
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

                /// The values of the properties of ``Zoo/Keeper`` that an individual stores.
                public struct KeeperValues: RDFCore.ClassValues {
                    public var feeds: [any Zoo.Animal] = []

                    public init() {
                    }
                }

                /// An individual of ``Zoo/Keeper`` that stores the values of its
                /// classes in an ``RDFCore/IndividualStorage`` of ``RDFCore/IndividualValues``.
                /// An individual of another ontology typed with the class conforms to it.
                public protocol KeeperStoring: Zoo.Keeper, Zoo.AnimalStoring {
                    var feeds: [any Zoo.Animal] {
                        get
                        set
                    }
                }

                public static let rex: any Zoo.Keeper = _rexIndividual()

                private final class _rexIndividual: Zoo.KeeperStoring {
                    fileprivate static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#rex", name: "rex")

                    private let values = RDFCore.IndividualStorage(RDFCore.IndividualValues())

                    fileprivate init() {
                    }

                    /// Reads or changes this individual's values of one class under its lock.
                    fileprivate func withClassValues<Values: RDFCore.ClassValues, Result: Sendable>(_ body: (inout Values) -> Result) -> Result {
                        values.withLock {
                            $0.withValues(body)
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

            extension AnimalStoring {
                public var name: String? {
                    get {
                        withClassValues { (values: inout AnimalValues) in
                            values.name
                        }
                    }
                    set {
                        withClassValues { (values: inout AnimalValues) in
                            values.name = newValue
                        }
                    }
                }
            }

            extension KeeperStoring {
                public var feeds: [any Zoo.Animal] {
                    get {
                        withClassValues { (values: inout KeeperValues) in
                            values.feeds
                        }
                    }
                    set {
                        withClassValues { (values: inout KeeperValues) in
                            values.feeds = newValue
                        }
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
                var body: some Content {
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
                var body: some Content {
                    #sourceLocation(file: "test.swift", line: 4)
                    Namespace("https://zoo.example.org/#")
                    #sourceLocation(file: "test.swift", line: 5)
                    RDFCore.Class("Keeper")
                    #sourceLocation(file: "test.swift", line: 6)
                    RDFCore.Class("Vet")
                    #sourceLocation(file: "test.swift", line: 7)
                    RDFCore.Class("KeeperVet") {


                            }
                    #sourceLocation(file: "test.swift", line: 11)
                    RDFCore.Individual("rex") {


                            }
                    #sourceLocation()
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

                /// The values of the properties of ``Zoo/Keeper`` that an individual stores.
                public struct KeeperValues: RDFCore.ClassValues {
                    public init() {
                    }
                }

                /// An individual of ``Zoo/Keeper`` that stores the values of its
                /// classes in an ``RDFCore/IndividualStorage`` of ``RDFCore/IndividualValues``.
                /// An individual of another ontology typed with the class conforms to it.
                public protocol KeeperStoring: Zoo.Keeper, RDFCore.ClassValuesStoring {
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

                /// The values of the properties of ``Zoo/Vet`` that an individual stores.
                public struct VetValues: RDFCore.ClassValues {
                    public init() {
                    }
                }

                /// An individual of ``Zoo/Vet`` that stores the values of its
                /// classes in an ``RDFCore/IndividualStorage`` of ``RDFCore/IndividualValues``.
                /// An individual of another ontology typed with the class conforms to it.
                public protocol VetStoring: Zoo.Vet, RDFCore.ClassValuesStoring {
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

                /// The values of the properties of ``Zoo/KeeperVet`` that an individual stores.
                public struct KeeperVetValues: RDFCore.ClassValues {
                    public init() {
                    }
                }

                /// An individual of ``Zoo/KeeperVet`` that stores the values of its
                /// classes in an ``RDFCore/IndividualStorage`` of ``RDFCore/IndividualValues``.
                /// An individual of another ontology typed with the class conforms to it.
                public protocol KeeperVetStoring: Zoo.KeeperVet, Zoo.KeeperStoring, Zoo.VetStoring {
                }

                public static let rex: any Zoo.Keeper & Zoo.Vet = _rexIndividual()

                private final class _rexIndividual: Zoo.KeeperStoring, Zoo.VetStoring {
                    fileprivate static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#rex", name: "rex")

                    private let values = RDFCore.IndividualStorage(RDFCore.IndividualValues())

                    fileprivate init() {
                    }

                    /// Reads or changes this individual's values of one class under its lock.
                    fileprivate func withClassValues<Values: RDFCore.ClassValues, Result: Sendable>(_ body: (inout Values) -> Result) -> Result {
                        values.withLock {
                            $0.withValues(body)
                        }
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
                var body: some Content {
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
                var body: some Content {
                    #sourceLocation(file: "test.swift", line: 4)
                    Namespace("https://units.example.org/#")
                    #sourceLocation(file: "test.swift", line: 5)
                    RDFCore.Datatype("Kilograms") {

                            }
                    #sourceLocation(file: "test.swift", line: 8)
                    RDFCore.Class("Animal") {

                            }
                    #sourceLocation(file: "test.swift", line: 11)
                    RDFCore.Property("weight") {



                            }
                    #sourceLocation()
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

                /// The values of the properties of ``Units/Animal`` that an individual stores.
                public struct AnimalValues: RDFCore.ClassValues {
                    public var weight: Units.Kilograms? = nil

                    public init() {
                    }
                }

                /// An individual of ``Units/Animal`` that stores the values of its
                /// classes in an ``RDFCore/IndividualStorage`` of ``RDFCore/IndividualValues``.
                /// An individual of another ontology typed with the class conforms to it.
                public protocol AnimalStoring: Units.Animal, OWL.ThingStoring {
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

            extension AnimalStoring {
                public var weight: Units.Kilograms? {
                    get {
                        withClassValues { (values: inout AnimalValues) in
                            values.weight
                        }
                    }
                    set {
                        withClassValues { (values: inout AnimalValues) in
                            values.weight = newValue
                        }
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
                var body: some Content {
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
                var body: some Content {
                    #sourceLocation(file: "test.swift", line: 4)
                    Namespace("http://www.w3.org/2002/07/owl#")
                    #sourceLocation(file: "test.swift", line: 5)
                    RDFCore.Class("Thing")
                    #sourceLocation(file: "test.swift", line: 6)
                    RDFCore.Class("Nothing") {

                            }
                    #sourceLocation()
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

                /// The values of the properties of ``OWL/Thing`` that an individual stores.
                public struct ThingValues: RDFCore.ClassValues {
                    public init() {
                    }
                }

                /// An individual of ``OWL/Thing`` that stores the values of its
                /// classes in an ``RDFCore/IndividualStorage`` of ``RDFCore/IndividualValues``.
                /// An individual of another ontology typed with the class conforms to it.
                public protocol ThingStoring: OWL.Thing, RDFCore.ClassValuesStoring {
                }

                public protocol Nothing: OWL.Thing {
                }

                /// The values of the properties of ``OWL/Nothing`` that an individual stores.
                public struct NothingValues: RDFCore.ClassValues {
                    public init() {
                    }
                }

                /// An individual of ``OWL/Nothing`` that stores the values of its
                /// classes in an ``RDFCore/IndividualStorage`` of ``RDFCore/IndividualValues``.
                /// An individual of another ontology typed with the class conforms to it.
                public protocol NothingStoring: OWL.Nothing, OWL.ThingStoring {
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
                var body: some Content {
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
                var body: some Content {
                    #sourceLocation(file: "test.swift", line: 4)
                    Namespace("https://zoo.example.org/#")
                    #sourceLocation(file: "test.swift", line: 5)
                    RDFCore.Class("Animal")
                    #sourceLocation(file: "test.swift", line: 6)
                    RDFCore.Class("Keeper") {

                            }
                    #sourceLocation(file: "test.swift", line: 9)
                    RDFCore.Class("AnimalIndividual")
                    #sourceLocation(file: "test.swift", line: 10)
                    RDFCore.Individual("rex") {

                            }
                    #sourceLocation(file: "test.swift", line: 13)
                    RDFCore.Datatype("Weight")
                    #sourceLocation(file: "test.swift", line: 14)
                    RDFCore.Property("heavier") {



                            }
                    #sourceLocation()
                }

                public protocol Animal: RDFCore.Resource {
                }

                /// The values of the properties of ``Zoo/Animal`` that an individual stores.
                public struct AnimalValues: RDFCore.ClassValues {
                    public init() {
                    }
                }

                /// An individual of ``Zoo/Animal`` that stores the values of its
                /// classes in an ``RDFCore/IndividualStorage`` of ``RDFCore/IndividualValues``.
                /// An individual of another ontology typed with the class conforms to it.
                public protocol AnimalStoring: Zoo.Animal, RDFCore.ClassValuesStoring {
                }

                public protocol Keeper: RDFCore.Resource {
                }

                /// The values of the properties of ``Zoo/Keeper`` that an individual stores.
                public struct KeeperValues: RDFCore.ClassValues {
                    public init() {
                    }
                }

                /// An individual of ``Zoo/Keeper`` that stores the values of its
                /// classes in an ``RDFCore/IndividualStorage`` of ``RDFCore/IndividualValues``.
                /// An individual of another ontology typed with the class conforms to it.
                public protocol KeeperStoring: Zoo.Keeper, RDFCore.ClassValuesStoring {
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

                /// The values of the properties of ``Zoo/AnimalIndividual`` that an individual stores.
                public struct AnimalIndividualValues: RDFCore.ClassValues {
                    public init() {
                    }
                }

                /// An individual of ``Zoo/AnimalIndividual`` that stores the values of its
                /// classes in an ``RDFCore/IndividualStorage`` of ``RDFCore/IndividualValues``.
                /// An individual of another ontology typed with the class conforms to it.
                public protocol AnimalIndividualStoring: Zoo.AnimalIndividual, RDFCore.ClassValuesStoring {
                }

                public static let rex: any OWL.Thing = _rexIndividual()

                private final class _rexIndividual: OWL.ThingStoring {
                    fileprivate static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#rex", name: "rex")

                    private let values = RDFCore.IndividualStorage(RDFCore.IndividualValues())

                    fileprivate init() {
                    }

                    /// Reads or changes this individual's values of one class under its lock.
                    fileprivate func withClassValues<Values: RDFCore.ClassValues, Result: Sendable>(_ body: (inout Values) -> Result) -> Result {
                        values.withLock {
                            $0.withValues(body)
                        }
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
                DiagnosticSpec(message: "'heavier' has at most one 'Weight', which would make the value type 'Weight' contain itself; make the property many-valued", line: 14, column: 9),
            ]
        )
    }

    @Test("A named individual may be typed with another ontology's class")
    func individualOfAnotherOntologysClass() {
        assertExpansion(
            """
            @Ontology
            struct Entailment: Ontology {
                var body: some Content {
                    Namespace("http://www.w3.org/ns/entailment/")
                    Individual("RDFS") {
                        Type(ServiceDescription.EntailmentRegime)
                        Label("RDFS entailment")
                    }
                }
            }
            """,
            expandedSource: """
            struct Entailment: Ontology {
                var body: some Content {
                    #sourceLocation(file: "test.swift", line: 4)
                    Namespace("http://www.w3.org/ns/entailment/")
                    #sourceLocation(file: "test.swift", line: 5)
                    RDFCore.Individual("RDFS") {

                                Label("RDFS entailment")
                            }
                    #sourceLocation()
                }

                public static let RDFS: any ServiceDescription.EntailmentRegime = _RDFSIndividual()

                private final class _RDFSIndividual: ServiceDescription.EntailmentRegimeStoring {
                    fileprivate static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "http://www.w3.org/ns/entailment/RDFS", name: "RDFS", label: "RDFS entailment")

                    private let values = RDFCore.IndividualStorage(RDFCore.IndividualValues())

                    fileprivate init() {
                    }

                    /// Reads or changes this individual's values of one class under its lock.
                    fileprivate func withClassValues<Values: RDFCore.ClassValues, Result: Sendable>(_ body: (inout Values) -> Result) -> Result {
                        values.withLock {
                            $0.withValues(body)
                        }
                    }
                }
            }
            """
        )
    }

    /// The rejected spelling, assembled so that no source file in the
    /// package contains it.
    static let contentFunction = "func " + "content()"

    @Test("Content written as a function is an error with a fix-it to var body")
    func contentFunctionIsAnError() {
        assertExpansion(
            """
            @Ontology
            public struct Zoo: Ontology {
                public \(Self.contentFunction) -> Content {
                    Namespace("https://zoo.example.org/#")
                    Class("Animal")
                }
            }
            """,
            expandedSource: """
            public struct Zoo: Ontology {
                public \(Self.contentFunction) -> Content {
                    Namespace("https://zoo.example.org/#")
                    Class("Animal")
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "Write the ontology's content in 'var body: some Content', as a SwiftUI view's body; @Ontology does not read a 'content()' function",
                    line: 3, column: 17,
                    fixIts: [FixItSpec(message: "Write 'var body: some Content'")]
                ),
            ],
            applyFixIts: ["Write 'var body: some Content'"],
            fixedSource: """
            @Ontology
            public struct Zoo: Ontology {
                public var body: some Content {
                    Namespace("https://zoo.example.org/#")
                    Class("Animal")
                }
            }
            """
        )
    }

    @Test("An ontology without var body is an error")
    func missingBodyIsAnError() {
        assertExpansion(
            """
            @Ontology
            struct Zoo: Ontology {
                let name = "Zoo"
            }
            """,
            expandedSource: """
            struct Zoo: Ontology {
                let name = "Zoo"
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@Ontology requires a 'var body: some Content' with a body", line: 1, column: 1),
            ]
        )
    }
}
