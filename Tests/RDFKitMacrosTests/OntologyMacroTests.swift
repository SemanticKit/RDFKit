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
                public protocol Animal: RDFCore.Resource {
                    var name: RDFCore.PropertyValue<RDFS.Literal> {
                        get
                    }
                }

                /// An individual of ``Zoo/Animal``.
                public final class AnimalIndividual: Zoo.Animal, RDFCore.StoredIndividual {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#Animal", name: "Animal", comment: "An animal.")

                    /// This individual's place in its graph, which stores its property values.
                    public let membership: RDFCore.Membership

                    private init(membership: RDFCore.Membership) {
                        self.membership = membership
                    }

                    /// Creates an individual in a graph, with these property values.
                    public convenience init(in graph: RDFCore.IndividualGraph, name: RDFS.Literal? = nil) {
                        self.init(membership: RDFCore.Membership(in: graph) {
                                AnimalIndividual(membership: $0)
                            })
                        graph.insert(self)
                        self.name.replace(with: name)
                    }
                }
                public protocol Keeper: Zoo.Animal {
                    var feeds: RDFCore.PropertyValues<any Zoo.Animal> {
                        get
                    }
                }

                /// An individual of ``Zoo/Keeper``.
                public final class KeeperIndividual: Zoo.Keeper, RDFCore.StoredIndividual {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#Keeper", name: "Keeper")

                    /// This individual's place in its graph, which stores its property values.
                    public let membership: RDFCore.Membership

                    private init(membership: RDFCore.Membership) {
                        self.membership = membership
                    }

                    /// Creates an individual in a graph, with these property values.
                    public convenience init(in graph: RDFCore.IndividualGraph, name: RDFS.Literal? = nil, feeds: [any Zoo.Animal] = []) {
                        self.init(membership: RDFCore.Membership(in: graph) {
                                KeeperIndividual(membership: $0)
                            })
                        graph.insert(self)
                        self.name.replace(with: name)
                        self.feeds.append(contentsOf: feeds)
                    }
                }

                public static let rex: any Zoo.Keeper = _rexIndividual()

                private final class _rexIndividual: Zoo.Keeper, RDFCore.StoredIndividual {
                    fileprivate static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#rex", name: "rex")

                    fileprivate let membership = RDFCore.Membership.fixed()

                    fileprivate init() {
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
                    public typealias Range = RDFS.Literal
                }
            }

            extension Animal where Self: RDFCore.StoredIndividual {
                public var name: RDFCore.PropertyValue<RDFS.Literal> {
                    RDFCore.PropertyValue(\\Self.name, of: membership)
                }
            }

            extension Keeper where Self: RDFCore.StoredIndividual {
                public var feeds: RDFCore.PropertyValues<any Zoo.Animal> {
                    RDFCore.PropertyValues(\\Self.feeds, of: membership)
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
                public protocol Keeper: RDFCore.Resource {
                }

                /// An individual of ``Zoo/Keeper``.
                public final class KeeperIndividual: Zoo.Keeper, RDFCore.StoredIndividual {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#Keeper", name: "Keeper")

                    /// This individual's place in its graph, which stores its property values.
                    public let membership: RDFCore.Membership

                    private init(membership: RDFCore.Membership) {
                        self.membership = membership
                    }

                    /// Creates an individual in a graph, with these property values.
                    public convenience init(in graph: RDFCore.IndividualGraph) {
                        self.init(membership: RDFCore.Membership(in: graph) {
                                KeeperIndividual(membership: $0)
                            })
                        graph.insert(self)
                    }
                }
                public protocol Vet: RDFCore.Resource {
                }

                /// An individual of ``Zoo/Vet``.
                public final class VetIndividual: Zoo.Vet, RDFCore.StoredIndividual {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#Vet", name: "Vet")

                    /// This individual's place in its graph, which stores its property values.
                    public let membership: RDFCore.Membership

                    private init(membership: RDFCore.Membership) {
                        self.membership = membership
                    }

                    /// Creates an individual in a graph, with these property values.
                    public convenience init(in graph: RDFCore.IndividualGraph) {
                        self.init(membership: RDFCore.Membership(in: graph) {
                                VetIndividual(membership: $0)
                            })
                        graph.insert(self)
                    }
                }
                public protocol KeeperVet: Zoo.Keeper, Zoo.Vet {
                }

                /// An individual of ``Zoo/KeeperVet``.
                public final class KeeperVetIndividual: Zoo.KeeperVet, RDFCore.StoredIndividual {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#KeeperVet", name: "KeeperVet")

                    /// This individual's place in its graph, which stores its property values.
                    public let membership: RDFCore.Membership

                    private init(membership: RDFCore.Membership) {
                        self.membership = membership
                    }

                    /// Creates an individual in a graph, with these property values.
                    public convenience init(in graph: RDFCore.IndividualGraph) {
                        self.init(membership: RDFCore.Membership(in: graph) {
                                KeeperVetIndividual(membership: $0)
                            })
                        graph.insert(self)
                    }
                }

                public static let rex: any Zoo.Keeper & Zoo.Vet = _rexIndividual()

                private final class _rexIndividual: Zoo.Keeper, Zoo.Vet, RDFCore.StoredIndividual {
                    fileprivate static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#rex", name: "rex")

                    fileprivate let membership = RDFCore.Membership.fixed()

                    fileprivate init() {
                    }
                }
            }
            """
        )
    }

    @Test("Datatypes stay value types that store their literal; a class refining another ontology's class has an individual type")
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

                public struct Kilograms: RDFCore.LiteralValue {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://units.example.org/#Kilograms", name: "Kilograms")

                    /// The lexical form of this literal.
                    public var lexicalForm: String

                    /// The language tag of this literal, if it is a language-tagged string.
                    public var languageTag: String?

                    /// The base direction of this literal, if it is a directional language-tagged string.
                    public var direction: RDFCore.TextDirection?

                    /// Creates a literal with this lexical form.
                    public init(_ lexicalForm: String, languageTag: String? = nil, direction: RDFCore.TextDirection? = nil) {
                        self.lexicalForm = lexicalForm
                        self.languageTag = languageTag
                        self.direction = direction
                    }

                    /// Creates a literal from its lexical form.
                    public init(stringLiteral lexicalForm: String) {
                        self.init(lexicalForm)
                    }
                }
                public protocol Animal: OWL.Thing {
                    var weight: RDFCore.PropertyValue<Units.Kilograms> {
                        get
                    }
                }

                /// An individual of ``Units/Animal``.
                public final class AnimalIndividual: Units.Animal, RDFCore.StoredIndividual {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://units.example.org/#Animal", name: "Animal")

                    /// This individual's place in its graph, which stores its property values.
                    public let membership: RDFCore.Membership

                    private init(membership: RDFCore.Membership) {
                        self.membership = membership
                    }

                    /// Creates an individual in a graph, with these property values.
                    public convenience init(in graph: RDFCore.IndividualGraph, weight: Units.Kilograms? = nil) {
                        self.init(membership: RDFCore.Membership(in: graph) {
                                AnimalIndividual(membership: $0)
                            })
                        graph.insert(self)
                        self.weight.replace(with: weight)
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

            extension Animal where Self: RDFCore.StoredIndividual {
                public var weight: RDFCore.PropertyValue<Units.Kilograms> {
                    RDFCore.PropertyValue(\\Self.weight, of: membership)
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
                public protocol Thing: RDFCore.Resource {
                }

                /// An individual of ``OWL/Thing``.
                public final class ThingIndividual: OWL.Thing, RDFCore.StoredIndividual {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "http://www.w3.org/2002/07/owl#Thing", name: "Thing")

                    /// This individual's place in its graph, which stores its property values.
                    public let membership: RDFCore.Membership

                    private init(membership: RDFCore.Membership) {
                        self.membership = membership
                    }

                    /// Creates an individual in a graph, with these property values.
                    public convenience init(in graph: RDFCore.IndividualGraph) {
                        self.init(membership: RDFCore.Membership(in: graph) {
                                ThingIndividual(membership: $0)
                            })
                        graph.insert(self)
                    }
                }
                public protocol Nothing: OWL.Thing {
                }
            }
            """
        )
    }

    @Test("A property of another ontology's class or of rdfs:Resource gets an accessor on its term type")
    func propertiesOfForeignDomains() {
        assertExpansion(
            """
            @Ontology
            struct Zoo: Ontology {
                func content() -> Content {
                    Namespace("https://zoo.example.org/#")
                    Property("sameSpeciesAs") {
                        Domain(OWL.Class)
                        Range(OWL.Class)
                    }
                    Property("motto") {
                        Type(RDFKit.OWL.FunctionalProperty)
                        Domain(RDFS.Resource)
                        Range(RDFS.Literal)
                    }
                    Property("bothOf") {
                        Domain(OWL.Class)
                        Domain(RDF.Property)
                    }
                    Property("label") {
                        Domain(RDFS.Literal)
                    }
                }
            }
            """,
            expandedSource: """

            struct Zoo: Ontology {
                func content() -> Content {
                    Namespace("https://zoo.example.org/#")
                    RDFCore.Property("sameSpeciesAs") {
                                Domain<OWL.Class>()
                                Range<OWL.Class>()
                            }
                    RDFCore.Property("motto") {
                                Type<RDFKit.OWL.FunctionalProperty>()
                                Domain<RDFS.Resource>()
                                Range<RDFS.Literal>()
                            }
                    RDFCore.Property("bothOf") {
                                Domain<OWL.Class>()
                                Domain<RDF.Property>()
                            }
                    RDFCore.Property("label") {
                                Domain<RDFS.Literal>()
                            }
                }

                public struct sameSpeciesAs: RDFCore.Entity {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#sameSpeciesAs", name: "sameSpeciesAs")

                    /// The type this property applies to.
                    public typealias Domain = OWL.Class

                    /// The type of this property's values.
                    public typealias Range = OWL.Class

                    /// The values of this property of an individual.
                    public static func values(of individual: some OWL.Class & RDFCore.StoredIndividual) -> RDFCore.PropertyValues<OWL.Class> {
                        propertyValues(of: individual)
                    }
                }

                public struct motto: RDFCore.Entity {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#motto", name: "motto")

                    /// The type this property applies to.
                    public typealias Domain = RDFS.Resource

                    /// The type of this property's values.
                    public typealias Range = RDFS.Literal

                    /// The value of this property of an individual.
                    public static func value(of individual: some RDFCore.StoredIndividual) -> RDFCore.PropertyValue<RDFS.Literal> {
                        propertyValue(of: individual)
                    }
                }

                public struct bothOf: RDFCore.Entity {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#bothOf", name: "bothOf")

                    /// The type this property applies to.
                    public typealias Domain = OWL.Class

                    /// The values of this property of an individual.
                    public static func values(of individual: some OWL.Class & RDF.Property & RDFCore.StoredIndividual) -> RDFCore.PropertyValues<any RDFCore.Resource> {
                        propertyValues(of: individual)
                    }
                }

                public struct label: RDFCore.Entity {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#label", name: "label")

                    /// The type this property applies to.
                    public typealias Domain = RDFS.Literal
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "'RDFS.Literal' is not a class of individuals, so no individual can have 'label'; make its domain a class", line: 19, column: 13),
            ]
        )
    }

    @Test("A property RDFCore provides checks the accessor RDFKit gives it against its declaration")
    func rdfCorePropertyAccessorIsChecked() {
        assertExpansion(
            """
            @Ontology
            struct RDFS: Ontology {
                func content() -> Content {
                    Namespace("http://www.w3.org/2000/01/rdf-schema#")
                    Class("Resource")
                    Class("Literal") {
                        SubClassOf(RDFS.Resource)
                    }
                    Property("label") {
                        Domain(RDFS.Resource)
                        Range(RDFS.Literal)
                    }
                }
            }
            """,
            expandedSource: """
            struct RDFS: Ontology {
                func content() -> Content {
                    Namespace("http://www.w3.org/2000/01/rdf-schema#")
                    RDFCore.Class("Resource")
                    RDFCore.Class("Literal") {
                                SubClassOf<RDFS.Resource>()
                            }
                    RDFCore.Property("label") {
                                Domain<RDFS.Resource>()
                                Range<RDFS.Literal>()
                            }
                }

                public typealias Resource = RDFCore.`Resource`

                public struct Literal: RDFCore.LiteralValue {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "http://www.w3.org/2000/01/rdf-schema#Literal", name: "Literal")

                    /// The lexical form of this literal.
                    public var lexicalForm: String

                    /// The language tag of this literal, if it is a language-tagged string.
                    public var languageTag: String?

                    /// The base direction of this literal, if it is a directional language-tagged string.
                    public var direction: RDFCore.TextDirection?

                    /// Creates a literal with this lexical form.
                    public init(_ lexicalForm: String, languageTag: String? = nil, direction: RDFCore.TextDirection? = nil) {
                        self.lexicalForm = lexicalForm
                        self.languageTag = languageTag
                        self.direction = direction
                    }

                    /// Creates a literal from its lexical form.
                    public init(stringLiteral lexicalForm: String) {
                        self.init(lexicalForm)
                    }
                }

                public typealias label = RDFCore.`Label`

                private static func _labelAccessor(of individual: some RDFCore.StoredIndividual) -> RDFCore.PropertyValues<RDFS.Literal> {
                    RDFS.label.values(of: individual)
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
                public protocol Animal: RDFCore.Resource {
                }
                public protocol Keeper: RDFCore.Resource {
                }

                /// An individual of ``Zoo/Keeper``.
                public final class KeeperIndividual: Zoo.Keeper, RDFCore.StoredIndividual {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#Keeper", name: "Keeper")

                    /// This individual's place in its graph, which stores its property values.
                    public let membership: RDFCore.Membership

                    private init(membership: RDFCore.Membership) {
                        self.membership = membership
                    }

                    /// Creates an individual in a graph, with these property values.
                    public convenience init(in graph: RDFCore.IndividualGraph) {
                        self.init(membership: RDFCore.Membership(in: graph) {
                                KeeperIndividual(membership: $0)
                            })
                        graph.insert(self)
                    }
                }
                public protocol AnimalIndividual: RDFCore.Resource {
                }

                /// An individual of ``Zoo/AnimalIndividual``.
                public final class AnimalIndividualIndividual: Zoo.AnimalIndividual, RDFCore.StoredIndividual {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#AnimalIndividual", name: "AnimalIndividual")

                    /// This individual's place in its graph, which stores its property values.
                    public let membership: RDFCore.Membership

                    private init(membership: RDFCore.Membership) {
                        self.membership = membership
                    }

                    /// Creates an individual in a graph, with these property values.
                    public convenience init(in graph: RDFCore.IndividualGraph) {
                        self.init(membership: RDFCore.Membership(in: graph) {
                                AnimalIndividualIndividual(membership: $0)
                            })
                        graph.insert(self)
                    }
                }

                public static let rex: any OWL.Thing = _rexIndividual()

                private final class _rexIndividual: OWL.Thing, RDFCore.StoredIndividual {
                    fileprivate static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#rex", name: "rex")

                    fileprivate let membership = RDFCore.Membership.fixed()

                    fileprivate init() {
                    }
                }

                public struct Weight: RDFCore.LiteralValue {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#Weight", name: "Weight")

                    /// The lexical form of this literal.
                    public var lexicalForm: String

                    /// The language tag of this literal, if it is a language-tagged string.
                    public var languageTag: String?

                    /// The base direction of this literal, if it is a directional language-tagged string.
                    public var direction: RDFCore.TextDirection?

                    public var heavier: Zoo.Weight?

                    /// Creates a literal with this lexical form.
                    public init(_ lexicalForm: String, languageTag: String? = nil, direction: RDFCore.TextDirection? = nil, heavier: Zoo.Weight? = nil) {
                        self.lexicalForm = lexicalForm
                        self.languageTag = languageTag
                        self.direction = direction
                        self.heavier = heavier
                    }

                    /// Creates a literal from its lexical form.
                    public init(stringLiteral lexicalForm: String) {
                        self.init(lexicalForm)
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

    @Test("Duplicate terms, colliding identifiers and the reserved property name are reported at the authored declaration")
    func declarationDiagnostics() {
        assertExpansion(
            """
            @Ontology
            struct Zoo: Ontology {
                func content() -> Content {
                    Namespace("https://zoo.example.org/#")
                    Class("Animal")
                    Class("Animal") {
                        Comment("Declared again.")
                    }
                    Class("version-1")
                    Class("version_1")
                    Property("membership") {
                        Domain(Zoo.Animal)
                        Range(Zoo.Animal)
                    }
                }
            }
            """,
            expandedSource: """
            struct Zoo: Ontology {
                func content() -> Content {
                    Namespace("https://zoo.example.org/#")
                    RDFCore.Class("Animal")
                    RDFCore.Class("Animal") {
                                Comment("Declared again.")
                            }
                    RDFCore.Class("version-1")
                    RDFCore.Class("version_1")
                    RDFCore.Property("membership") {
                                Domain<Zoo.Animal>()
                                Range<Zoo.Animal>()
                            }
                }
                public protocol Animal: RDFCore.Resource {
                }

                /// An individual of ``Zoo/Animal``.
                public final class AnimalIndividual: Zoo.Animal, RDFCore.StoredIndividual {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#Animal", name: "Animal")

                    /// This individual's place in its graph, which stores its property values.
                    public let membership: RDFCore.Membership

                    private init(membership: RDFCore.Membership) {
                        self.membership = membership
                    }

                    /// Creates an individual in a graph, with these property values.
                    public convenience init(in graph: RDFCore.IndividualGraph) {
                        self.init(membership: RDFCore.Membership(in: graph) {
                                AnimalIndividual(membership: $0)
                            })
                        graph.insert(self)
                    }
                }
                public protocol version_1: RDFCore.Resource {
                }

                /// An individual of ``Zoo/version_1``.
                public final class version_1Individual: Zoo.version_1, RDFCore.StoredIndividual {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#version-1", name: "version-1")

                    /// This individual's place in its graph, which stores its property values.
                    public let membership: RDFCore.Membership

                    private init(membership: RDFCore.Membership) {
                        self.membership = membership
                    }

                    /// Creates an individual in a graph, with these property values.
                    public convenience init(in graph: RDFCore.IndividualGraph) {
                        self.init(membership: RDFCore.Membership(in: graph) {
                                version_1Individual(membership: $0)
                            })
                        graph.insert(self)
                    }
                }

                public struct membership: RDFCore.Entity {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#membership", name: "membership")

                    /// The type this property applies to.
                    public typealias Domain = any Zoo.Animal

                    /// The type of this property's values.
                    public typealias Range = any Zoo.Animal
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "'Animal' is already declared in this ontology", line: 6, column: 9),
                DiagnosticSpec(message: "'version_1' and 'version-1' would both be the Swift type 'version_1'; rename one of them", line: 10, column: 9),
                DiagnosticSpec(message: "Individuals keep their place in their graph as 'membership', so a property with a class as its domain cannot be named 'membership'", line: 11, column: 9),
            ]
        )
    }
}
