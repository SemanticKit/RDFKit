import SwiftSyntaxMacrosGenericTestSupport
import Testing

@Suite("@Ontology member expansion", .tags(.generated))
struct OntologyMacroTests {
    @Test("A class becomes a protocol, a storing protocol and the Swift class of its members; a property its value and storing types")
    func classesBecomeProtocolsAndClasses() {
        assertExpansion(
            """
            @Ontology
            public struct Zoo: Ontology {
                public var body: some Content {
                    Namespace("https://zoo.example.org/#")
                    Class("Animal") {
                        Type(RDF.Class)
                        Label("Animal")
                        Comment("An animal.")
                    }
                    Class("Keeper") {
                        SubClassOf(Zoo.Animal)
                    }
                    Property("feeds") {
                        Domain(Zoo.Keeper)
                        Range(Zoo.Animal)
                    }
                    Property("name") {
                        Domain(Zoo.Animal)
                        Range(RDF.Literal)
                    }
                }
            }
            """,
            expandedSource: """

            public struct Zoo: Ontology {
                public var body: some Content {
                    #sourceLocation(file: "test.swift", line: 4)
                    RDFCore.Namespace("https://zoo.example.org/#")
                    #sourceLocation(file: "test.swift", line: 5)
                    RDFCore.Class("Animal") {

                                RDFCore.Label("Animal")
                                RDFCore.Comment("An animal.")
                            }
                    #sourceLocation(file: "test.swift", line: 10)
                    RDFCore.Class("Keeper") {

                            }
                    #sourceLocation(file: "test.swift", line: 13)
                    RDFCore.Property("feeds") {


                            }
                    #sourceLocation(file: "test.swift", line: 17)
                    RDFCore.Property("name") {


                            }
                    #sourceLocation()
                }

                /// Animal
                ///
                /// An animal.
                public protocol Animal: RDF.Resource {
                    var name: [RDF.LiteralIndividual.Member] {
                        get
                        set
                    }
                }

                /// A member of ``Zoo/Animal`` that keeps its property values in an
                /// ``RDFCore/IndividualStorage``. An individual typed with the class, in
                /// any module, conforms to it.
                public protocol AnimalStoring: Zoo.Animal, Zoo.nameStoring, RDF.ResourceStoring {
                }

                /// Animal
                ///
                /// An animal.
                public final class AnimalIndividual: Zoo.AnimalStoring, RDFCore.ResourceClass, RDFCore.DecodableResource {
                    public static let classKey: RDFCore.TermKey? = RDFCore.TermKey("Animal", in: Zoo.self)

                    public static let classes: [any RDFCore.ResourceClass.Type] = [Zoo.AnimalIndividual.self]

                    /// The properties a member of the class has, which a decoder reads:
                    /// its own and its superclasses'.
                    public static var properties: [any (RDFCore.PropertyValue & Decodable).Type] {
                        [Zoo.nameValue.self] + RDF.ResourceIndividual.properties
                    }

                    /// A member of the class as a property value.
                    public typealias Member = any Zoo.Animal

                    public let storage = RDFCore.IndividualStorage()

                    /// A member of the class that no declaration names: a blank node at the boundary.
                    public init() {
                    }

                    public static func encodeDescription(to encoder: any Encoder) throws {
                        var container = encoder.container(keyedBy: RDFCore.PropertyKey.self)
                        try container.encode([RDF.ClassIndividual.self] as [any RDFCore.ResourceClass.Type], for: RDFCore.PropertyKey(RDF.type.key))
                        try container.encode([RDFCore.Literal("Animal")], for: RDFCore.PropertyKey(RDF.label.key))
                        try container.encode([RDFCore.Literal("An animal.")], for: RDFCore.PropertyKey(RDF.comment.key))
                    }
                }

                public protocol Keeper: Zoo.Animal {
                    var feeds: [any Zoo.Animal] {
                        get
                        set
                    }
                }

                /// A member of ``Zoo/Keeper`` that keeps its property values in an
                /// ``RDFCore/IndividualStorage``. An individual typed with the class, in
                /// any module, conforms to it.
                public protocol KeeperStoring: Zoo.Keeper, Zoo.feedsStoring, Zoo.AnimalStoring {
                }

                public final class KeeperIndividual: Zoo.KeeperStoring, RDFCore.ResourceClass, RDFCore.DecodableResource {
                    public static let classKey: RDFCore.TermKey? = RDFCore.TermKey("Keeper", in: Zoo.self)

                    public static let classes: [any RDFCore.ResourceClass.Type] = [Zoo.KeeperIndividual.self]

                    /// The properties a member of the class has, which a decoder reads:
                    /// its own and its superclasses'.
                    public static var properties: [any (RDFCore.PropertyValue & Decodable).Type] {
                        [Zoo.feedsValue.self] + Zoo.AnimalIndividual.properties
                    }

                    /// A member of the class as a property value.
                    public typealias Member = any Zoo.Keeper

                    public let storage = RDFCore.IndividualStorage()

                    /// A member of the class that no declaration names: a blank node at the boundary.
                    public init() {
                    }

                    public static func encodeDescription(to encoder: any Encoder) throws {
                        var container = encoder.container(keyedBy: RDFCore.PropertyKey.self)
                        try container.encode([Zoo.AnimalIndividual.self] as [any RDFCore.ResourceClass.Type], for: RDFCore.PropertyKey(RDF.subClassOf.key))
                    }
                }

                public struct feeds: RDFCore.PropertyTerm {
                    public static let key = RDFCore.TermKey("feeds", in: Zoo.self)

                    /// The property's description, which ``Zoo/ontology`` lists.
                    public init() {
                    }

                    public func encode(to encoder: any Encoder) throws {
                        var container = encoder.container(keyedBy: RDFCore.PropertyKey.self)
                        try container.encode([Zoo.KeeperIndividual.self] as [any RDFCore.ResourceClass.Type], for: RDFCore.PropertyKey(RDF.domain.key))
                        try container.encode([Zoo.AnimalIndividual.self] as [any RDFCore.ResourceClass.Type], for: RDFCore.PropertyKey(RDF.range.key))
                    }
                }

                /// The values an individual has for ``Zoo/feeds``.
                public struct feedsValue: RDFCore.PropertyValue, Decodable {
                    /// The declared key of the property, from which an encoder derives its IRI.
                    public static var key: RDFCore.TermKey {
                        Zoo.feeds.key
                    }

                    public var value: [any Zoo.Animal] = []

                    public init() {
                    }

                    public init(from decoder: any Decoder) throws {
                        let container = try decoder.container(keyedBy: RDFCore.PropertyKey.self)
                        value = try container.decode([any Zoo.Animal].self, for: RDFCore.PropertyKey(Self.key), as: Zoo.AnimalIndividual.self)
                    }

                    public func encode(to encoder: any Encoder) throws {
                        var container = encoder.container(keyedBy: RDFCore.PropertyKey.self)
                        try container.encode(value, for: RDFCore.PropertyKey(Self.key))
                    }
                }

                /// An individual that has ``Zoo/feeds``.
                public protocol feedsStoring: RDFCore.PropertyValueStoring {
                    var feeds: [any Zoo.Animal] {
                        get
                        set
                    }
                }

                public struct name: RDFCore.PropertyTerm {
                    public static let key = RDFCore.TermKey("name", in: Zoo.self)

                    /// The property's description, which ``Zoo/ontology`` lists.
                    public init() {
                    }

                    public func encode(to encoder: any Encoder) throws {
                        var container = encoder.container(keyedBy: RDFCore.PropertyKey.self)
                        try container.encode([Zoo.AnimalIndividual.self] as [any RDFCore.ResourceClass.Type], for: RDFCore.PropertyKey(RDF.domain.key))
                        try container.encode([RDF.LiteralIndividual.self] as [any RDFCore.ResourceClass.Type], for: RDFCore.PropertyKey(RDF.range.key))
                    }
                }

                /// The values an individual has for ``Zoo/name``.
                public struct nameValue: RDFCore.PropertyValue, Decodable {
                    /// The declared key of the property, from which an encoder derives its IRI.
                    public static var key: RDFCore.TermKey {
                        Zoo.name.key
                    }

                    public var value: [RDF.LiteralIndividual.Member] = []

                    public init() {
                    }

                    public init(from decoder: any Decoder) throws {
                        let container = try decoder.container(keyedBy: RDFCore.PropertyKey.self)
                        value = try container.decode([RDF.LiteralIndividual.Member].self, for: RDFCore.PropertyKey(Self.key), as: RDF.LiteralIndividual.self)
                    }

                    public func encode(to encoder: any Encoder) throws {
                        var container = encoder.container(keyedBy: RDFCore.PropertyKey.self)
                        try container.encode(value, for: RDFCore.PropertyKey(Self.key))
                    }
                }

                /// An individual that has ``Zoo/name``.
                public protocol nameStoring: RDFCore.PropertyValueStoring {
                    var name: [RDF.LiteralIndividual.Member] {
                        get
                        set
                    }
                }

                /// The descriptions of the terms this ontology declares.
                ///
                /// Encoding them gives the ontology's graph:
                ///
                ///     let document = try TurtleEncoder().encode(Zoo().ontology)
                public var ontology: [any RDFCore.Description] {
                    [
                        RDFCore.ClassDescription(Zoo.AnimalIndividual.self),
                        RDFCore.ClassDescription(Zoo.KeeperIndividual.self),
                        Zoo.feeds(),
                        Zoo.name(),
                    ]
                }

                /// The namespace this ontology's terms are declared in, from which an
                /// encoder derives each term's IRI.
                public static let namespace = "https://zoo.example.org/#"
            }

            extension feedsStoring {
                public var feeds: [any Zoo.Animal] {
                    get {
                        storage[feedsValue.self].value
                    }
                    set {
                        storage[feedsValue.self].value = newValue
                    }
                    _modify {
                        yield &storage[feedsValue.self].value
                    }
                }
            }

            extension nameStoring {
                public var name: [RDF.LiteralIndividual.Member] {
                    get {
                        storage[nameValue.self].value
                    }
                    set {
                        storage[nameValue.self].value = newValue
                    }
                    _modify {
                        yield &storage[nameValue.self].value
                    }
                }
            }
            """
        )
    }

