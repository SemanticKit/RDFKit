import RDFCore
import RDFKit
import ReferencedVocabularies

/// The Friend of a Friend (FOAF) vocabulary, version 0.99.
///
/// Namespace `http://xmlns.com/foaf/0.1/`, declared from the FOAF specification's RDF (http://xmlns.com/foaf/spec/index.rdf).
///
/// Classes, properties and individuals are declared as the published
/// vocabulary declares them: their types (including `owl:FunctionalProperty`
/// and `owl:InverseFunctionalProperty`), superclasses, superproperties,
/// domains, ranges, labels and comments. `owl:inverseOf`, `owl:equivalentClass`,
/// `owl:equivalentProperty` and `owl:disjointWith` statements are not, because
/// the DSL has no annotation for them yet.
///
/// A WebID profile describes its agent with FOAF: `Foaf.PersonIndividual` is a
/// person, and `knows` links people to each other. The properties whose domain is
/// `owl:Thing`, such as `foaf:name`, apply to any resource and are read through
/// their term: `Foaf.name[alice]`.
@Ontology
public struct Foaf: Ontology {
    public init() {}

    public func content() -> Content {
        Namespace("http://xmlns.com/foaf/0.1/")

        Class("Agent") {
            Type(RDFS.Class)
            Type(OWL.Class)
            Label("Agent")
            Comment("An agent (eg. person, group, software or physical artifact).")
        }

        Class("Document") {
            Type(RDFS.Class)
            Type(OWL.Class)
            Label("Document")
            Comment("A document.")
        }

        Class("Group") {
            Type(RDFS.Class)
            Type(OWL.Class)
            SubClassOf(Foaf.Agent)
            Label("Group")
            Comment("A class of Agents.")
        }

        Class("Image") {
            Type(RDFS.Class)
            Type(OWL.Class)
            SubClassOf(Foaf.Document)
            Label("Image")
            Comment("An image.")
        }

        Class("LabelProperty") {
            Type(RDFS.Class)
            Type(OWL.Class)
            Label("Label Property")
            Comment("A foaf:LabelProperty is any RDF property with texual values that serve as labels.")
        }

        Class("OnlineAccount") {
            Type(RDFS.Class)
            Type(OWL.Class)
            SubClassOf(OWL.Thing)
            Label("Online Account")
            Comment("An online account.")
        }

        Class("OnlineChatAccount") {
            Type(RDFS.Class)
            Type(OWL.Class)
            SubClassOf(Foaf.OnlineAccount)
            Label("Online Chat Account")
            Comment("An online chat account.")
        }

        Class("OnlineEcommerceAccount") {
            Type(RDFS.Class)
            Type(OWL.Class)
            SubClassOf(Foaf.OnlineAccount)
            Label("Online E-commerce Account")
            Comment("An online e-commerce account.")
        }

        Class("OnlineGamingAccount") {
            Type(RDFS.Class)
            Type(OWL.Class)
            SubClassOf(Foaf.OnlineAccount)
            Label("Online Gaming Account")
            Comment("An online gaming account.")
        }

        Class("Organization") {
            Type(RDFS.Class)
            Type(OWL.Class)
            SubClassOf(Foaf.Agent)
            Label("Organization")
            Comment("An organization.")
        }

        Class("Person") {
            Type(RDFS.Class)
            Type(OWL.Class)
            SubClassOf(Contact.Person)
            SubClassOf(Geo.SpatialThing)
            SubClassOf(Foaf.Agent)
            Label("Person")
            Comment("A person.")
        }

        Class("PersonalProfileDocument") {
            Type(RDFS.Class)
            Type(OWL.Class)
            SubClassOf(Foaf.Document)
            Label("PersonalProfileDocument")
            Comment("A personal profile RDF document.")
        }

        Class("Project") {
            Type(RDFS.Class)
            Type(OWL.Class)
            Label("Project")
            Comment("A project (a collective endeavour of some kind).")
        }

        Property("account") {
            Type(RDF.Property)
            Type(OWL.ObjectProperty)
            Domain(Foaf.Agent)
            Range(Foaf.OnlineAccount)
            Label("account")
            Comment("Indicates an account held by this agent.")
        }

        Property("accountName") {
            Type(RDF.Property)
            Type(OWL.DatatypeProperty)
            Domain(Foaf.OnlineAccount)
            Range(RDFS.Literal)
            Label("account name")
            Comment("Indicates the name (identifier) associated with this online account.")
        }

        Property("accountServiceHomepage") {
            Type(RDF.Property)
            Type(OWL.ObjectProperty)
            Domain(Foaf.OnlineAccount)
            Range(Foaf.Document)
            Label("account service homepage")
            Comment("Indicates a homepage of the service provide for this online account.")
        }

        Property("age") {
            Type(RDF.Property)
            Type(OWL.DatatypeProperty)
            Type(OWL.FunctionalProperty)
            Domain(Foaf.Agent)
            Range(RDFS.Literal)
            Label("age")
            Comment("The age in years of some agent.")
        }

        Property("aimChatID") {
            Type(RDF.Property)
            Type(OWL.DatatypeProperty)
            Type(OWL.InverseFunctionalProperty)
            SubPropertyOf(Foaf.nick)
            Domain(Foaf.Agent)
            Range(RDFS.Literal)
            Label("AIM chat ID")
            Comment("An AIM chat ID")
        }

        Property("based_near") {
            Type(RDF.Property)
            Type(OWL.ObjectProperty)
            Domain(Geo.SpatialThing)
            Range(Geo.SpatialThing)
            Label("based near")
            Comment("A location that something is based near, for some broadly human notion of near.")
        }

        Property("birthday") {
            Type(RDF.Property)
            Type(OWL.DatatypeProperty)
            Type(OWL.FunctionalProperty)
            Domain(Foaf.Agent)
            Range(RDFS.Literal)
            Label("birthday")
            Comment("The birthday of this Agent, represented in mm-dd string form, eg. '12-31'.")
        }

        Property("currentProject") {
            Type(RDF.Property)
            Type(OWL.ObjectProperty)
            Domain(Foaf.Person)
            Range(OWL.Thing)
            Label("current project")
            Comment("A current project this person works on.")
        }

        Property("depiction") {
            Type(RDF.Property)
            Type(OWL.ObjectProperty)
            Domain(OWL.Thing)
            Range(Foaf.Image)
            Label("depiction")
            Comment("A depiction of some thing.")
        }

        Property("depicts") {
            Type(RDF.Property)
            Type(OWL.ObjectProperty)
            Domain(Foaf.Image)
            Range(OWL.Thing)
            Label("depicts")
            Comment("A thing depicted in this representation.")
        }

        Property("dnaChecksum") {
            Type(RDF.Property)
            Type(OWL.DatatypeProperty)
            Range(RDFS.Literal)
            Label("DNA checksum")
            Comment("A checksum for the DNA of some thing. Joke.")
        }

        Property("familyName") {
            Type(RDF.Property)
            Type(OWL.DatatypeProperty)
            Domain(Foaf.Person)
            Range(RDFS.Literal)
            Label("familyName")
            Comment("The family name of some person.")
        }

        Property("family_name") {
            Type(RDF.Property)
            Type(OWL.DatatypeProperty)
            Domain(Foaf.Person)
            Range(RDFS.Literal)
            Label("family_name")
            Comment("The family name of some person.")
        }

        Property("firstName") {
            Type(RDF.Property)
            Type(OWL.DatatypeProperty)
            Domain(Foaf.Person)
            Range(RDFS.Literal)
            Label("firstName")
            Comment("The first name of a person.")
        }

        Property("focus") {
            Type(RDF.Property)
            Type(OWL.ObjectProperty)
            Domain(SKOS.Concept)
            Range(OWL.Thing)
            Label("focus")
            Comment("The underlying or 'focal' entity associated with some SKOS-described concept.")
        }

        Property("fundedBy") {
            Type(RDF.Property)
            Type(OWL.ObjectProperty)
            Domain(OWL.Thing)
            Range(OWL.Thing)
            Label("funded by")
            Comment("An organization funding a project or person.")
        }

        Property("geekcode") {
            Type(RDF.Property)
            Type(OWL.DatatypeProperty)
            Domain(Foaf.Person)
            Range(RDFS.Literal)
            Label("geekcode")
            Comment("A textual geekcode for this person, see http://www.geekcode.com/geek.html")
        }

        Property("gender") {
            Type(RDF.Property)
            Type(OWL.DatatypeProperty)
            Type(OWL.FunctionalProperty)
            Domain(Foaf.Agent)
            Range(RDFS.Literal)
            Label("gender")
            Comment("The gender of this Agent (typically but not necessarily 'male' or 'female').")
        }

        Property("givenName") {
            Type(RDF.Property)
            Type(OWL.DatatypeProperty)
            Label("Given name")
            Comment("The given name of some person.")
        }

        Property("givenname") {
            Type(RDF.Property)
            Type(OWL.DatatypeProperty)
            Label("Given name")
            Comment("The given name of some person.")
        }

        Property("holdsAccount") {
            Type(RDF.Property)
            Type(OWL.ObjectProperty)
            Domain(Foaf.Agent)
            Range(Foaf.OnlineAccount)
            Label("account")
            Comment("Indicates an account held by this agent.")
        }

        Property("homepage") {
            Type(RDF.Property)
            Type(OWL.InverseFunctionalProperty)
            Type(OWL.ObjectProperty)
            SubPropertyOf(Foaf.isPrimaryTopicOf)
            SubPropertyOf(Foaf.page)
            Domain(OWL.Thing)
            Range(Foaf.Document)
            Label("homepage")
            Comment("A homepage for some thing.")
        }

        Property("icqChatID") {
            Type(RDF.Property)
            Type(OWL.DatatypeProperty)
            Type(OWL.InverseFunctionalProperty)
            SubPropertyOf(Foaf.nick)
            Domain(Foaf.Agent)
            Range(RDFS.Literal)
            Label("ICQ chat ID")
            Comment("An ICQ chat ID")
        }

        Property("img") {
            Type(RDF.Property)
            Type(OWL.ObjectProperty)
            SubPropertyOf(Foaf.depiction)
            Domain(Foaf.Person)
            Range(Foaf.Image)
            Label("image")
            Comment("An image that can be used to represent some thing (ie. those depictions which are particularly representative of something, eg. one's photo on a homepage).")
        }

        Property("interest") {
            Type(RDF.Property)
            Type(OWL.ObjectProperty)
            Domain(Foaf.Agent)
            Range(Foaf.Document)
            Label("interest")
            Comment("A page about a topic of interest to this person.")
        }

        Property("isPrimaryTopicOf") {
            Type(RDF.Property)
            Type(OWL.InverseFunctionalProperty)
            SubPropertyOf(Foaf.page)
            Domain(OWL.Thing)
            Range(Foaf.Document)
            Label("is primary topic of")
            Comment("A document that this thing is the primary topic of.")
        }

        Property("jabberID") {
            Type(RDF.Property)
            Type(OWL.DatatypeProperty)
            Type(OWL.InverseFunctionalProperty)
            Domain(Foaf.Agent)
            Range(RDFS.Literal)
            Label("jabber ID")
            Comment("A jabber ID for something.")
        }

        Property("knows") {
            Type(RDF.Property)
            Type(OWL.ObjectProperty)
            Domain(Foaf.Person)
            Range(Foaf.Person)
            Label("knows")
            Comment("A person known by this person (indicating some level of reciprocated interaction between the parties).")
        }

        Property("lastName") {
            Type(RDF.Property)
            Type(OWL.DatatypeProperty)
            Domain(Foaf.Person)
            Range(RDFS.Literal)
            Label("lastName")
            Comment("The last name of a person.")
        }

        Property("logo") {
            Type(RDF.Property)
            Type(OWL.InverseFunctionalProperty)
            Type(OWL.ObjectProperty)
            Domain(OWL.Thing)
            Range(OWL.Thing)
            Label("logo")
            Comment("A logo representing some thing.")
        }

        Property("made") {
            Type(RDF.Property)
            Type(OWL.ObjectProperty)
            Domain(Foaf.Agent)
            Range(OWL.Thing)
            Label("made")
            Comment("Something that was made by this agent.")
        }

        Property("maker") {
            Type(RDF.Property)
            Type(OWL.ObjectProperty)
            Domain(OWL.Thing)
            Range(Foaf.Agent)
            Label("maker")
            Comment("An agent that made this thing.")
        }

        Property("mbox") {
            Type(RDF.Property)
            Type(OWL.InverseFunctionalProperty)
            Type(OWL.ObjectProperty)
            Domain(Foaf.Agent)
            Range(OWL.Thing)
            Label("personal mailbox")
            Comment("A personal mailbox, ie. an Internet mailbox associated with exactly one owner, the first owner of this mailbox. This is a 'static inverse functional property', in that there is (across time and change) at most one individual that ever has any particular value for foaf:mbox.")
        }

        Property("mbox_sha1sum") {
            Type(RDF.Property)
            Type(OWL.DatatypeProperty)
            Type(OWL.InverseFunctionalProperty)
            Domain(Foaf.Agent)
            Range(RDFS.Literal)
            Label("sha1sum of a personal mailbox URI name")
            Comment("The sha1sum of the URI of an Internet mailbox associated with exactly one owner, the first owner of the mailbox.")
        }

        Property("member") {
            Type(RDF.Property)
            Type(OWL.ObjectProperty)
            Domain(Foaf.Group)
            Range(Foaf.Agent)
            Label("member")
            Comment("Indicates a member of a Group")
        }

        Property("membershipClass") {
            Type(RDF.Property)
            Type(OWL.AnnotationProperty)
            Label("membershipClass")
            Comment("Indicates the class of individuals that are a member of a Group")
        }

        Property("msnChatID") {
            Type(RDF.Property)
            Type(OWL.DatatypeProperty)
            Type(OWL.InverseFunctionalProperty)
            SubPropertyOf(Foaf.nick)
            Domain(Foaf.Agent)
            Range(RDFS.Literal)
            Label("MSN chat ID")
            Comment("An MSN chat ID")
        }

        Property("myersBriggs") {
            Type(RDF.Property)
            Type(OWL.DatatypeProperty)
            Domain(Foaf.Person)
            Range(RDFS.Literal)
            Label("myersBriggs")
            Comment("A Myers Briggs (MBTI) personality classification.")
        }

        Property("name") {
            Type(RDF.Property)
            Type(OWL.DatatypeProperty)
            SubPropertyOf(RDFS.label)
            Domain(OWL.Thing)
            Range(RDFS.Literal)
            Label("name")
            Comment("A name for some thing.")
        }

        Property("nick") {
            Type(RDF.Property)
            Type(OWL.DatatypeProperty)
            Label("nickname")
            Comment("A short informal nickname characterising an agent (includes login identifiers, IRC and other chat nicknames).")
        }

        Property("openid") {
            Type(RDF.Property)
            Type(OWL.InverseFunctionalProperty)
            Type(OWL.ObjectProperty)
            SubPropertyOf(Foaf.isPrimaryTopicOf)
            Domain(Foaf.Agent)
            Range(Foaf.Document)
            Label("openid")
            Comment("An OpenID for an Agent.")
        }

        Property("page") {
            Type(RDF.Property)
            Type(OWL.ObjectProperty)
            Domain(OWL.Thing)
            Range(Foaf.Document)
            Label("page")
            Comment("A page or document about this thing.")
        }

        Property("pastProject") {
            Type(RDF.Property)
            Type(OWL.ObjectProperty)
            Domain(Foaf.Person)
            Range(OWL.Thing)
            Label("past project")
            Comment("A project this person has previously worked on.")
        }

        Property("phone") {
            Type(RDF.Property)
            Type(OWL.ObjectProperty)
            Label("phone")
            Comment("A phone, specified using fully qualified tel: URI scheme (refs: http://www.w3.org/Addressing/schemes.html#tel).")
        }

        Property("plan") {
            Type(RDF.Property)
            Type(OWL.DatatypeProperty)
            Domain(Foaf.Person)
            Range(RDFS.Literal)
            Label("plan")
            Comment("A .plan comment, in the tradition of finger and '.plan' files.")
        }

        Property("primaryTopic") {
            Type(RDF.Property)
            Type(OWL.FunctionalProperty)
            Type(OWL.ObjectProperty)
            Domain(Foaf.Document)
            Range(OWL.Thing)
            Label("primary topic")
            Comment("The primary topic of some page or document.")
        }

        Property("publications") {
            Type(RDF.Property)
            Type(OWL.ObjectProperty)
            Domain(Foaf.Person)
            Range(Foaf.Document)
            Label("publications")
            Comment("A link to the publications of this person.")
        }

        Property("schoolHomepage") {
            Type(RDF.Property)
            Type(OWL.ObjectProperty)
            Domain(Foaf.Person)
            Range(Foaf.Document)
            Label("schoolHomepage")
            Comment("A homepage of a school attended by the person.")
        }

        Property("sha1") {
            Type(RDF.Property)
            Type(OWL.DatatypeProperty)
            Domain(Foaf.Document)
            Label("sha1sum (hex)")
            Comment("A sha1sum hash, in hex.")
        }

        Property("skypeID") {
            Type(RDF.Property)
            Type(OWL.DatatypeProperty)
            SubPropertyOf(Foaf.nick)
            Domain(Foaf.Agent)
            Range(RDFS.Literal)
            Label("Skype ID")
            Comment("A Skype ID")
        }

        Property("status") {
            Type(RDF.Property)
            Type(OWL.DatatypeProperty)
            Domain(Foaf.Agent)
            Range(RDFS.Literal)
            Label("status")
            Comment("A string expressing what the user is happy for the general public (normally) to know about their current activity.")
        }

        Property("surname") {
            Type(RDF.Property)
            Type(OWL.DatatypeProperty)
            Domain(Foaf.Person)
            Range(RDFS.Literal)
            Label("Surname")
            Comment("The surname of some person.")
        }

        Property("theme") {
            Type(RDF.Property)
            Type(OWL.ObjectProperty)
            Domain(OWL.Thing)
            Range(OWL.Thing)
            Label("theme")
            Comment("A theme.")
        }

        Property("thumbnail") {
            Type(RDF.Property)
            Type(OWL.ObjectProperty)
            Domain(Foaf.Image)
            Range(Foaf.Image)
            Label("thumbnail")
            Comment("A derived thumbnail image.")
        }

        Property("tipjar") {
            Type(RDF.Property)
            Type(OWL.ObjectProperty)
            SubPropertyOf(Foaf.page)
            Domain(Foaf.Agent)
            Range(Foaf.Document)
            Label("tipjar")
            Comment("A tipjar document for this agent, describing means for payment and reward.")
        }

        Property("title") {
            Type(RDF.Property)
            Type(OWL.DatatypeProperty)
            Label("title")
            Comment("Title (Mr, Mrs, Ms, Dr. etc)")
        }

        Property("topic") {
            Type(RDF.Property)
            Type(OWL.ObjectProperty)
            Domain(Foaf.Document)
            Range(OWL.Thing)
            Label("topic")
            Comment("A topic of some page or document.")
        }

        Property("topic_interest") {
            Type(RDF.Property)
            Type(OWL.ObjectProperty)
            Domain(Foaf.Agent)
            Range(OWL.Thing)
            Label("topic_interest")
            Comment("A thing of interest to this person.")
        }

        Property("weblog") {
            Type(RDF.Property)
            Type(OWL.InverseFunctionalProperty)
            Type(OWL.ObjectProperty)
            SubPropertyOf(Foaf.page)
            Domain(Foaf.Agent)
            Range(Foaf.Document)
            Label("weblog")
            Comment("A weblog of some thing (whether person, group, company etc.).")
        }

        Property("workInfoHomepage") {
            Type(RDF.Property)
            Type(OWL.ObjectProperty)
            Domain(Foaf.Person)
            Range(Foaf.Document)
            Label("work info homepage")
            Comment("A work info homepage of some person; a page about their work for some organization.")
        }

        Property("workplaceHomepage") {
            Type(RDF.Property)
            Type(OWL.ObjectProperty)
            Domain(Foaf.Person)
            Range(Foaf.Document)
            Label("workplace homepage")
            Comment("A workplace homepage of some person; the homepage of an organization they work for.")
        }

        Property("yahooChatID") {
            Type(RDF.Property)
            Type(OWL.DatatypeProperty)
            Type(OWL.InverseFunctionalProperty)
            SubPropertyOf(Foaf.nick)
            Domain(Foaf.Agent)
            Range(RDFS.Literal)
            Label("Yahoo chat ID")
            Comment("A Yahoo chat ID")
        }
    }
}
