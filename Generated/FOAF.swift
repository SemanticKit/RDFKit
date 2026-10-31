import IRIKit
import RDFCore
import RDFKit
/// term_status: unstable
///
/// label: Label Property
///
/// comment: A foaf:LabelProperty is any RDF property with texual values that serve as labels.
public protocol LabelProperty: RDFS.Resource, AnyObject {
}
/// comment: A person.
///
/// label: Person
///
/// term_status: stable
public protocol Person: FOAF.SpatialThing, FOAF.Agent, AnyObject {
    /// comment: A textual geekcode for this person, see http://www.geekcode.com/geek.html
    ///
    /// label: geekcode
    ///
    /// term_status: archaic
    var geekcode: Values<any RDFS.Literal> {
        get
        set
    }
    /// comment: The first name of a person.
    ///
    /// label: firstName
    ///
    /// term_status: testing
    var firstName: Values<any RDFS.Literal> {
        get
        set
    }
    /// comment: The last name of a person.
    ///
    /// label: lastName
    ///
    /// term_status: testing
    var lastName: Values<any RDFS.Literal> {
        get
        set
    }
    /// comment: The surname of some person.
    ///
    /// label: Surname
    ///
    /// term_status: archaic
    var surname: Values<any RDFS.Literal> {
        get
        set
    }
    /// comment: The family name of some person.
    ///
    /// label: family_name
    ///
    /// term_status: archaic
    var family_name: Values<any RDFS.Literal> {
        get
        set
    }
    /// comment: The family name of some person.
    ///
    /// label: familyName
    ///
    /// term_status: testing
    var familyName: Values<any RDFS.Literal> {
        get
        set
    }
    /// comment: A .plan comment, in the tradition of finger and '.plan' files.
    ///
    /// label: plan
    ///
    /// term_status: testing
    var plan: Values<any RDFS.Literal> {
        get
        set
    }
    /// comment: An image that can be used to represent some thing (ie. those depictions which are particularly representative of something, eg. one's photo on a homepage).
    ///
    /// label: image
    ///
    /// term_status: testing
    var img: Values<any FOAF.Image> {
        get
        set
    }
    /// comment: A Myers Briggs (MBTI) personality classification.
    ///
    /// label: myersBriggs
    ///
    /// term_status: testing
    var myersBriggs: Values<any RDFS.Literal> {
        get
        set
    }
    /// comment: A workplace homepage of some person; the homepage of an organization they work for.
    ///
    /// label: workplace homepage
    ///
    /// term_status: testing
    var workplaceHomepage: Values<any FOAF.Document> {
        get
        set
    }
    /// comment: A work info homepage of some person; a page about their work for some organization.
    ///
    /// label: work info homepage
    ///
    /// term_status: testing
    var workInfoHomepage: Values<any FOAF.Document> {
        get
        set
    }
    /// comment: A homepage of a school attended by the person.
    ///
    /// label: schoolHomepage
    ///
    /// term_status: testing
    var schoolHomepage: Values<any FOAF.Document> {
        get
        set
    }
    /// comment: A person known by this person (indicating some level of reciprocated interaction between the parties).
    ///
    /// label: knows
    ///
    /// term_status: stable
    var knows: Values<any FOAF.Person> {
        get
        set
    }
    /// comment: A link to the publications of this person.
    ///
    /// label: publications
    ///
    /// term_status: testing
    var publications: Values<any FOAF.Document> {
        get
        set
    }
    /// comment: A current project this person works on.
    ///
    /// label: current project
    ///
    /// term_status: testing
    var currentProject: Values<any OWL.Thing> {
        get
        set
    }
    /// comment: A project this person has previously worked on.
    ///
    /// label: past project
    ///
    /// term_status: testing
    var pastProject: Values<any OWL.Thing> {
        get
        set
    }
}
/// comment: An agent (eg. person, group, software or physical artifact).
///
/// label: Agent
///
/// term_status: stable
public protocol Agent: RDFS.Resource, AnyObject {
    /// comment: A  personal mailbox, ie. an Internet mailbox associated with exactly one owner, the first owner of this mailbox. This is a 'static inverse functional property', in that  there is (across time and change) at most one individual that ever has any particular value for foaf:mbox.
    ///
    /// label: personal mailbox
    ///
    /// term_status: stable
    var mbox: Values<any OWL.Thing> {
        get
        set
    }
    /// comment: The sha1sum of the URI of an Internet mailbox associated with exactly one owner, the  first owner of the mailbox.
    ///
    /// label: sha1sum of a personal mailbox URI name
    ///
    /// term_status: testing
    var mbox_sha1sum: Values<any RDFS.Literal> {
        get
        set
    }
    /// comment: The gender of this Agent (typically but not necessarily 'male' or 'female').
    ///
    /// label: gender
    ///
    /// term_status: testing
    var gender: (any RDFS.Literal)? {
        get
        set
    }
    /// comment: A jabber ID for something.
    ///
    /// label: jabber ID
    ///
    /// term_status: testing
    var jabberID: Values<any RDFS.Literal> {
        get
        set
    }
    /// comment: An AIM chat ID
    ///
    /// label: AIM chat ID
    ///
    /// term_status: testing
    var aimChatID: Values<any RDFS.Literal> {
        get
        set
    }
    /// comment: A Skype ID
    ///
    /// label: Skype ID
    ///
    /// term_status: testing
    var skypeID: Values<any RDFS.Literal> {
        get
        set
    }
    /// comment: An ICQ chat ID
    ///
    /// label: ICQ chat ID
    ///
    /// term_status: testing
    var icqChatID: Values<any RDFS.Literal> {
        get
        set
    }
    /// comment: A Yahoo chat ID
    ///
    /// label: Yahoo chat ID
    ///
    /// term_status: testing
    var yahooChatID: Values<any RDFS.Literal> {
        get
        set
    }
    /// comment: An MSN chat ID
    ///
    /// label: MSN chat ID
    ///
    /// term_status: testing
    var msnChatID: Values<any RDFS.Literal> {
        get
        set
    }
    /// comment: A weblog of some thing (whether person, group, company etc.).
    ///
    /// label: weblog
    ///
    /// term_status: stable
    var weblog: Values<any FOAF.Document> {
        get
        set
    }
    /// comment: An OpenID for an Agent.
    ///
    /// label: openid
    ///
    /// term_status: testing
    var openid: Values<any FOAF.Document> {
        get
        set
    }
    /// comment: A tipjar document for this agent, describing means for payment and reward.
    ///
    /// label: tipjar
    ///
    /// term_status: testing
    var tipjar: Values<any FOAF.Document> {
        get
        set
    }
    /// comment: Something that was made by this agent.
    ///
    /// label: made
    ///
    /// term_status: stable
    var made: Values<any OWL.Thing> {
        get
        set
    }
    /// comment: A page about a topic of interest to this person.
    ///
    /// label: interest
    ///
    /// term_status: testing
    var interest: Values<any FOAF.Document> {
        get
        set
    }
    /// comment: A thing of interest to this person.
    ///
    /// label: topic_interest
    ///
    /// term_status: testing
    var topic_interest: Values<any OWL.Thing> {
        get
        set
    }
    /// comment: Indicates an account held by this agent.
    ///
    /// label: account
    ///
    /// term_status: testing
    var account: Values<any FOAF.OnlineAccount> {
        get
        set
    }
    /// comment: Indicates an account held by this agent.
    ///
    /// label: account
    ///
    /// term_status: archaic
    var holdsAccount: Values<any FOAF.OnlineAccount> {
        get
        set
    }
    /// comment: The birthday of this Agent, represented in mm-dd string form, eg. '12-31'.
    ///
    /// label: birthday
    ///
    /// term_status: unstable
    var birthday: (any RDFS.Literal)? {
        get
        set
    }
    /// comment: The age in years of some agent.
    ///
    /// label: age
    ///
    /// term_status: unstable
    var age: (any RDFS.Literal)? {
        get
        set
    }
    /// comment: A string expressing what the user is happy for the general public (normally) to know about their current activity.
    ///
    /// label: status
    ///
    /// term_status: unstable
    var status: Values<any RDFS.Literal> {
        get
        set
    }
}
/// label: Spatial Thing
public protocol SpatialThing: RDFS.Resource, AnyObject {
    /// comment: A location that something is based near, for some broadly human notion of near.
    ///
    /// label: based near
    ///
    /// term_status: testing
    var based_near: Values<any FOAF.SpatialThing> {
        get
        set
    }
}
/// comment: A document.
///
/// label: Document
///
/// term_status: stable
public protocol Document: RDFS.Resource, AnyObject {
    /// comment: A sha1sum hash, in hex.
    ///
    /// label: sha1sum (hex)
    ///
    /// term_status: unstable
    var sha1: Values<any RDFS.Resource> {
        get
        set
    }
    /// comment: A topic of some page or document.
    ///
    /// label: topic
    ///
    /// term_status: testing
    var topic: Values<any OWL.Thing> {
        get
        set
    }
    /// comment: The primary topic of some page or document.
    ///
    /// label: primary topic
    ///
    /// term_status: stable
    var primaryTopic: (any OWL.Thing)? {
        get
        set
    }
}
/// comment: An organization.
///
/// label: Organization
///
/// term_status: stable
public protocol Organization: FOAF.Agent, AnyObject {
}
/// comment: A class of Agents.
///
/// label: Group
///
/// term_status: stable
public protocol Group: FOAF.Agent, AnyObject {
    /// comment: Indicates a member of a Group
    ///
    /// label: member
    ///
    /// term_status: stable
    var member: Values<any FOAF.Agent> {
        get
        set
    }
}
/// comment: A project (a collective endeavour of some kind).
///
/// label: Project
///
/// term_status: testing
public protocol Project: RDFS.Resource, AnyObject {
}
/// comment: An image.
///
/// label: Image
///
/// term_status: stable
public protocol Image: FOAF.Document, AnyObject {
    /// comment: A thing depicted in this representation.
    ///
    /// label: depicts
    ///
    /// term_status: testing
    var depicts: Values<any OWL.Thing> {
        get
        set
    }
    /// comment: A derived thumbnail image.
    ///
    /// label: thumbnail
    ///
    /// term_status: testing
    var thumbnail: Values<any FOAF.Image> {
        get
        set
    }
}
/// comment: A personal profile RDF document.
///
/// label: PersonalProfileDocument
///
/// term_status: testing
public protocol PersonalProfileDocument: FOAF.Document, AnyObject {
}
/// comment: An online account.
///
/// label: Online Account
///
/// term_status: testing
public protocol OnlineAccount: OWL.Thing, AnyObject {
    /// comment: Indicates a homepage of the service provide for this online account.
    ///
    /// label: account service homepage
    ///
    /// term_status: testing
    var accountServiceHomepage: Values<any FOAF.Document> {
        get
        set
    }
    /// comment: Indicates the name (identifier) associated with this online account.
    ///
    /// label: account name
    ///
    /// term_status: testing
    var accountName: Values<any RDFS.Literal> {
        get
        set
    }
}
/// comment: An online gaming account.
///
/// label: Online Gaming Account
///
/// term_status: unstable
public protocol OnlineGamingAccount: FOAF.OnlineAccount, AnyObject {
}
/// comment: An online e-commerce account.
///
/// label: Online E-commerce Account
///
/// term_status: unstable
public protocol OnlineEcommerceAccount: FOAF.OnlineAccount, AnyObject {
}
/// comment: An online chat account.
///
/// label: Online Chat Account
///
/// term_status: unstable
public protocol OnlineChatAccount: FOAF.OnlineAccount, AnyObject {
}
/// label: Concept
public protocol Concept: RDFS.Resource, AnyObject {
    /// comment: The underlying or 'focal' entity associated with some SKOS-described concept.
    ///
    /// label: focus
    ///
    /// term_status: testing
    var focus: Values<any OWL.Thing> {
        get
        set
    }
}
public protocol Assurance: RDFS.Resource {
    var assurance: Values<any RDFS.Resource> {
        get
        set
    }
}
public protocol Src_assurance: RDFS.Resource {
    var src_assurance: Values<any RDFS.Resource> {
        get
        set
    }
}
public protocol Term_status: RDFS.Resource {
    var term_status: Values<any RDFS.Resource> {
        get
        set
    }
}
public protocol Description: RDFS.Resource {
    var description: Values<any RDFS.Resource> {
        get
        set
    }
}
public protocol Date: RDFS.Resource {
    var date: Values<any RDFS.Resource> {
        get
        set
    }
}
/// comment: A checksum for the DNA of some thing. Joke.
///
/// label: DNA checksum
///
/// term_status: archaic
public protocol DnaChecksum: RDFS.Resource {
    /// comment: A checksum for the DNA of some thing. Joke.
    ///
    /// label: DNA checksum
    ///
    /// term_status: archaic
    var dnaChecksum: Values<any RDFS.Literal> {
        get
        set
    }
}
/// comment: Title (Mr, Mrs, Ms, Dr. etc)
///
/// label: title
///
/// term_status: testing
public protocol Title: RDFS.Resource {
    /// comment: Title (Mr, Mrs, Ms, Dr. etc)
    ///
    /// label: title
    ///
    /// term_status: testing
    var title: Values<any RDFS.Resource> {
        get
        set
    }
}
/// comment: A short informal nickname characterising an agent (includes login identifiers, IRC and other chat nicknames).
///
/// label: nickname
///
/// term_status: testing
public protocol Nick: RDFS.Resource {
    /// comment: A short informal nickname characterising an agent (includes login identifiers, IRC and other chat nicknames).
    ///
    /// label: nickname
    ///
    /// term_status: testing
    var nick: Values<any RDFS.Resource> {
        get
        set
    }
}
/// comment: A name for some thing.
///
/// label: name
///
/// term_status: testing
public protocol Name: RDFS.Resource {
    /// comment: A name for some thing.
    ///
    /// label: name
    ///
    /// term_status: testing
    var name: Values<any RDFS.Literal> {
        get
        set
    }
}
/// comment: The given name of some person.
///
/// label: Given name
///
/// term_status: testing
public protocol GivenName: RDFS.Resource {
    /// comment: The given name of some person.
    ///
    /// label: Given name
    ///
    /// term_status: testing
    var givenName: Values<any RDFS.Resource> {
        get
        set
    }
}
/// comment: The given name of some person.
///
/// label: Given name
///
/// term_status: archaic
public protocol Givenname: RDFS.Resource {
    /// comment: The given name of some person.
    ///
    /// label: Given name
    ///
    /// term_status: archaic
    var givenname: Values<any RDFS.Resource> {
        get
        set
    }
}
/// comment: A phone,  specified using fully qualified tel: URI scheme (refs: http://www.w3.org/Addressing/schemes.html#tel).
///
/// label: phone
///
/// term_status: testing
public protocol Phone: RDFS.Resource {
    /// comment: A phone,  specified using fully qualified tel: URI scheme (refs: http://www.w3.org/Addressing/schemes.html#tel).
    ///
    /// label: phone
    ///
    /// term_status: testing
    var phone: Values<any RDFS.Resource> {
        get
        set
    }
}
/// comment: A homepage for some thing.
///
/// label: homepage
///
/// term_status: stable
public protocol Homepage: RDFS.Resource {
    /// comment: A homepage for some thing.
    ///
    /// label: homepage
    ///
    /// term_status: stable
    var homepage: Values<any FOAF.Document> {
        get
        set
    }
}
/// comment: An agent that  made this thing.
///
/// label: maker
///
/// term_status: stable
public protocol Maker: RDFS.Resource {
    /// comment: An agent that  made this thing.
    ///
    /// label: maker
    ///
    /// term_status: stable
    var maker: Values<any FOAF.Agent> {
        get
        set
    }
}
/// comment: A depiction of some thing.
///
/// label: depiction
///
/// term_status: testing
public protocol Depiction: RDFS.Resource {
    /// comment: A depiction of some thing.
    ///
    /// label: depiction
    ///
    /// term_status: testing
    var depiction: Values<any FOAF.Image> {
        get
        set
    }
}
/// comment: An organization funding a project or person.
///
/// label: funded by
///
/// term_status: archaic
public protocol FundedBy: RDFS.Resource {
    /// comment: An organization funding a project or person.
    ///
    /// label: funded by
    ///
    /// term_status: archaic
    var fundedBy: Values<any OWL.Thing> {
        get
        set
    }
}
/// comment: A logo representing some thing.
///
/// label: logo
///
/// term_status: testing
public protocol Logo: RDFS.Resource {
    /// comment: A logo representing some thing.
    ///
    /// label: logo
    ///
    /// term_status: testing
    var logo: Values<any OWL.Thing> {
        get
        set
    }
}
/// comment: A document that this thing is the primary topic of.
///
/// label: is primary topic of
///
/// term_status: stable
public protocol IsPrimaryTopicOf: RDFS.Resource {
    /// comment: A document that this thing is the primary topic of.
    ///
    /// label: is primary topic of
    ///
    /// term_status: stable
    var isPrimaryTopicOf: Values<any FOAF.Document> {
        get
        set
    }
}
/// comment: A page or document about this thing.
///
/// label: page
///
/// term_status: stable
public protocol Page: RDFS.Resource {
    /// comment: A page or document about this thing.
    ///
    /// label: page
    ///
    /// term_status: stable
    var page: Values<any FOAF.Document> {
        get
        set
    }
}
/// comment: A theme.
///
/// label: theme
///
/// term_status: archaic
public protocol Theme: RDFS.Resource {
    /// comment: A theme.
    ///
    /// label: theme
    ///
    /// term_status: archaic
    var theme: Values<any OWL.Thing> {
        get
        set
    }
}
/// comment: Indicates the class of individuals that are a member of a Group
///
/// label: membershipClass
///
/// term_status: unstable
public protocol MembershipClass: RDFS.Resource {
    /// comment: Indicates the class of individuals that are a member of a Group
    ///
    /// label: membershipClass
    ///
    /// term_status: unstable
    var membershipClass: Values<any RDFS.Resource> {
        get
        set
    }
}
/// The namespace the documents declare these terms in.
public var namespace: String {
    "http://xmlns.com/foaf/0.1/"
}
/// The namespace the documents declare these terms in.
public var namespace1_1Namespace: String {
    "http://purl.org/dc/elements/1.1/"
}
/// The namespace the documents declare these terms in.
public var wgs84_posNamespace: String {
    "http://www.w3.org/2003/01/geo/wgs84_pos#"
}
/// The namespace the documents declare these terms in.
public var nsNamespace: String {
    "http://www.w3.org/2003/06/sw-vocab-status/ns#"
}
/// The namespace the documents declare these terms in.
public var coreNamespace: String {
    "http://www.w3.org/2004/02/skos/core#"
}
/// The namespace the documents declare these terms in.
public var namespace0_1Namespace: String {
    "http://xmlns.com/wot/0.1/"
}
/// The statements of the documents FOAF is translated from.
public struct OntologyDescription: Encodable, Sendable {
    private enum CodingKeys: CodingKey {
        case id
        case type
        case description
        case title
        case term_status
        case label
        case comment
        case isDefinedBy
        case equivalentClass
        case subClassOf
        case disjointWith
        case domain
        case range
        case subPropertyOf
        case inverseOf
        case equivalentProperty
        var stringValue: String {
            switch self {
            case .id:
                "@id"
            case .type:
                RDF.namespace + "type"
            case .description:
                FOAF.namespace1_1Namespace + "description"
            case .title:
                "http://purl.org/dc/elements/1.1/title"
            case .term_status:
                FOAF.nsNamespace + "term_status"
            case .label:
                RDFS.namespace + "label"
            case .comment:
                RDFS.namespace + "comment"
            case .isDefinedBy:
                RDFS.namespace + "isDefinedBy"
            case .equivalentClass:
                OWL.namespace + "equivalentClass"
            case .subClassOf:
                RDFS.namespace + "subClassOf"
            case .disjointWith:
                OWL.namespace + "disjointWith"
            case .domain:
                RDFS.namespace + "domain"
            case .range:
                RDFS.namespace + "range"
            case .subPropertyOf:
                RDFS.namespace + "subPropertyOf"
            case .inverseOf:
                OWL.namespace + "inverseOf"
            case .equivalentProperty:
                OWL.namespace + "equivalentProperty"
            }
        }
        init?(stringValue: String) {
            return nil
        }
        var intValue: Int? {
            nil
        }
        init?(intValue: Int) {
            return nil
        }
    }
    public init() {
    }
    /// Writes every statement of the documents.
    public func encode(to encoder: any Encoder) throws {
        var subjects = encoder.unkeyedContainer()
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace, forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Ontology", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .description)
                try objects.encode("The Friend of a Friend (FOAF) RDF vocabulary, described using W3C RDF Schema and the Web Ontology Language.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .title)
                try objects.encode("Friend of a Friend (FOAF) vocabulary")
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace0_1Namespace + "assurance", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "AnnotationProperty", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace0_1Namespace + "src_assurance", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "AnnotationProperty", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.nsNamespace + "term_status", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "AnnotationProperty", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace1_1Namespace + "description", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "AnnotationProperty", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode("http://purl.org/dc/elements/1.1/title", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "AnnotationProperty", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace1_1Namespace + "date", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "AnnotationProperty", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(RDFS.namespace + "Class", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Class", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "LabelProperty", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "Class", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Class", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("unstable")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("Label Property")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A foaf:LabelProperty is any RDF property with texual values that serve as labels.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "Person", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "Class", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Class", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A person.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("Person")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("stable")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .equivalentClass)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode("http://schema.org/Person", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode("http://www.w3.org/2000/10/swap/pim/contact#Person", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subClassOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Agent", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.wgs84_posNamespace + "SpatialThing", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .disjointWith)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Organization", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Project", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "Agent", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Class", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "Class", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("An agent (eg. person, group, software or physical artifact).")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("Agent")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("stable")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .equivalentClass)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode("http://purl.org/dc/terms/Agent", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.wgs84_posNamespace + "SpatialThing", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Class", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("Spatial Thing")
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "Document", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "Class", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Class", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A document.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("Document")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("stable")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .equivalentClass)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode("http://schema.org/CreativeWork", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .disjointWith)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Organization", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Project", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "Organization", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "Class", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Class", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("An organization.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("Organization")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("stable")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subClassOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Agent", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .disjointWith)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Person", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Document", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "Group", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "Class", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Class", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A class of Agents.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("Group")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("stable")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subClassOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Agent", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "Project", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "Class", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Class", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A project (a collective endeavour of some kind).")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("Project")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .disjointWith)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Person", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Document", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "Image", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "Class", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Class", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("An image.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("Image")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("stable")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .equivalentClass)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode("http://schema.org/ImageObject", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subClassOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Document", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "PersonalProfileDocument", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "Class", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Class", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A personal profile RDF document.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("PersonalProfileDocument")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subClassOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Document", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "OnlineAccount", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "Class", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Class", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("An online account.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("Online Account")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subClassOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Thing", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(OWL.namespace + "Thing", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("Thing")
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "OnlineGamingAccount", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "Class", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Class", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("An online gaming account.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("Online Gaming Account")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("unstable")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subClassOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "OnlineAccount", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "OnlineEcommerceAccount", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "Class", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Class", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("An online e-commerce account.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("Online E-commerce Account")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("unstable")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subClassOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "OnlineAccount", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "OnlineChatAccount", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "Class", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Class", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("An online chat account.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("Online Chat Account")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("unstable")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subClassOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "OnlineAccount", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "mbox", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "InverseFunctionalProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A  personal mailbox, ie. an Internet mailbox associated with exactly one owner, the first owner of this mailbox. This is a 'static inverse functional property', in that  there is (across time and change) at most one individual that ever has any particular value for foaf:mbox.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("personal mailbox")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("stable")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Agent", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Thing", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "mbox_sha1sum", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "InverseFunctionalProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "DatatypeProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("The sha1sum of the URI of an Internet mailbox associated with exactly one owner, the  first owner of the mailbox.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("sha1sum of a personal mailbox URI name")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Agent", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "Literal", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "gender", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "FunctionalProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "DatatypeProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("The gender of this Agent (typically but not necessarily 'male' or 'female').")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("gender")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Agent", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "Literal", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "geekcode", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "DatatypeProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A textual geekcode for this person, see http://www.geekcode.com/geek.html")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("geekcode")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("archaic")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Person", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "Literal", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "dnaChecksum", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "DatatypeProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A checksum for the DNA of some thing. Joke.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("DNA checksum")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("archaic")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "Literal", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "sha1", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "DatatypeProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A sha1sum hash, in hex.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("sha1sum (hex)")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("unstable")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Document", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "based_near", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A location that something is based near, for some broadly human notion of near.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("based near")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.wgs84_posNamespace + "SpatialThing", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.wgs84_posNamespace + "SpatialThing", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "title", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "DatatypeProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("Title (Mr, Mrs, Ms, Dr. etc)")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("title")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "nick", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "DatatypeProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A short informal nickname characterising an agent (includes login identifiers, IRC and other chat nicknames).")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("nickname")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "jabberID", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "DatatypeProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "InverseFunctionalProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A jabber ID for something.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("jabber ID")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Agent", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "Literal", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "aimChatID", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "DatatypeProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "InverseFunctionalProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("An AIM chat ID")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("AIM chat ID")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subPropertyOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "nick", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Agent", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "Literal", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "skypeID", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "DatatypeProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A Skype ID")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("Skype ID")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subPropertyOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "nick", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Agent", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "Literal", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "icqChatID", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "DatatypeProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "InverseFunctionalProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("An ICQ chat ID")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("ICQ chat ID")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subPropertyOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "nick", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Agent", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "Literal", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "yahooChatID", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "DatatypeProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "InverseFunctionalProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A Yahoo chat ID")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("Yahoo chat ID")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subPropertyOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "nick", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Agent", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "Literal", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "msnChatID", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "DatatypeProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "InverseFunctionalProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("An MSN chat ID")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("MSN chat ID")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subPropertyOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "nick", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Agent", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "Literal", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "name", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "DatatypeProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A name for some thing.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("name")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Thing", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "Literal", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subPropertyOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "label", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "firstName", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "DatatypeProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("The first name of a person.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("firstName")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Person", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "Literal", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "lastName", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "DatatypeProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("The last name of a person.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("lastName")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Person", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "Literal", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "givenName", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "DatatypeProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("The given name of some person.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("Given name")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "givenname", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "DatatypeProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("The given name of some person.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("Given name")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("archaic")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "surname", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "DatatypeProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("The surname of some person.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("Surname")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("archaic")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Person", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "Literal", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "family_name", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "DatatypeProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("The family name of some person.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("family_name")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("archaic")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Person", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "Literal", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "familyName", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "DatatypeProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("The family name of some person.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("familyName")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Person", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "Literal", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "phone", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A phone,  specified using fully qualified tel: URI scheme (refs: http://www.w3.org/Addressing/schemes.html#tel).")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("phone")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "homepage", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "InverseFunctionalProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A homepage for some thing.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("homepage")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("stable")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subPropertyOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "page", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "isPrimaryTopicOf", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Thing", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Document", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "weblog", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "InverseFunctionalProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A weblog of some thing (whether person, group, company etc.).")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("weblog")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("stable")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subPropertyOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "page", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Agent", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Document", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "openid", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "InverseFunctionalProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("An OpenID for an Agent.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("openid")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subPropertyOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "isPrimaryTopicOf", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Agent", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Document", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "tipjar", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A tipjar document for this agent, describing means for payment and reward.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("tipjar")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subPropertyOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "page", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Agent", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Document", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "plan", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "DatatypeProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A .plan comment, in the tradition of finger and '.plan' files.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("plan")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Person", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "Literal", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "made", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("Something that was made by this agent.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("made")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("stable")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Agent", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Thing", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .inverseOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "maker", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "maker", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("An agent that  made this thing.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("maker")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("stable")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .equivalentProperty)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode("http://purl.org/dc/terms/creator", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Thing", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Agent", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .inverseOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "made", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "img", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("An image that can be used to represent some thing (ie. those depictions which are particularly representative of something, eg. one's photo on a homepage).")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("image")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Person", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Image", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subPropertyOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "depiction", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "depiction", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A depiction of some thing.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("depiction")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Thing", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Image", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .inverseOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "depicts", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "depicts", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A thing depicted in this representation.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("depicts")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Thing", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Image", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .inverseOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "depiction", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "thumbnail", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A derived thumbnail image.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("thumbnail")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Image", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Image", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "myersBriggs", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "DatatypeProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A Myers Briggs (MBTI) personality classification.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("myersBriggs")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Person", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "Literal", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "workplaceHomepage", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A workplace homepage of some person; the homepage of an organization they work for.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("workplace homepage")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Person", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Document", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "workInfoHomepage", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A work info homepage of some person; a page about their work for some organization.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("work info homepage")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Person", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Document", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "schoolHomepage", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A homepage of a school attended by the person.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("schoolHomepage")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Person", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Document", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "knows", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A person known by this person (indicating some level of reciprocated interaction between the parties).")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("knows")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("stable")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Person", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Person", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "interest", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A page about a topic of interest to this person.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("interest")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Agent", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Document", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "topic_interest", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A thing of interest to this person.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("topic_interest")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Agent", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Thing", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "publications", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A link to the publications of this person.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("publications")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Person", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Document", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "currentProject", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A current project this person works on.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("current project")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Person", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Thing", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "pastProject", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A project this person has previously worked on.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("past project")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Person", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Thing", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "fundedBy", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("An organization funding a project or person.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("funded by")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("archaic")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Thing", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Thing", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "logo", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "InverseFunctionalProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A logo representing some thing.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("logo")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Thing", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Thing", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "topic", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A topic of some page or document.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("topic")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Document", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Thing", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .inverseOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "page", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "primaryTopic", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "FunctionalProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("The primary topic of some page or document.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("primary topic")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("stable")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Document", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Thing", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .inverseOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "isPrimaryTopicOf", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "focus", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("The underlying or 'focal' entity associated with some SKOS-described concept.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("focus")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.coreNamespace + "Concept", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Thing", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.coreNamespace + "Concept", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("Concept")
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "isPrimaryTopicOf", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "InverseFunctionalProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A document that this thing is the primary topic of.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("is primary topic of")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("stable")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .subPropertyOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "page", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .inverseOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "primaryTopic", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Thing", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Document", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "page", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A page or document about this thing.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("page")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("stable")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Thing", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Document", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .inverseOf)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "topic", forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "theme", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A theme.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("theme")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("archaic")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Thing", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "Thing", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "account", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("Indicates an account held by this agent.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("account")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Agent", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "OnlineAccount", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "holdsAccount", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("Indicates an account held by this agent.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("account")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("archaic")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Agent", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "OnlineAccount", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "accountServiceHomepage", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("Indicates a homepage of the service provide for this online account.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("account service homepage")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "OnlineAccount", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Document", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "accountName", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "DatatypeProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("Indicates the name (identifier) associated with this online account.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("account name")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("testing")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "OnlineAccount", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "Literal", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "member", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "ObjectProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("Indicates a member of a Group")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("member")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("stable")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Group", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Agent", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "membershipClass", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "AnnotationProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("Indicates the class of individuals that are a member of a Group")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("membershipClass")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("unstable")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "birthday", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "FunctionalProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "DatatypeProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("The birthday of this Agent, represented in mm-dd string form, eg. '12-31'.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("birthday")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("unstable")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Agent", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "Literal", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "age", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "FunctionalProperty", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "DatatypeProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("The age in years of some agent.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("age")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("unstable")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Agent", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "Literal", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
        do {
            var node = subjects.nestedContainer(keyedBy: CodingKeys.self)
            try node.encode(FOAF.namespace + "status", forKey: .id)
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .type)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDF.namespace + "Property", forKey: .id)
                }
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(OWL.namespace + "DatatypeProperty", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .comment)
                try objects.encode("A string expressing what the user is happy for the general public (normally) to know about their current activity.")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .label)
                try objects.encode("status")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .term_status)
                try objects.encode("unstable")
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .domain)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace + "Agent", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .range)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(RDFS.namespace + "Literal", forKey: .id)
                }
            }
            do {
                var objects = node.nestedUnkeyedContainer(forKey: .isDefinedBy)
                do {
                    var node = objects.nestedContainer(keyedBy: CodingKeys.self)
                    try node.encode(FOAF.namespace, forKey: .id)
                }
            }
        }
    }
}
/// FOAF as its documents state it, every statement of them.
public let ontology = OntologyDescription()