    @Test("Several superclasses become several refinements")
    func severalSuperclassesAreSeveralRefinements() {
        assertExpansion(
            """
            @Ontology
            struct Library: Ontology {
                var body: some Content {
                    Namespace("https://library.example/#")
                    Class("Book")
                    Class("Periodical")
                    Class("Annual") {
                        SubClassOf(Library.Book)
                        SubClassOf(Library.Periodical)
                    }
                }
            }
            """,
            expandedSource: """

            struct Library: Ontology {
                var body: some Content {
                    #sourceLocation(file: "test.swift", line: 4)
                    RDFCore.Namespace("https://library.example/#")
                    #sourceLocation(file: "test.swift", line: 5)
                    RDFCore.Class("Book")
                    #sourceLocation(file: "test.swift", line: 6)
                    RDFCore.Class("Periodical")
                    #sourceLocation(file: "test.swift", line: 7)
                    RDFCore.Class("Annual") {


                            }
                    #sourceLocation()
                }

                protocol Book: RDF.Resource {
                }

                /// A member of ``Library/Book`` that keeps its property values in an
                /// ``RDFCore/IndividualStorage``. An individual typed with the class, in
                /// any module, conforms to it.
                protocol BookStoring: Library.Book, RDF.ResourceStoring {
                }

                final class BookIndividual: Library.BookStoring, RDFCore.ResourceClass, RDFCore.DecodableResource {
                    static let classKey: RDFCore.TermKey? = RDFCore.TermKey("Book", in: Library.self)

                    static let classes: [any RDFCore.ResourceClass.Type] = [Library.BookIndividual.self]

                    /// The properties a member of the class has, which a decoder reads:
                    /// its own and its superclasses'.
                    static var properties: [any (RDFCore.PropertyValue & Decodable).Type] {
                        RDF.ResourceIndividual.properties
                    }

                    /// A member of the class as a property value.
                    typealias Member = any Library.Book

                    let storage = RDFCore.IndividualStorage()

                    /// A member of the class that no declaration names: a blank node at the boundary.
                    init() {
                    }

                    static func encodeDescription(to encoder: any Encoder) throws {
                        _ = encoder.container(keyedBy: RDFCore.PropertyKey.self)
                    }
                }

                protocol Periodical: RDF.Resource {
                }

                /// A member of ``Library/Periodical`` that keeps its property values in an
                /// ``RDFCore/IndividualStorage``. An individual typed with the class, in
                /// any module, conforms to it.
                protocol PeriodicalStoring: Library.Periodical, RDF.ResourceStoring {
                }

                final class PeriodicalIndividual: Library.PeriodicalStoring, RDFCore.ResourceClass, RDFCore.DecodableResource {
                    static let classKey: RDFCore.TermKey? = RDFCore.TermKey("Periodical", in: Library.self)

                    static let classes: [any RDFCore.ResourceClass.Type] = [Library.PeriodicalIndividual.self]

                    /// The properties a member of the class has, which a decoder reads:
                    /// its own and its superclasses'.
                    static var properties: [any (RDFCore.PropertyValue & Decodable).Type] {
                        RDF.ResourceIndividual.properties
                    }

                    /// A member of the class as a property value.
                    typealias Member = any Library.Periodical

                    let storage = RDFCore.IndividualStorage()

                    /// A member of the class that no declaration names: a blank node at the boundary.
                    init() {
                    }

                    static func encodeDescription(to encoder: any Encoder) throws {
                        _ = encoder.container(keyedBy: RDFCore.PropertyKey.self)
                    }
                }

                protocol Annual: Library.Book, Library.Periodical {
                }

                /// A member of ``Library/Annual`` that keeps its property values in an
                /// ``RDFCore/IndividualStorage``. An individual typed with the class, in
                /// any module, conforms to it.
                protocol AnnualStoring: Library.Annual, Library.BookStoring, Library.PeriodicalStoring {
                }

                final class AnnualIndividual: Library.AnnualStoring, RDFCore.ResourceClass, RDFCore.DecodableResource {
                    static let classKey: RDFCore.TermKey? = RDFCore.TermKey("Annual", in: Library.self)

                    static let classes: [any RDFCore.ResourceClass.Type] = [Library.AnnualIndividual.self]

                    /// The properties a member of the class has, which a decoder reads:
                    /// its own and its superclasses'.
                    static var properties: [any (RDFCore.PropertyValue & Decodable).Type] {
                        Library.BookIndividual.properties + Library.PeriodicalIndividual.properties
                    }

                    /// A member of the class as a property value.
                    typealias Member = any Library.Annual

                    let storage = RDFCore.IndividualStorage()

                    /// A member of the class that no declaration names: a blank node at the boundary.
                    init() {
                    }

                    static func encodeDescription(to encoder: any Encoder) throws {
                        var container = encoder.container(keyedBy: RDFCore.PropertyKey.self)
                        try container.encode([Library.BookIndividual.self, Library.PeriodicalIndividual.self] as [any RDFCore.ResourceClass.Type], for: RDFCore.PropertyKey(RDF.subClassOf.key))
                    }
                }

                /// The descriptions of the terms this ontology declares.
                ///
                /// Encoding them gives the ontology's graph:
                ///
                ///     let document = try TurtleEncoder().encode(Library().ontology)
                var ontology: [any RDFCore.Description] {
                    [
                        RDFCore.ClassDescription(Library.BookIndividual.self),
                        RDFCore.ClassDescription(Library.PeriodicalIndividual.self),
                        RDFCore.ClassDescription(Library.AnnualIndividual.self),
                    ]
                }

                /// The namespace this ontology's terms are declared in, from which an
                /// encoder derives each term's IRI.
                static let namespace = "https://library.example/#"
            }
            """
        )
    }

