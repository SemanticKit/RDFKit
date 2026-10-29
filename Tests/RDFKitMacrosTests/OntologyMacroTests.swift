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
                                SubClassOf<Zoo.Animal>()
                            }
                    RDFCore.Individual("rex") {
                                Type<Zoo.Keeper>()
                            }
                    RDFCore.Property("feeds") {
                                Domain<Zoo.Keeper>()
                                Range<Zoo.Animal>()
                            }
                    RDFCore.Property("name") {
                                Type<OWL.FunctionalProperty>()
                                Domain<Zoo.Animal>()
                                Range<RDFS.Literal>()
                            }
                }

                /// An animal.
                @ClassProperties
                public protocol Animal: RDFCore.Resource {
                    var name: String? {
                        get
                        set
                    }
                }

                /// An individual of ``Zoo/Animal``.
                public final class AnimalIndividual: Zoo.Animal {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#Animal", name: "Animal", comment: "An animal.")

                    /// The individual's property values.
                    public let propertyValues = RDFCore.IndividualStorage()

                    /// Creates an individual with these property values.
                    public init(name: String? = nil) {
                        propertyValues[Zoo.name()] = name
                    }

                    public var name: String? {
                        get {
                            propertyValues[Zoo.name()]
                        }
                        set {
                            propertyValues[Zoo.name()] = newValue
                        }
                    }
                }

                @ClassProperties
                public protocol Keeper: Zoo.Animal {
                    var feeds: [any Zoo.Animal] {
                        get
                        set
                    }
                }

                /// An individual of ``Zoo/Keeper``.
                public final class KeeperIndividual: Zoo.Keeper {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#Keeper", name: "Keeper")

                    /// The individual's property values.
                    public let propertyValues = RDFCore.IndividualStorage()

                    /// Creates an individual with these property values.
                    public init(name: String? = nil, feeds: [any Zoo.Animal] = []) {
                        propertyValues[Zoo.name()] = name
                        propertyValues[Zoo.feeds()] = feeds
                    }

                    public var name: String? {
                        get {
                            propertyValues[Zoo.name()]
                        }
                        set {
                            propertyValues[Zoo.name()] = newValue
                        }
                    }

                    public var feeds: [any Zoo.Animal] {
                        get {
                            propertyValues[Zoo.feeds()]
                        }
                        set {
                            propertyValues[Zoo.feeds()] = newValue
                        }
                    }
                }

                public static let rex: any Zoo.Keeper = _rexIndividual()

                private final class _rexIndividual: Zoo.Keeper {
                    fileprivate static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#rex", name: "rex")

                    /// The individual's property values.
                    fileprivate let propertyValues = RDFCore.IndividualStorage()

                    /// Creates an individual with these property values.
                    fileprivate init(name: String? = nil, feeds: [any Zoo.Animal] = []) {
                        propertyValues[Zoo.name()] = name
                        propertyValues[Zoo.feeds()] = feeds
                    }

                    fileprivate var name: String? {
                        get {
                            propertyValues[Zoo.name()]
                        }
                        set {
                            propertyValues[Zoo.name()] = newValue
                        }
                    }

                    fileprivate var feeds: [any Zoo.Animal] {
                        get {
                            propertyValues[Zoo.feeds()]
                        }
                        set {
                            propertyValues[Zoo.feeds()] = newValue
                        }
                    }
                }

                public struct feeds: RDFCore.PropertyTerm {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#feeds", name: "feeds")

                    /// The type this property applies to.
                    public typealias Domain = any Zoo.Keeper

                    /// The type of this property's values.
                    public typealias Range = any Zoo.Animal

                    /// The values one subject has for this property.
                    public typealias Value = [any Zoo.Animal]

                    /// No values.
                    public static var noValues: Value {
                        []
                    }

                    /// The property term, the key of its values in an individual's storage.
                    public init() {
                    }

                    /// The values `subject` has for this property.
                    public static subscript(subject: any Zoo.Keeper) -> Value {
                        get {
                            subject.propertyValues[Self()]
                        }
                        set {
                            subject.propertyValues[Self()] = newValue
                        }
                    }
                }

                public struct name: RDFCore.PropertyTerm {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#name", name: "name")

                    /// The type this property applies to.
                    public typealias Domain = any Zoo.Animal

                    /// The type of this property's values.
                    public typealias Range = String

                    /// The values one subject has for this property.
                    public typealias Value = String?

                    /// No values.
                    public static var noValues: Value {
                        nil
                    }

                    /// The property term, the key of its values in an individual's storage.
                    public init() {
                    }

                    /// The values `subject` has for this property.
                    public static subscript(subject: any Zoo.Animal) -> Value {
                        get {
                            subject.propertyValues[Self()]
                        }
                        set {
                            subject.propertyValues[Self()] = newValue
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
                                SubClassOf<Zoo.Keeper>()
                                SubClassOf<Zoo.Vet>()
                            }
                    RDFCore.Individual("rex") {
                                Type<Zoo.Keeper>()
                                Type<Zoo.Vet>()
                            }
                }

                @ClassProperties
                public protocol Keeper: RDFCore.Resource {
                }

                /// An individual of ``Zoo/Keeper``.
                public final class KeeperIndividual: Zoo.Keeper {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#Keeper", name: "Keeper")

                    /// The individual's property values.
                    public let propertyValues = RDFCore.IndividualStorage()

                    /// Creates an individual with these property values.
                    public init() {
                    }
                }

                @ClassProperties
                public protocol Vet: RDFCore.Resource {
                }

                /// An individual of ``Zoo/Vet``.
                public final class VetIndividual: Zoo.Vet {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#Vet", name: "Vet")

                    /// The individual's property values.
                    public let propertyValues = RDFCore.IndividualStorage()

                    /// Creates an individual with these property values.
                    public init() {
                    }
                }

                @ClassProperties
                public protocol KeeperVet: Zoo.Keeper, Zoo.Vet {
                }

                /// An individual of ``Zoo/KeeperVet``.
                public final class KeeperVetIndividual: Zoo.KeeperVet {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#KeeperVet", name: "KeeperVet")

                    /// The individual's property values.
                    public let propertyValues = RDFCore.IndividualStorage()

                    /// Creates an individual with these property values.
                    public init() {
                    }
                }

                public static let rex: any Zoo.Keeper & Zoo.Vet = _rexIndividual()

                private final class _rexIndividual: Zoo.Keeper, Zoo.Vet {
                    fileprivate static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#rex", name: "rex")

                    /// The individual's property values.
                    fileprivate let propertyValues = RDFCore.IndividualStorage()

                    /// Creates an individual with these property values.
                    fileprivate init() {
                    }
                }
            }
            """
        )
    }

    @Test("Datatypes stay value types; a class refining another ontology's class has an individual type")
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
                                SubClassOf<RDFS.Literal>()
                            }
                    RDFCore.Class("Animal") {
                                SubClassOf<OWL.Thing>()
                            }
                    RDFCore.Property("weight") {
                                Type<OWL.FunctionalProperty>()
                                Domain<Units.Animal>()
                                Range<Units.Kilograms>()
                            }
                }

                public struct Kilograms: RDFCore.Entity {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://units.example.org/#Kilograms", name: "Kilograms")

                    public init() {
                    }
                }

                @ClassProperties
                public protocol Animal: OWL.Thing {
                    var weight: Units.Kilograms? {
                        get
                        set
                    }
                }

                /// An individual of ``Units/Animal``.
                public final class AnimalIndividual: Units.Animal {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://units.example.org/#Animal", name: "Animal")

                    /// The individual's property values.
                    public let propertyValues = RDFCore.IndividualStorage()

                    /// Creates an individual with these property values.
                    public init(weight: Units.Kilograms? = nil) {
                        propertyValues[Units.weight()] = weight
                    }

                    public var weight: Units.Kilograms? {
                        get {
                            propertyValues[Units.weight()]
                        }
                        set {
                            propertyValues[Units.weight()] = newValue
                        }
                    }
                }

                public struct weight: RDFCore.PropertyTerm {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://units.example.org/#weight", name: "weight")

                    /// The type this property applies to.
                    public typealias Domain = any Units.Animal

                    /// The type of this property's values.
                    public typealias Range = Units.Kilograms

                    /// The values one subject has for this property.
                    public typealias Value = Units.Kilograms?

                    /// No values.
                    public static var noValues: Value {
                        nil
                    }

                    /// The property term, the key of its values in an individual's storage.
                    public init() {
                    }

                    /// The values `subject` has for this property.
                    public static subscript(subject: any Units.Animal) -> Value {
                        get {
                            subject.propertyValues[Self()]
                        }
                        set {
                            subject.propertyValues[Self()] = newValue
                        }
                    }
                }
            }
            """
        )
    }

    @Test("A property of another ontology's class, or of several classes, is read through its term")
    func termSubscripts() {
        assertExpansion(
            """
            @Ontology
            struct Keys: Ontology {
                func content() -> Content {
                    Namespace("https://keys.example.org/#")
                    Class("Key")
                    Class("PublicKey") {
                        SubClassOf(Keys.Key)
                    }
                    Class("Lock")
                    Property("key") {
                        Domain(Foaf.Agent)
                        Range(Keys.Key)
                        Range(Keys.PublicKey)
                    }
                    Property("size") {
                        Type(OWL.FunctionalProperty)
                        Domain(Keys.Key)
                        Domain(Keys.Lock)
                        Range(XSD.nonNegativeInteger)
                    }
                    Property("note") {
                        Range(RDFS.Literal)
                    }
                }
            }
            """,
            expandedSource: """
            struct Keys: Ontology {
                func content() -> Content {
                    Namespace("https://keys.example.org/#")
                    RDFCore.Class("Key")
                    RDFCore.Class("PublicKey") {
                                SubClassOf<Keys.Key>()
                            }
                    RDFCore.Class("Lock")
                    RDFCore.Property("key") {
                                Domain<Foaf.Agent>()
                                Range<Keys.Key>()
                                Range<Keys.PublicKey>()
                            }
                    RDFCore.Property("size") {
                                Type<OWL.FunctionalProperty>()
                                Domain<Keys.Key>()
                                Domain<Keys.Lock>()
                                Range<XSD.nonNegativeInteger>()
                            }
                    RDFCore.Property("note") {
                                Range<RDFS.Literal>()
                            }
                }

                @ClassProperties
                public protocol Key: RDFCore.Resource {
                    var size: UInt? {
                        get
                        set
                    }
                }

                /// An individual of ``Keys/Key``.
                public final class KeyIndividual: Keys.Key {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://keys.example.org/#Key", name: "Key")

                    /// The individual's property values.
                    public let propertyValues = RDFCore.IndividualStorage()

                    /// Creates an individual with these property values.
                    public init(size: UInt? = nil) {
                        propertyValues[Keys.size()] = size
                    }

                    public var size: UInt? {
                        get {
                            propertyValues[Keys.size()]
                        }
                        set {
                            propertyValues[Keys.size()] = newValue
                        }
                    }
                }

                @ClassProperties
                public protocol PublicKey: Keys.Key {
                }

                /// An individual of ``Keys/PublicKey``.
                public final class PublicKeyIndividual: Keys.PublicKey {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://keys.example.org/#PublicKey", name: "PublicKey")

                    /// The individual's property values.
                    public let propertyValues = RDFCore.IndividualStorage()

                    /// Creates an individual with these property values.
                    public init(size: UInt? = nil) {
                        propertyValues[Keys.size()] = size
                    }

                    public var size: UInt? {
                        get {
                            propertyValues[Keys.size()]
                        }
                        set {
                            propertyValues[Keys.size()] = newValue
                        }
                    }
                }

                @ClassProperties
                public protocol Lock: RDFCore.Resource {
                    var size: UInt? {
                        get
                        set
                    }
                }

                /// An individual of ``Keys/Lock``.
                public final class LockIndividual: Keys.Lock {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://keys.example.org/#Lock", name: "Lock")

                    /// The individual's property values.
                    public let propertyValues = RDFCore.IndividualStorage()

                    /// Creates an individual with these property values.
                    public init(size: UInt? = nil) {
                        propertyValues[Keys.size()] = size
                    }

                    public var size: UInt? {
                        get {
                            propertyValues[Keys.size()]
                        }
                        set {
                            propertyValues[Keys.size()] = newValue
                        }
                    }
                }

                public struct key: RDFCore.PropertyTerm {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://keys.example.org/#key", name: "key")

                    /// The type this property applies to.
                    public typealias Domain = any Foaf.Agent

                    /// The type of this property's values.
                    public typealias Range = any Keys.Key & Keys.PublicKey

                    /// The values one subject has for this property.
                    public typealias Value = [any Keys.Key & Keys.PublicKey]

                    /// No values.
                    public static var noValues: Value {
                        []
                    }

                    /// The property term, the key of its values in an individual's storage.
                    public init() {
                    }

                    /// The values `subject` has for this property.
                    public static subscript(subject: any Foaf.Agent) -> Value {
                        get {
                            subject.propertyValues[Self()]
                        }
                        set {
                            subject.propertyValues[Self()] = newValue
                        }
                    }
                }

                public struct size: RDFCore.PropertyTerm {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://keys.example.org/#size", name: "size")

                    /// The type this property applies to.
                    public typealias Domain = any Keys.Key & Keys.Lock

                    /// The type of this property's values.
                    public typealias Range = UInt

                    /// The values one subject has for this property.
                    public typealias Value = UInt?

                    /// No values.
                    public static var noValues: Value {
                        nil
                    }

                    /// The property term, the key of its values in an individual's storage.
                    public init() {
                    }

                    /// The values `subject` has for this property.
                    public static subscript(subject: any Keys.Key) -> Value {
                        get {
                            subject.propertyValues[Self()]
                        }
                        set {
                            subject.propertyValues[Self()] = newValue
                        }
                    }

                    /// The values `subject` has for this property.
                    public static subscript(subject: any Keys.Lock) -> Value {
                        get {
                            subject.propertyValues[Self()]
                        }
                        set {
                            subject.propertyValues[Self()] = newValue
                        }
                    }

                    /// The values `subject` has for this property.
                    public static subscript(subject: any Keys.Key & Keys.Lock) -> Value {
                        get {
                            subject.propertyValues[Self()]
                        }
                        set {
                            subject.propertyValues[Self()] = newValue
                        }
                    }
                }

                public struct note: RDFCore.PropertyTerm {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://keys.example.org/#note", name: "note")

                    /// The type of this property's values.
                    public typealias Range = String

                    /// The values one subject has for this property.
                    public typealias Value = [String]

                    /// No values.
                    public static var noValues: Value {
                        []
                    }

                    /// The property term, the key of its values in an individual's storage.
                    public init() {
                    }

                    /// The values `subject` has for this property.
                    public static subscript(subject: any RDFCore.Resource) -> Value {
                        get {
                            subject.propertyValues[Self()]
                        }
                        set {
                            subject.propertyValues[Self()] = newValue
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
                                SubClassOf<OWL.Thing>()
                            }
                }

                @ClassProperties
                public protocol Thing: RDFCore.Resource {
                }

                /// An individual of ``OWL/Thing``.
                public final class ThingIndividual: OWL.Thing {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "http://www.w3.org/2002/07/owl#Thing", name: "Thing")

                    /// The individual's property values.
                    public let propertyValues = RDFCore.IndividualStorage()

                    /// Creates an individual with these property values.
                    public init() {
                    }
                }

                @ClassProperties
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
                                SubClassOf<Zoo.Animl>()
                            }
                    RDFCore.Class("AnimalIndividual")
                    RDFCore.Individual("rex") {
                                Type<OWL.Thing>()
                            }
                    RDFCore.Datatype("Weight")
                    RDFCore.Property("heavier") {
                                Type<OWL.FunctionalProperty>()
                                Domain<Zoo.Weight>()
                                Range<Zoo.Weight>()
                            }
                }

                @ClassProperties
                public protocol Animal: RDFCore.Resource {
                }

                @ClassProperties
                public protocol Keeper: RDFCore.Resource {
                }

                /// An individual of ``Zoo/Keeper``.
                public final class KeeperIndividual: Zoo.Keeper {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#Keeper", name: "Keeper")

                    /// The individual's property values.
                    public let propertyValues = RDFCore.IndividualStorage()

                    /// Creates an individual with these property values.
                    public init() {
                    }
                }

                @ClassProperties
                public protocol AnimalIndividual: RDFCore.Resource {
                }

                /// An individual of ``Zoo/AnimalIndividual``.
                public final class AnimalIndividualIndividual: Zoo.AnimalIndividual {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#AnimalIndividual", name: "AnimalIndividual")

                    /// The individual's property values.
                    public let propertyValues = RDFCore.IndividualStorage()

                    /// Creates an individual with these property values.
                    public init() {
                    }
                }

                public static let rex: any OWL.Thing = _rexIndividual()

                private final class _rexIndividual: OWL.Thing {
                    fileprivate static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#rex", name: "rex")

                    /// The individual's property values.
                    fileprivate let propertyValues = RDFCore.IndividualStorage()

                    /// Creates an individual with these property values.
                    fileprivate init() {
                    }
                }

                public struct Weight: RDFCore.Entity {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#Weight", name: "Weight")

                    public var heavier: Zoo.Weight?

                    public init(heavier: Zoo.Weight? = nil) {
                        self.heavier = heavier
                    }
                }

                public struct heavier: RDFCore.PropertyTerm {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#heavier", name: "heavier")

                    /// The type this property applies to.
                    public typealias Domain = Zoo.Weight

                    /// The type of this property's values.
                    public typealias Range = Zoo.Weight

                    /// The values one subject has for this property.
                    public typealias Value = Zoo.Weight?

                    /// No values.
                    public static var noValues: Value {
                        nil
                    }

                    /// The property term, the key of its values in an individual's storage.
                    public init() {
                    }
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
}
