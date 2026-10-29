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

                /// The values of the properties of an individual of ``Zoo/Animal``.
                final class AnimalProperties: RDFCore.PropertySet {
                    public let name = RDFCore.PropertyValue<RDFS.Literal>()

                    /// Creates the properties with no values.
                    public init() {
                    }

                    /// Removes every value.
                    public func removeAll() {
                        name.removeAll()
                    }
                }

                /// An individual of ``Zoo/Animal``.
                public final class AnimalIndividual: Zoo.Animal {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#Animal", name: "Animal", comment: "An animal.")

                    /// The values of this individual's properties.
                    public let individualProperties = RDFCore.IndividualProperties()

                    /// Creates an individual in a graph, with these property values.
                    public init(in graph: RDFCore.IndividualGraph, name: RDFS.Literal? = nil) {
                        self.name.replace(with: name)
                        graph.insert(self)
                    }
                }
                protocol Keeper: Zoo.Animal {
                    var feeds: RDFCore.PropertyValues<any Zoo.Animal> {
                        get
                    }
                }

                /// The values of the properties of an individual of ``Zoo/Keeper``.
                final class KeeperProperties: RDFCore.PropertySet {
                    public let feeds = RDFCore.PropertyValues<any Zoo.Animal>()

                    /// Creates the properties with no values.
                    public init() {
                    }

                    /// Removes every value.
                    public func removeAll() {
                        feeds.removeAll()
                    }
                }

                /// An individual of ``Zoo/Keeper``.
                public final class KeeperIndividual: Zoo.Keeper {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#Keeper", name: "Keeper")

                    /// The values of this individual's properties.
                    public let individualProperties = RDFCore.IndividualProperties()

                    /// Creates an individual in a graph, with these property values.
                    public init(in graph: RDFCore.IndividualGraph, name: RDFS.Literal? = nil, feeds: [any Zoo.Animal] = []) {
                        self.name.replace(with: name)
                        self.feeds.replace(with: feeds)
                        graph.insert(self)
                    }
                }

                public static let rex: any Zoo.Keeper = _rexIndividual()

                private final class _rexIndividual: Zoo.Keeper {
                    fileprivate static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#rex", name: "rex")

                    fileprivate let individualProperties = RDFCore.IndividualProperties()

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

            extension Animal {
                var name: RDFCore.PropertyValue<RDFS.Literal> {
                    individualProperties[\\AnimalProperties.name]
                }
            }

            extension Keeper {
                var feeds: RDFCore.PropertyValues<any Zoo.Animal> {
                    individualProperties[\\KeeperProperties.feeds]
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
                public final class KeeperIndividual: Zoo.Keeper {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#Keeper", name: "Keeper")

                    /// The values of this individual's properties.
                    public let individualProperties = RDFCore.IndividualProperties()

                    /// Creates an individual in a graph, with these property values.
                    public init(in graph: RDFCore.IndividualGraph) {
                        graph.insert(self)
                    }
                }
                protocol Vet: RDFS.Resource {
                }

                /// An individual of ``Zoo/Vet``.
                public final class VetIndividual: Zoo.Vet {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#Vet", name: "Vet")

                    /// The values of this individual's properties.
                    public let individualProperties = RDFCore.IndividualProperties()

                    /// Creates an individual in a graph, with these property values.
                    public init(in graph: RDFCore.IndividualGraph) {
                        graph.insert(self)
                    }
                }
                protocol KeeperVet: Zoo.Keeper, Zoo.Vet {
                }

                /// An individual of ``Zoo/KeeperVet``.
                public final class KeeperVetIndividual: Zoo.KeeperVet {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#KeeperVet", name: "KeeperVet")

                    /// The values of this individual's properties.
                    public let individualProperties = RDFCore.IndividualProperties()

                    /// Creates an individual in a graph, with these property values.
                    public init(in graph: RDFCore.IndividualGraph) {
                        graph.insert(self)
                    }
                }

                public static let rex: any Zoo.Keeper & Zoo.Vet = _rexIndividual()

                private final class _rexIndividual: Zoo.Keeper, Zoo.Vet {
                    fileprivate static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#rex", name: "rex")

                    fileprivate let individualProperties = RDFCore.IndividualProperties()

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

                /// The values of the properties of an individual of ``Units/Animal``.
                final class AnimalProperties: RDFCore.PropertySet {
                    public let weight = RDFCore.PropertyValue<Units.Kilograms>()

                    /// Creates the properties with no values.
                    public init() {
                    }

                    /// Removes every value.
                    public func removeAll() {
                        weight.removeAll()
                    }
                }

                /// An individual of ``Units/Animal``.
                public final class AnimalIndividual: Units.Animal {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://units.example.org/#Animal", name: "Animal")

                    /// The values of this individual's properties.
                    public let individualProperties = RDFCore.IndividualProperties()

                    /// Creates an individual in a graph, with these property values.
                    public init(in graph: RDFCore.IndividualGraph, weight: Units.Kilograms? = nil) {
                        self.weight.replace(with: weight)
                        graph.insert(self)
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
                var weight: RDFCore.PropertyValue<Units.Kilograms> {
                    individualProperties[\\AnimalProperties.weight]
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
                protocol Resource: RDFCore.IndividualObject, RDF.Extending, OWL.Extending {
                    var label: RDFCore.PropertyValues<RDFS.Literal> {
                        get
                    }

                    var seeAlso: RDFCore.PropertyValues<any RDFS.Resource> {
                        get
                    }
                }

                /// The values of the properties of an individual of ``RDFS/Resource``.
                final class ResourceProperties: RDFCore.PropertySet {
                    public let label = RDFCore.PropertyValues<RDFS.Literal>()

                    public let seeAlso = RDFCore.PropertyValues<any RDFS.Resource>()

                    /// Creates the properties with no values.
                    public init() {
                    }

                    /// Removes every value.
                    public func removeAll() {
                        label.removeAll()
                        seeAlso.removeAll()
                    }
                }

                /// An individual of ``RDFS/Resource``.
                public final class ResourceIndividual: RDFS.Resource {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "http://www.w3.org/2000/01/rdf-schema#Resource", name: "Resource")

                    /// The values of this individual's properties.
                    public let individualProperties = RDFCore.IndividualProperties()

                    /// Creates an individual in a graph, with these property values.
                    public init(in graph: RDFCore.IndividualGraph, label: [RDFS.Literal] = [], seeAlso: [any RDFS.Resource] = []) {
                        self.label.replace(with: label)
                        self.seeAlso.replace(with: seeAlso)
                        graph.insert(self)
                    }
                }
                protocol Class: RDFS.Resource {
                    var subClassOf: RDFCore.PropertyValues<any RDFS.Class> {
                        get
                    }
                }

                /// The values of the properties of an individual of ``RDFS/Class``.
                final class ClassProperties: RDFCore.PropertySet {
                    public let subClassOf = RDFCore.PropertyValues<any RDFS.Class>()

                    /// Creates the properties with no values.
                    public init() {
                    }

                    /// Removes every value.
                    public func removeAll() {
                        subClassOf.removeAll()
                    }
                }

                /// An individual of ``RDFS/Class``.
                public final class ClassIndividual: RDFS.Class {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "http://www.w3.org/2000/01/rdf-schema#Class", name: "Class")

                    /// The values of this individual's properties.
                    public let individualProperties = RDFCore.IndividualProperties()

                    /// Creates an individual in a graph, with these property values.
                    public init(in graph: RDFCore.IndividualGraph, label: [RDFS.Literal] = [], seeAlso: [any RDFS.Resource] = [], subClassOf: [any RDFS.Class] = []) {
                        self.label.replace(with: label)
                        self.seeAlso.replace(with: seeAlso)
                        self.subClassOf.replace(with: subClassOf)
                        graph.insert(self)
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

            extension Resource {
                var label: RDFCore.PropertyValues<RDFS.Literal> {
                    individualProperties[\\ResourceProperties.label]
                }

                var seeAlso: RDFCore.PropertyValues<any RDFS.Resource> {
                    individualProperties[\\ResourceProperties.seeAlso]
                }
            }

            extension Class {
                var subClassOf: RDFCore.PropertyValues<any RDFS.Class> {
                    individualProperties[\\ClassProperties.subClassOf]
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

                /// The values of the properties of an individual of ``Kin/Relation``.
                public final class RelationProperties: RDFCore.PropertySet {
                    public let closeTo = RDFCore.PropertyValues<any Kin.Relation>()

                    /// Creates the properties with no values.
                    public init() {
                    }

                    /// Removes every value.
                    public func removeAll() {
                        closeTo.removeAll()
                    }
                }

                /// An individual of ``Kin/Relation``.
                public final class RelationIndividual: Kin.Relation {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://kin.example.org/#Relation", name: "Relation")

                    /// The values of this individual's properties.
                    public let individualProperties = RDFCore.IndividualProperties()

                    /// Creates an individual in a graph, with these property values.
                    public init(in graph: RDFCore.IndividualGraph, closeTo: [any Kin.Relation] = []) {
                        self.closeTo.replace(with: closeTo)
                        graph.insert(self)
                    }
                }

                public static let relativeOf: any OWL.TransitiveProperty & OWL.SymmetricProperty = _relativeOfIndividual()

                private final class _relativeOfIndividual: OWL.TransitiveProperty, OWL.SymmetricProperty {
                    fileprivate static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://kin.example.org/#relativeOf", name: "relativeOf")

                    fileprivate let individualProperties = RDFCore.IndividualProperties()

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
                /// Each property is a member of an individual in its domain.
                public protocol Extending: RDFCore.IndividualObject {
                    /// The name of the relation read backwards.
                    typealias _inverseName = (any RDF.Property, RDFCore.PropertyValues<RDFS.Literal>)
                }

                /// The values of the properties Kin declares for other ontologies' classes.
                public final class ExtendingProperties: RDFCore.PropertySet {
                    /// The name of the relation read backwards.
                    public let inverseName = RDFCore.PropertyValues<RDFS.Literal>()

                    /// Creates the properties with no values.
                    public init() {
                    }

                    /// Removes every value.
                    public func removeAll() {
                        inverseName.removeAll()
                    }
                }
            }

            extension Relation {
                public var closeTo: RDFCore.PropertyValues<any Kin.Relation> {
                    individualProperties[\\RelationProperties.closeTo]
                }
            }

            extension Extending where Self: RDF.Property {
                /// The name of the relation read backwards.
                public var inverseName: RDFCore.PropertyValues<RDFS.Literal> {
                    individualProperties[\\ExtendingProperties.inverseName]
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
                public final class ThingIndividual: OWL.Thing {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "http://www.w3.org/2002/07/owl#Thing", name: "Thing")

                    /// The values of this individual's properties.
                    public let individualProperties = RDFCore.IndividualProperties()

                    /// Creates an individual in a graph, with these property values.
                    public init(in graph: RDFCore.IndividualGraph) {
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
                public final class KeeperIndividual: Zoo.Keeper {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#Keeper", name: "Keeper")

                    /// The values of this individual's properties.
                    public let individualProperties = RDFCore.IndividualProperties()

                    /// Creates an individual in a graph, with these property values.
                    public init(in graph: RDFCore.IndividualGraph) {
                        graph.insert(self)
                    }
                }
                protocol AnimalIndividual: RDFS.Resource {
                }

                /// An individual of ``Zoo/AnimalIndividual``.
                public final class AnimalIndividualIndividual: Zoo.AnimalIndividual {
                    public static let metadata: any RDFCore.ContentMetadata = RDFCore.RDFMetadata(id: "https://zoo.example.org/#AnimalIndividual", name: "AnimalIndividual")

                    /// The values of this individual's properties.
                    public let individualProperties = RDFCore.IndividualProperties()

                    /// Creates an individual in a graph, with these property values.
                    public init(in graph: RDFCore.IndividualGraph) {
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
}