    @Test("A class or range of another module is resolved through its generated types; a datatype's members are literals")
    func classesOfOtherModulesResolveThroughTheirTypes() {
        assertExpansion(
            """
            @Ontology
            struct Club: Ontology {
                var body: some Content {
                    Namespace("https://club.example.org/#")
                    Datatype("Code") {
                        SubClassOf(RDF.Literal)
                    }
                    Class("Member") {
                        SubClassOf(FOAF.Person)
                        SeeAlso("https://club.example.org/rules")
                        Deprecated()
                    }
                    Property("code") {
                        Domain(Club.Member)
                        Range(Club.Code)
                    }
                    Property("friend") {
                        Domain(Club.Member)
                        Range(FOAF.Person)
                    }
                    Property("note")
                }
            }
            """,
            expandedSource: """

            struct Club: Ontology {
                var body: some Content {
                    #sourceLocation(file: "test.swift", line: 4)
                    RDFCore.Namespace("https://club.example.org/#")
                    #sourceLocation(file: "test.swift", line: 5)
                    RDFCore.Datatype("Code") {

                            }
                    #sourceLocation(file: "test.swift", line: 8)
                    RDFCore.Class("Member") {

                                RDFCore.SeeAlso("https://club.example.org/rules")
                                RDFCore.Deprecated()
                            }
                    #sourceLocation(file: "test.swift", line: 13)
                    RDFCore.Property("code") {


                            }
                    #sourceLocation(file: "test.swift", line: 17)
                    RDFCore.Property("friend") {


                            }
                    #sourceLocation(file: "test.swift", line: 21)
                    RDFCore.Property("note")
                    #sourceLocation()
                }

                protocol Code: RDF.Literal {
                }

                /// A member of ``Club/Code`` that keeps its property values in an
                /// ``RDFCore/IndividualStorage``. An individual typed with the class, in
                /// any module, conforms to it.
                protocol CodeStoring: Club.Code, RDF.LiteralStoring {
                }

                final class CodeIndividual: Club.CodeStoring, RDFCore.ResourceClass, RDFCore.DecodableResource {
                    static let classKey: RDFCore.TermKey? = RDFCore.TermKey("Code", in: Club.self)

                    static let classes: [any RDFCore.ResourceClass.Type] = [Club.CodeIndividual.self]

                    /// The properties a member of the class has, which a decoder reads:
                    /// its own and its superclasses'.
                    static var properties: [any (RDFCore.PropertyValue & Decodable).Type] {
                        RDF.LiteralIndividual.properties
                    }

                    /// A member of the class as a property value.
                    typealias Member = RDFCore.Literal

                    let storage = RDFCore.IndividualStorage()

                    /// A member of the class that no declaration names: a blank node at the boundary.
                    init() {
                    }

                    static func encodeDescription(to encoder: any Encoder) throws {
                        var container = encoder.container(keyedBy: RDFCore.PropertyKey.self)
                        try container.encode([RDF.LiteralIndividual.self] as [any RDFCore.ResourceClass.Type], for: RDFCore.PropertyKey(RDF.subClassOf.key))
                    }
                }

                @available(*, deprecated)
                protocol Member: FOAF.Person {
                    var code: [RDFCore.Literal] {
                        get
                        set
                    }

                    var friend: [FOAF.PersonIndividual.Member] {
                        get
                        set
                    }
                }

                /// A member of ``Club/Member`` that keeps its property values in an
                /// ``RDFCore/IndividualStorage``. An individual typed with the class, in
                /// any module, conforms to it.
                protocol MemberStoring: Club.Member, Club.codeStoring, Club.friendStoring, FOAF.PersonStoring {
                }

                @available(*, deprecated)
                final class MemberIndividual: Club.MemberStoring, RDFCore.ResourceClass, RDFCore.DecodableResource {
                    static let classKey: RDFCore.TermKey? = RDFCore.TermKey("Member", in: Club.self)

                    static let classes: [any RDFCore.ResourceClass.Type] = [Club.MemberIndividual.self]

                    /// The properties a member of the class has, which a decoder reads:
                    /// its own and its superclasses'.
                    static var properties: [any (RDFCore.PropertyValue & Decodable).Type] {
                        [Club.codeValue.self] + [Club.friendValue.self] + FOAF.PersonIndividual.properties
                    }

                    /// A member of the class as a property value.
                    typealias Member = any Club.Member

                    let storage = RDFCore.IndividualStorage()

                    /// A member of the class that no declaration names: a blank node at the boundary.
                    init() {
                    }

                    static func encodeDescription(to encoder: any Encoder) throws {
                        var container = encoder.container(keyedBy: RDFCore.PropertyKey.self)
                        try container.encode([FOAF.PersonIndividual.self] as [any RDFCore.ResourceClass.Type], for: RDFCore.PropertyKey(RDF.subClassOf.key))
                        struct SeeAlsoNamespace0: RDFCore.Vocabulary {
                            static var namespace: String {
                                "https://club.example.org/rules"
                            }
                        }
                        final class SeeAlsoDocument0: RDFCore.Resource {
                            static var key: RDFCore.TermKey? {
                                RDFCore.TermKey("", in: SeeAlsoNamespace0.self)
                            }
                            func encode(to encoder: any Encoder) throws {
                            }
                        }
                        try container.encode([SeeAlsoDocument0()] as [any RDFCore.Resource], for: RDFCore.PropertyKey(RDF.seeAlso.key))
                        try container.encode([try RDFCore.Literal("true", datatype: "http://www.w3.org/2001/XMLSchema#boolean")], for: RDFCore.PropertyKey(OWL.deprecatedValue.key))
                    }
                }

                struct code: RDFCore.PropertyTerm {
                    static let key = RDFCore.TermKey("code", in: Club.self)

                    /// The property's description, which ``Club/ontology`` lists.
                    init() {
                    }

                    func encode(to encoder: any Encoder) throws {
                        var container = encoder.container(keyedBy: RDFCore.PropertyKey.self)
                        try container.encode([Club.MemberIndividual.self] as [any RDFCore.ResourceClass.Type], for: RDFCore.PropertyKey(RDF.domain.key))
                        try container.encode([Club.CodeIndividual.self] as [any RDFCore.ResourceClass.Type], for: RDFCore.PropertyKey(RDF.range.key))
                    }
                }

                /// The values an individual has for ``Club/code``.
                struct codeValue: RDFCore.PropertyValue, Decodable {
                    /// The declared key of the property, from which an encoder derives its IRI.
                    static var key: RDFCore.TermKey {
                        Club.code.key
                    }

                    var value: [RDFCore.Literal] = []

                    init() {
                    }

                    init(from decoder: any Decoder) throws {
                        let container = try decoder.container(keyedBy: RDFCore.PropertyKey.self)
                        value = try container.decode([RDFCore.Literal].self, for: RDFCore.PropertyKey(Self.key), as: Club.CodeIndividual.self)
                    }

                    func encode(to encoder: any Encoder) throws {
                        var container = encoder.container(keyedBy: RDFCore.PropertyKey.self)
                        try container.encode(value, for: RDFCore.PropertyKey(Self.key))
                    }
                }

                /// An individual that has ``Club/code``.
                protocol codeStoring: RDFCore.PropertyValueStoring {
                    var code: [RDFCore.Literal] {
                        get
                        set
                    }
                }

                struct friend: RDFCore.PropertyTerm {
                    static let key = RDFCore.TermKey("friend", in: Club.self)

                    /// The property's description, which ``Club/ontology`` lists.
                    init() {
                    }

                    func encode(to encoder: any Encoder) throws {
                        var container = encoder.container(keyedBy: RDFCore.PropertyKey.self)
                        try container.encode([Club.MemberIndividual.self] as [any RDFCore.ResourceClass.Type], for: RDFCore.PropertyKey(RDF.domain.key))
                        try container.encode([FOAF.PersonIndividual.self] as [any RDFCore.ResourceClass.Type], for: RDFCore.PropertyKey(RDF.range.key))
                    }
                }

                /// The values an individual has for ``Club/friend``.
                struct friendValue: RDFCore.PropertyValue, Decodable {
                    /// The declared key of the property, from which an encoder derives its IRI.
                    static var key: RDFCore.TermKey {
                        Club.friend.key
                    }

                    var value: [FOAF.PersonIndividual.Member] = []

                    init() {
                    }

                    init(from decoder: any Decoder) throws {
                        let container = try decoder.container(keyedBy: RDFCore.PropertyKey.self)
                        value = try container.decode([FOAF.PersonIndividual.Member].self, for: RDFCore.PropertyKey(Self.key), as: FOAF.PersonIndividual.self)
                    }

                    func encode(to encoder: any Encoder) throws {
                        var container = encoder.container(keyedBy: RDFCore.PropertyKey.self)
                        try container.encode(value, for: RDFCore.PropertyKey(Self.key))
                    }
                }

                /// An individual that has ``Club/friend``.
                protocol friendStoring: RDFCore.PropertyValueStoring {
                    var friend: [FOAF.PersonIndividual.Member] {
                        get
                        set
                    }
                }

                struct note: RDFCore.PropertyTerm {
                    static let key = RDFCore.TermKey("note", in: Club.self)

                    /// The property's description, which ``Club/ontology`` lists.
                    init() {
                    }

                    func encode(to encoder: any Encoder) throws {
                        _ = encoder.container(keyedBy: RDFCore.PropertyKey.self)
                    }
                }

                /// The descriptions of the terms this ontology declares.
                ///
                /// Encoding them gives the ontology's graph:
                ///
                ///     let document = try TurtleEncoder().encode(Club().ontology)
                var ontology: [any RDFCore.Description] {
                    [
                        RDFCore.ClassDescription(Club.CodeIndividual.self),
                        RDFCore.ClassDescription(Club.MemberIndividual.self),
                        Club.code(),
                        Club.friend(),
                        Club.note(),
                    ]
                }

                /// The namespace this ontology's terms are declared in, from which an
                /// encoder derives each term's IRI.
                static let namespace = "https://club.example.org/#"
            }

            extension codeStoring {
                var code: [RDFCore.Literal] {
                    get {
                        storage[codeValue.self].value
                    }
                    set {
                        storage[codeValue.self].value = newValue
                    }
                    _modify {
                        yield &storage[codeValue.self].value
                    }
                }
            }

            extension friendStoring {
                var friend: [FOAF.PersonIndividual.Member] {
                    get {
                        storage[friendValue.self].value
                    }
                    set {
                        storage[friendValue.self].value = newValue
                    }
                    _modify {
                        yield &storage[friendValue.self].value
                    }
                }
            }
            """
        )
    }

