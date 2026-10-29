import RDFCore
import RDFKit
import FOAF
import ReferencedVocabularies

/// The Web Access Control (WAC) vocabulary.
///
/// Namespace `http://www.w3.org/ns/auth/acl#`, declared from its namespace document (http://www.w3.org/ns/auth/acl).
///
/// Classes, properties and individuals are declared as the published
/// vocabulary declares them: their types (including `owl:FunctionalProperty`
/// and `owl:InverseFunctionalProperty`), superclasses, superproperties,
/// domains, ranges, labels and comments. `owl:inverseOf`, `owl:equivalentClass`,
/// `owl:equivalentProperty` and `owl:disjointWith` statements are not, because
/// the DSL has no annotation for them yet.
@Ontology
public struct ACL: Ontology {
    public init() {}

    public func content() -> Content {
        Namespace("http://www.w3.org/ns/auth/acl#")

        Class("Access") {
            Type(RDFS.Class)
            Label("access")
            Comment("Any kind of access to a resource. Don't use this, use R W and RW")
        }

        Class("Append") {
            Type(RDFS.Class)
            SubClassOf(ACL.Access)
            SubClassOf(ACL.Write)
            Label("append")
            Comment("Append accesses are specific write access which only add information, and do not remove information. For text files, for example, append access allows bytes to be added onto the end of the file. For RDF graphs, Append access allows adds triples to the graph but does not remove any. Append access is useful for dropbox functionality. Dropbox can be used for link notification, which the information added is a notification that a some link has been made elsewhere relevant to the given resource.")
        }

        Class("AuthenticatedAgent") {
            Type(RDFS.Class)
            SubClassOf(Foaf.Agent)
            Label("Anyone authenticated")
            Comment("A class of agents who have been authenticated. In other words, anyone can access this resource, but not anonymously. The social expectation is that the authentication process will provide an identify and a name, or pseudonym. (A new ID should not be minted for every access: the intent is that the user is able to continue to use the ID for continues interactions with peers, and for example to develop a reputation)")
        }

        Class("Authorization") {
            Type(RDFS.Class)
            Label("authorization")
            Comment("An element of access control, allowing agent to agents access of some kind to resources or classes of resources")
        }

        Class("Control") {
            Type(RDFS.Class)
            SubClassOf(ACL.Access)
            Label("control")
            Comment("Allows read/write access to the ACL for the resource(s)")
        }

        Class("Origin") {
            Type(RDFS.Class)
            Label("Origin")
            Comment("An Origin is basically a web site (Note WITHOUT the trailing slash after the domain name and port in its URI) and is the basis for controlling access to data by web apps in the Same Origin Model of web security. All scripts from the same origin are given the same right.")
        }

        Class("Read") {
            Type(RDFS.Class)
            SubClassOf(ACL.Access)
            Label("read")
            Comment("The class of read operations")
        }

        Class("Write") {
            Type(RDFS.Class)
            SubClassOf(ACL.Access)
            Label("write")
        }

        Property("accessControl") {
            Type(RDF.Property)
            SubPropertyOf(RDFS.seeAlso)
            Domain(Gen.InformationResource)
            Range(Gen.InformationResource)
            Label("access control")
            Comment("The Access Control file for this information resource. This may of course be a virtual resource implemented by the access control system. Note that HTTP header `Link: <foo.acl>; rel=\"acl\"` can also be used for this.")
        }

        Property("accessTo") {
            Type(RDF.Property)
            Domain(ACL.Authorization)
            Range(Gen.InformationResource)
            Label("to")
            Comment("The information resource to which access is being granted.")
        }

        Property("accessToClass") {
            Type(RDF.Property)
            Domain(ACL.Authorization)
            Range(RDFS.Class)
            Label("to all in")
            Comment("A class of information resources to which access is being granted.")
        }

        Property("agent") {
            Type(RDF.Property)
            Domain(ACL.Authorization)
            Range(Foaf.Agent)
            Label("agent")
            Comment("A person or social entity to being given the right")
        }

        Property("agentClass") {
            Type(RDF.Property)
            Domain(ACL.Authorization)
            Range(RDFS.Class)
            Label("agent class")
            Comment("A class of persons or social entities to being given the right")
        }

        Property("agentGroup") {
            Type(RDF.Property)
            Domain(ACL.Authorization)
            Range(VCard.Group)
            Label("agent group")
            Comment("A group of persons or social entities to being given the right. The right is given to any entity which is a vcard:member of the group, as defined by the document received when the Group is dereferenced.")
        }

        Property("default") {
            Type(RDF.Property)
            Domain(ACL.Authorization)
            Label("default access for things in this")
            Comment("If a resource has no ACL file (it is 404), then access to the resource is given by the ACL of the immediately containing directory, or failing that (404) the ACL of the recursively next containing directory which has an ACL file. Within that ACL file, any Authorization which has that directory as its acl:default applies to the resource. (The highest directory must have an ACL file.)")
        }

        Property("defaultForNew") {
            Type(RDF.Property)
            Domain(ACL.Authorization)
            Label("default access for new things in the object")
            Comment("THIS IS OBSOLETE AS OF 2017-08-01. See 'default'. Was: A directory for which this authorization is used for new files in the directory.")
        }

        Property("delegates") {
            Type(RDF.Property)
            Range(Foaf.Agent)
            Label("delegates")
            Comment("Delegates a person or another agent to act on behalf of the agent. For example, Alice delegates Bob to act on behalf of Alice for ACL purposes.")
        }

        Property("mode") {
            Type(RDF.Property)
            Domain(ACL.Authorization)
            Range(RDFS.Class)
            Label("access mode")
            Comment("A mode of access such as read or write.")
        }

        Property("origin") {
            Type(RDF.Property)
            Domain(ACL.Authorization)
            Range(ACL.Origin)
            Label("origin")
            Comment("A web application, identified by its Origin, such as <https://scripts.example.com>, being given the right. When a user of the web application at a certain origin accesses the server, then the browser sets the Origin: header to warn that a possibly untrusted webapp is being used. Then, BOTH the user AND the origin must have the required access.")
        }

        Property("owner") {
            Type(RDF.Property)
            Range(Foaf.Agent)
            Label("owner")
            Comment("The person or other agent which owns this. For example, the owner of a file in a filesystem. There is a sense of \"right to control\". Typically defaults to the agent who created something, but can be changed.")
        }
    }
}
