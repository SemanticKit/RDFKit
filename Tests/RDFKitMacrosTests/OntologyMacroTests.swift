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
                protocol Keeper: Zoo.Animal {
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
                var name: RDFCore.PropertyValue<RDFS.Literal> {
                    RDFCore.PropertyValue(\\Self.name, of: membership)
                }
            }

            extension Keeper where Self: RDFCore.StoredIndividual {
                var feeds: RDFCore.PropertyValues<any Zoo.Animal> {
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
                                RDFS.subClassOf<Zoo.Keeper>()
                                RDFS.subClassOf<Zoo.Vet>()
                            }
                    RDFCore.Individual("rex") {
                                RDF.type<Zoo.Keeper>()
                                RDF.type<Zoo.Vet>()
                            }
                }
                protocol Keeper: RDFS.Resource {
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
                protocol Vet: RDFS.Resource {
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
                protocol KeeperVet: Zoo.Keeper, Zoo.Vet {
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

    @Test("Datatypes store literals; a class can refine another ontology's class")
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
                protocol Animal: OWL.Thing {
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
                var weight: RDFCore.PropertyValue<Units.Kilograms> {
                    RDFCore.PropertyValue(\\Self.weight, of: membership)
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
                protocol Resource: RDFCore.Resource, RDF.Extending, OWL.Extending {
                    var label: RDFCore.PropertyValues<RDFS.Literal> {
                        get
                    }

                    var seeAlso: RDFCore.PropertyValues<any RDFS.Resource> {
                        get
                    }
                }

                /// An individual of ``RDFS/Resource``.
                public final class ResourceIndividual: RDFS.Resource, RDFCore.StoredIndividual {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "http://www.w3.org/2000/01/rdf-schema#Resource", name: "Resource")

                    /// This individual's place in its graph, which stores its property values.
                    public let membership: RDFCore.Membership

                    private init(membership: RDFCore.Membership) {
                        self.membership = membership
                    }

                    /// Creates an individual in a graph, with these property values.
                    public convenience init(in graph: RDFCore.IndividualGraph, label: [RDFS.Literal] = [], seeAlso: [any RDFS.Resource] = []) {
                        self.init(membership: RDFCore.Membership(in: graph) {
                                ResourceIndividual(membership: $0)
                            })
                        graph.insert(self)
                        self.label.append(contentsOf: label)
                        self.seeAlso.append(contentsOf: seeAlso)
                    }
                }
                protocol Class: RDFS.Resource {
                    var subClassOf: RDFCore.PropertyValues<any RDFS.Class> {
                        get
                    }
                }

                /// An individual of ``RDFS/Class``.
                public final class ClassIndividual: RDFS.Class, RDFCore.StoredIndividual {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "http://www.w3.org/2000/01/rdf-schema#Class", name: "Class")

                    /// This individual's place in its graph, which stores its property values.
                    public let membership: RDFCore.Membership

                    private init(membership: RDFCore.Membership) {
                        self.membership = membership
                    }

                    /// Creates an individual in a graph, with these property values.
                    public convenience init(in graph: RDFCore.IndividualGraph, label: [RDFS.Literal] = [], seeAlso: [any RDFS.Resource] = [], subClassOf: [any RDFS.Class] = []) {
                        self.init(membership: RDFCore.Membership(in: graph) {
                                ClassIndividual(membership: $0)
                            })
                        graph.insert(self)
                        self.label.append(contentsOf: label)
                        self.seeAlso.append(contentsOf: seeAlso)
                        self.subClassOf.append(contentsOf: subClassOf)
                    }
                }

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
                    public typealias Range = RDFS.Literal
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

            extension Resource where Self: RDFCore.StoredIndividual {
                var label: RDFCore.PropertyValues<RDFS.Literal> {
                    RDFCore.PropertyValues(\\Self.label, of: membership)
                }

                var seeAlso: RDFCore.PropertyValues<any RDFS.Resource> {
                    RDFCore.PropertyValues(\\Self.seeAlso, of: membership)
                }
            }

            extension Class where Self: RDFCore.StoredIndividual {
                var subClassOf: RDFCore.PropertyValues<any RDFS.Class> {
                    RDFCore.PropertyValues(\\Self.subClassOf, of: membership)
                }
            }
            """
        )
    }

    @Test("Properties for other ontologies' classes, and individuals of several of them")
    func foreignDomainsAndClasses() {
        assertExpansion(
            """
            @Ontology
            public struct Kin: Ontology {
                public func content() -> Content {
                    Namespace("https://kin.example.org/#")
                    Class("Relation") {
                        SubClassOf(OWL.TransitiveProperty)
                        SubClassOf(OWL.SymmetricProperty)
                    }
                    Individual("relativeOf") {
                        Type(OWL.TransitiveProperty)
                        Type(OWL.SymmetricProperty)
                    }
                    Property("inverseName") {
                        Comment("The name of the relation read backwards.")
                        Domain(RDF.Property)
                        Range(RDFS.Literal)
                    }
                    Property("closeTo") {
                        Domain(Kin.Relation)
                        Range(Kin.Relation)
                    }
                }
            }
            """,
            expandedSource: """
            public struct Kin: Ontology {
                public func content() -> Content {
                    Namespace("https://kin.example.org/#")
                    RDFCore.Class("Relation") {
                                RDFS.subClassOf<OWL.TransitiveProperty>()
                                RDFS.subClassOf<OWL.SymmetricProperty>()
                            }
                    RDFCore.Individual("relativeOf") {
                                RDF.type<OWL.TransitiveProperty>()
                                RDF.type<OWL.SymmetricProperty>()
                            }
                    RDFCore.Property("inverseName") {
                                RDFS.comment("The name of the relation read backwards.")
                                RDFS.domain<RDF.Property>()
                                RDFS.range<RDFS.Literal>()
                            }
                    RDFCore.Property("closeTo") {
                                RDFS.domain<Kin.Relation>()
                                RDFS.range<Kin.Relation>()
                            }
                }
                public protocol Relation: OWL.TransitiveProperty, OWL.SymmetricProperty, Kin.Extending {
                    var closeTo: RDFCore.PropertyValues<any Kin.Relation> {
                        get
                    }
                }

                /// An individual of ``Kin/Relation``.
                public final class RelationIndividual: Kin.Relation, RDFCore.StoredIndividual {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://kin.example.org/#Relation", name: "Relation")

                    /// This individual's place in its graph, which stores its property values.
                    public let membership: RDFCore.Membership

                    private init(membership: RDFCore.Membership) {
                        self.membership = membership
                    }

                    /// Creates an individual in a graph, with these property values.
                    public convenience init(in graph: RDFCore.IndividualGraph, closeTo: [any Kin.Relation] = []) {
                        self.init(membership: RDFCore.Membership(in: graph) {
                                RelationIndividual(membership: $0)
                            })
                        graph.insert(self)
                        self.closeTo.append(contentsOf: closeTo)
                    }
                }

                public static let relativeOf: any OWL.TransitiveProperty & OWL.SymmetricProperty = _relativeOfIndividual()

                private final class _relativeOfIndividual: OWL.TransitiveProperty, OWL.SymmetricProperty, RDFCore.StoredIndividual {
                    fileprivate static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://kin.example.org/#relativeOf", name: "relativeOf")

                    fileprivate let membership = RDFCore.Membership.fixed()

                    fileprivate init() {
                    }
                }

                /// The name of the relation read backwards.
                public struct inverseName: RDFCore.Entity {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://kin.example.org/#inverseName", name: "inverseName", comment: "The name of the relation read backwards.")

                    /// The type this property applies to.
                    public typealias Domain = RDF.Property

                    /// The type of this property's values.
                    public typealias Range = RDFS.Literal
                }

                public struct closeTo: RDFCore.Entity {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://kin.example.org/#closeTo", name: "closeTo")

                    /// The type this property applies to.
                    public typealias Domain = any Kin.Relation

                    /// The type of this property's values.
                    public typealias Range = any Kin.Relation
                }

                /// The individuals the properties Kin declares for other ontologies' classes apply to.
                ///
                /// Each such property is a member of every individual in its domain.
                public protocol Extending: RDFCore.Resource {
                    /// The individual's place in its graph, which stores its property values.
                    var membership: RDFCore.Membership {
                        get
                    }

                    /// The name of the relation read backwards.
                    typealias _inverseName = (any RDF.Property, RDFCore.PropertyValues<RDFS.Literal>)
                }
            }

            extension Relation where Self: RDFCore.StoredIndividual {
                public var closeTo: RDFCore.PropertyValues<any Kin.Relation> {
                    RDFCore.PropertyValues(\\Self.closeTo, of: membership)
                }
            }

            extension Extending where Self: RDF.Property {
                /// The name of the relation read backwards.
                public var inverseName: RDFCore.PropertyValues<RDFS.Literal> {
                    RDFCore.PropertyValues(\\Self.inverseName, of: membership)
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
                protocol Nothing: OWL.Thing {
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
                }
                protocol Keeper: RDFS.Resource {
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
                protocol AnimalIndividual: RDFS.Resource {
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
                DiagnosticSpec(message: "'AnimalIndividual' is declared in this ontology, so the type @Ontology generates for 'Animal' cannot use that name", line: 5, column: 9),
                DiagnosticSpec(message: "'OWL.Nothing' is not a class with individuals; write a class protocol with its ontology, such as OWL.Thing, and not owl:Nothing or a datatype", line: 11, column: 13),
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
                                RDFS.comment("Declared again.")
                            }
                    RDFCore.Class("version-1")
                    RDFCore.Class("version_1")
                    RDFCore.Property("membership") {
                                RDFS.domain<Zoo.Animal>()
                                RDFS.range<Zoo.Animal>()
                            }
                }
                protocol Animal: RDFS.Resource {
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
                protocol version_1: RDFS.Resource {
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