    @Test("Declarations of one term are one term with everything each states, each requirement once")
    func splitDeclarationsAreMerged() {
        assertExpansion(
            """
            @Ontology
            struct Zoo: Ontology {
                var body: some Content {
                    Namespace("https://zoo.example.org/#")
                    Class("Animal")
                    Property("name") {
                        Domain(Zoo.Animal)
                    }
                    Class("Animal") {
                        SubClassOf(FOAF.Agent)
                        Label("Animal")
                    }
                    Property("name") {
                        Domain(Zoo.Animal)
                        Label("name")
                    }
                }
            }
            """,
            expandedSource: """

            struct Zoo: Ontology {
                var body: some Content {
                    #sourceLocation(file: "test.swift", line: 4)
                    RDFCore.Namespace("https://zoo.example.org/#")
                    #sourceLocation(file: "test.swift", line: 5)
                    RDFCore.Class("Animal")
                    #sourceLocation(file: "test.swift", line: 6)
                    RDFCore.Property("name") {

                            }
                    #sourceLocation(file: "test.swift", line: 9)
                    RDFCore.Class("Animal") {

                                RDFCore.Label("Animal")
                            }
                    #sourceLocation(file: "test.swift", line: 13)
                    RDFCore.Property("name") {

                                RDFCore.Label("name")
                            }
                    #sourceLocation()
                }

                /// Animal
                protocol Animal: FOAF.Agent {
                    /// name
                    var name: [RDFCore.Value] {
                        get
                        set
                    }
                }

                /// A member of ``Zoo/Animal`` that keeps its property values in an
                /// ``RDFCore/IndividualStorage``. An individual typed with the class, in
                /// any module, conforms to it.
                protocol AnimalStoring: Zoo.Animal, Zoo.nameStoring, FOAF.AgentStoring {
                }

                /// Animal
                final class AnimalIndividual: Zoo.AnimalStoring, RDFCore.ResourceClass, RDFCore.DecodableResource {
                    static let classKey: RDFCore.TermKey? = RDFCore.TermKey("Animal", in: Zoo.self)

                    static let classes: [any RDFCore.ResourceClass.Type] = [Zoo.AnimalIndividual.self]

                    /// The properties a member of the class has, which a decoder reads:
                    /// its own and its superclasses'.
                    static var properties: [any (RDFCore.PropertyValue & Decodable).Type] {
                        [Zoo.nameValue.self] + FOAF.AgentIndividual.properties
                    }

                    /// A member of the class as a property value.
                    typealias Member = any Zoo.Animal

                    let storage = RDFCore.IndividualStorage()

                    /// A member of the class that no declaration names: a blank node at the boundary.
                    init() {
                    }

                    static func encodeDescription(to encoder: any Encoder) throws {
                        var container = encoder.container(keyedBy: RDFCore.PropertyKey.self)
                        try container.encode([FOAF.AgentIndividual.self] as [any RDFCore.ResourceClass.Type], for: RDFCore.PropertyKey(RDF.subClassOf.key))
                        try container.encode([RDFCore.Literal("Animal")], for: RDFCore.PropertyKey(RDF.label.key))
                    }
                }

                /// name
                struct name: RDFCore.PropertyTerm {
                    static let key = RDFCore.TermKey("name", in: Zoo.self)

                    /// The property's description, which ``Zoo/ontology`` lists.
                    init() {
                    }

                    func encode(to encoder: any Encoder) throws {
                        var container = encoder.container(keyedBy: RDFCore.PropertyKey.self)
                        try container.encode([Zoo.AnimalIndividual.self] as [any RDFCore.ResourceClass.Type], for: RDFCore.PropertyKey(RDF.domain.key))
                        try container.encode([RDFCore.Literal("name")], for: RDFCore.PropertyKey(RDF.label.key))
                    }
                }

                /// The values an individual has for ``Zoo/name``.
                struct nameValue: RDFCore.PropertyValue, Decodable {
                    /// The declared key of the property, from which an encoder derives its IRI.
                    static var key: RDFCore.TermKey {
                        Zoo.name.key
                    }

                    var value: [RDFCore.Value] = []

                    init() {
                    }

                    init(from decoder: any Decoder) throws {
                        let container = try decoder.container(keyedBy: RDFCore.PropertyKey.self)
                        value = try container.decode([RDFCore.Value].self, for: RDFCore.PropertyKey(Self.key), as: RDF.ResourceIndividual.self)
                    }

                    func encode(to encoder: any Encoder) throws {
                        var container = encoder.container(keyedBy: RDFCore.PropertyKey.self)
                        try container.encode(value, for: RDFCore.PropertyKey(Self.key))
                    }
                }

                /// An individual that has ``Zoo/name``.
                protocol nameStoring: RDFCore.PropertyValueStoring {
                    var name: [RDFCore.Value] {
                        get
                        set
                    }
                }

                /// The descriptions of the terms this ontology declares.
                ///
                /// Encoding them gives the ontology's graph:
                ///
                ///     let document = try TurtleEncoder().encode(Zoo().ontology)
                var ontology: [any RDFCore.Description] {
                    [
                        RDFCore.ClassDescription(Zoo.AnimalIndividual.self),
                        Zoo.name(),
                    ]
                }

                /// The namespace this ontology's terms are declared in, from which an
                /// encoder derives each term's IRI.
                static let namespace = "https://zoo.example.org/#"
            }

            extension nameStoring {
                var name: [RDFCore.Value] {
                    get {
                        storage[nameValue.self].value
                    }
                    set {
                        storage[nameValue.self].value = newValue
                    }
                    _modify {
                        yield &storage[nameValue.self].value
                    }
                }
            }
            """
        )
    }

    @Test("A term declared again with another form is reported at the later declaration")
    func redeclarationWithAnotherFormIsReported() {
        assertExpansion(
            """
            @Ontology
            struct Zoo: Ontology {
                var body: some Content {
                    Namespace("https://zoo.example.org/#")
                    Class("Animal")
                    Property("Animal") {
                        Domain(Zoo.Animal)
                    }
                }
            }
            """,
            expandedSource: """

            struct Zoo: Ontology {
                var body: some Content {
                    #sourceLocation(file: "test.swift", line: 4)
                    RDFCore.Namespace("https://zoo.example.org/#")
                    #sourceLocation(file: "test.swift", line: 5)
                    RDFCore.Class("Animal")
                    #sourceLocation(file: "test.swift", line: 6)
                    RDFCore.Property("Animal") {

                            }
                    #sourceLocation()
                }

                protocol Animal: RDF.Resource {
                }

                /// A member of ``Zoo/Animal`` that keeps its property values in an
                /// ``RDFCore/IndividualStorage``. An individual typed with the class, in
                /// any module, conforms to it.
                protocol AnimalStoring: Zoo.Animal, RDF.ResourceStoring {
                }

                final class AnimalIndividual: Zoo.AnimalStoring, RDFCore.ResourceClass, RDFCore.DecodableResource {
                    static let classKey: RDFCore.TermKey? = RDFCore.TermKey("Animal", in: Zoo.self)

                    static let classes: [any RDFCore.ResourceClass.Type] = [Zoo.AnimalIndividual.self]

                    /// The properties a member of the class has, which a decoder reads:
                    /// its own and its superclasses'.
                    static var properties: [any (RDFCore.PropertyValue & Decodable).Type] {
                        RDF.ResourceIndividual.properties
                    }

                    /// A member of the class as a property value.
                    typealias Member = any Zoo.Animal

                    let storage = RDFCore.IndividualStorage()

                    /// A member of the class that no declaration names: a blank node at the boundary.
                    init() {
                    }

                    static func encodeDescription(to encoder: any Encoder) throws {
                        _ = encoder.container(keyedBy: RDFCore.PropertyKey.self)
                    }
                }

                /// The descriptions of the terms this ontology declares.
                ///
                /// Encoding them gives the ontology's graph:
                ///
                ///     let document = try TurtleEncoder().encode(Zoo().ontology)
                var ontology: [any RDFCore.Description] {
                    [
                        RDFCore.ClassDescription(Zoo.AnimalIndividual.self),
                    ]
                }

                /// The namespace this ontology's terms are declared in, from which an
                /// encoder derives each term's IRI.
                static let namespace = "https://zoo.example.org/#"
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "'Animal' is declared as Class(\"Animal\") in this ontology, so it cannot also be declared as Property(\"Animal\")", line: 6, column: 9),
            ]
        )
    }

    @Test("Mistakes are reported where they were written")
    func mistakesAreReportedAtTheAuthoredDeclaration() {
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
                }
            }
            """,
            expandedSource: """

            struct Zoo: Ontology {
                var body: some Content {
                    #sourceLocation(file: "test.swift", line: 4)
                    RDFCore.Namespace("https://zoo.example.org/#")
                    #sourceLocation(file: "test.swift", line: 5)
                    RDFCore.Class("Animal")
                    #sourceLocation(file: "test.swift", line: 6)
                    RDFCore.Class("Keeper") {

                            }
                    #sourceLocation(file: "test.swift", line: 9)
                    RDFCore.Class("AnimalIndividual")
                    #sourceLocation()
                }

                protocol Animal: RDF.Resource {
                }

                protocol Keeper: RDF.Resource {
                }

                /// A member of ``Zoo/Keeper`` that keeps its property values in an
                /// ``RDFCore/IndividualStorage``. An individual typed with the class, in
                /// any module, conforms to it.
                protocol KeeperStoring: Zoo.Keeper, RDF.ResourceStoring {
                }

                final class KeeperIndividual: Zoo.KeeperStoring, RDFCore.ResourceClass, RDFCore.DecodableResource {
                    static let classKey: RDFCore.TermKey? = RDFCore.TermKey("Keeper", in: Zoo.self)

                    static let classes: [any RDFCore.ResourceClass.Type] = [Zoo.KeeperIndividual.self]

                    /// The properties a member of the class has, which a decoder reads:
                    /// its own and its superclasses'.
                    static var properties: [any (RDFCore.PropertyValue & Decodable).Type] {
                        RDF.ResourceIndividual.properties
                    }

                    /// A member of the class as a property value.
                    typealias Member = any Zoo.Keeper

                    let storage = RDFCore.IndividualStorage()

                    /// A member of the class that no declaration names: a blank node at the boundary.
                    init() {
                    }

                    static func encodeDescription(to encoder: any Encoder) throws {
                        var container = encoder.container(keyedBy: RDFCore.PropertyKey.self)
                        try container.encode([Zoo.AnimlIndividual.self] as [any RDFCore.ResourceClass.Type], for: RDFCore.PropertyKey(RDF.subClassOf.key))
                    }
                }

                protocol AnimalIndividual: RDF.Resource {
                }

                /// A member of ``Zoo/AnimalIndividual`` that keeps its property values in an
                /// ``RDFCore/IndividualStorage``. An individual typed with the class, in
                /// any module, conforms to it.
                protocol AnimalIndividualStoring: Zoo.AnimalIndividual, RDF.ResourceStoring {
                }

                final class AnimalIndividualIndividual: Zoo.AnimalIndividualStoring, RDFCore.ResourceClass, RDFCore.DecodableResource {
                    static let classKey: RDFCore.TermKey? = RDFCore.TermKey("AnimalIndividual", in: Zoo.self)

                    static let classes: [any RDFCore.ResourceClass.Type] = [Zoo.AnimalIndividualIndividual.self]

                    /// The properties a member of the class has, which a decoder reads:
                    /// its own and its superclasses'.
                    static var properties: [any (RDFCore.PropertyValue & Decodable).Type] {
                        RDF.ResourceIndividual.properties
                    }

                    /// A member of the class as a property value.
                    typealias Member = any Zoo.AnimalIndividual

                    let storage = RDFCore.IndividualStorage()

                    /// A member of the class that no declaration names: a blank node at the boundary.
                    init() {
                    }

                    static func encodeDescription(to encoder: any Encoder) throws {
                        _ = encoder.container(keyedBy: RDFCore.PropertyKey.self)
                    }
                }

                /// The descriptions of the terms this ontology declares.
                ///
                /// Encoding them gives the ontology's graph:
                ///
                ///     let document = try TurtleEncoder().encode(Zoo().ontology)
                var ontology: [any RDFCore.Description] {
                    [
                        RDFCore.ClassDescription(Zoo.KeeperIndividual.self),
                        RDFCore.ClassDescription(Zoo.AnimalIndividualIndividual.self),
                    ]
                }

                /// The namespace this ontology's terms are declared in, from which an
                /// encoder derives each term's IRI.
                static let namespace = "https://zoo.example.org/#"
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "'Zoo.Animl' is not declared in Zoo", line: 7, column: 13),
                DiagnosticSpec(message: "'AnimalIndividual' is declared in this ontology, so the individual type of 'Animal' cannot use that name", line: 5, column: 9),
            ]
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
