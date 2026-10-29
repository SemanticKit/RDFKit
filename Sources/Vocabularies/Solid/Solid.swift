import RDFCore
import RDFKit
import FOAF
import LDP
import ReferencedVocabularies

/// The Solid terms vocabulary.
///
/// Namespace `http://www.w3.org/ns/solid/terms#`, declared from its namespace document (http://www.w3.org/ns/solid/terms, `solid-terms.ttl` in solid/vocab).
///
/// Classes, properties and individuals are declared as the published
/// vocabulary declares them: their types (including `owl:FunctionalProperty`
/// and `owl:InverseFunctionalProperty`), superclasses, superproperties,
/// domains, ranges, labels and comments. `owl:inverseOf`, `owl:equivalentClass`,
/// `owl:equivalentProperty` and `owl:disjointWith` statements are not, because
/// the DSL has no annotation for them yet.
///
/// Most Solid properties, such as `solid:oidcIssuer`, have no domain, so they
/// apply to any resource and are read through their term:
/// `Solid.oidcIssuer.values(of: alice)`.
@Ontology
public struct Solid: Ontology {
    public init() {}

    public func content() -> Content {
        Namespace("http://www.w3.org/ns/solid/terms#")

        Class("Account") {
            Type(RDFS.Class)
            Label("Account")
            Comment("A Solid account.")
        }

        Class("Inbox") {
            Type(RDFS.Class)
            Label("Inbox")
            Comment("A resource containing notifications.")
        }

        Class("InsertDeletePatch") {
            Type(RDFS.Class)
            SubClassOf(Solid.Patch)
            Label("Insert/delete patch")
            Comment("A class of patch expressing insertions, deletions, and conditional modifications to a resource that has an RDF-based representation.")
        }

        Class("ListedDocument") {
            Type(RDFS.Class)
            Label("Listed Type Index")
            Comment("Listed Type Index is a registry of resources that are publicly discoverable by outside users and applications.")
        }

        Class("Notification") {
            Type(RDFS.Class)
            Label("Notification")
            Comment("A notification resource.")
        }

        Class("Patch") {
            Type(RDFS.Class)
            Label("Patch")
            Comment("A patch expresses conditional modifications to a resource that has an RDF-based representation.")
        }

        Class("Timeline") {
            Type(RDFS.Class)
            Label("Timeline")
            Comment("A resource containing time ordered items and sub-containers. Sub-containers may be desirable in file based systems to split the timeline into logical components e.g. /yyyy-mm-dd/ as used in ISO 8061.")
        }

        Class("TypeIndex") {
            Type(RDFS.Class)
            Label("Type index")
            Comment("A index of type registries for resources. Applications can register the RDF type they use and list them in the index resource.")
        }

        Class("TypeRegistration") {
            Type(RDFS.Class)
            Label("Type Registration")
            Comment("The registered types that map a RDF classes/types to their locations using either `instance` or `instanceContainer` property.")
        }

        Class("UnlistedDocument") {
            Type(RDFS.Class)
            Label("Unlisted Type Index")
            Comment("Unlisted Type Index is a registry of resources that are private to the user and their apps, for types that are not publicly discoverable.")
        }

        Property("account") {
            Type(RDF.Property)
            Label("account")
            Comment("A solid account belonging to an Agent.")
        }

        Property("deletes") {
            Type(RDF.Property)
            Type(OWL.FunctionalProperty)
            Type(OWL.ObjectProperty)
            Domain(Solid.Patch)
            Range(Log.Formula)
            Label("deletes")
            Comment("The triple patterns this patch removes from the document.")
        }

        Property("forClass") {
            Type(RDF.Property)
            Label("registry class")
            Comment("A class that is used to map an listed or unlisted type index.")
        }

        Property("inbox") {
            Type(RDF.Property)
            SubPropertyOf(LDP.inbox)
            Label("inbox (deprecated)")
            Comment("Deprecated pointer to a Linked Data Notifications inbox; please use http://www.w3.org/ns/ldp#inbox instead.")
        }

        Property("inserts") {
            Type(RDF.Property)
            Type(OWL.FunctionalProperty)
            Type(OWL.ObjectProperty)
            Domain(Solid.Patch)
            Range(Log.Formula)
            Label("inserts")
            Comment("The triple patterns this patch adds to the document.")
        }

        Property("instance") {
            Type(RDF.Property)
            Label("instance")
            Comment("Maps a type to an individual resource, typically an index or a directory listing resource.")
        }

        Property("instanceContainer") {
            Type(RDF.Property)
            Label("instance container")
            Comment("Maps a type to a container which the client would have to list to get the instances of that type.")
        }

        Property("loginEndpoint") {
            Type(RDF.Property)
            Label("loginEndpoint")
            Comment("The login URI of a given server.")
        }

        Property("logoutEndpoint") {
            Type(RDF.Property)
            Label("logoutEndpoint")
            Comment("The logout URI of a given server.")
        }

        Property("notification") {
            Type(RDF.Property)
            Label("notification")
            Comment("Notification resource for an inbox.")
        }

        Property("oidcIssuer") {
            Type(RDF.Property)
            SubPropertyOf(OpenIDConnect.issuer)
            Label("OIDC issuer")
            Comment("The preferred OpenID Connect issuer URI for a given WebID.")
        }

        Property("owner") {
            Type(RDF.Property)
            Range(Foaf.Agent)
            Label("owner")
            Comment("A person or social entity that is considered to have control, rights, and responsibilities over a data storage.")
        }

        Property("patches") {
            Type(RDF.Property)
            Type(OWL.ObjectProperty)
            Domain(Solid.Patch)
            Range(RDFS.Resource)
            Label("patches")
            Comment("The document to which this patch applies.")
        }

        Property("privateLabelIndex") {
            Type(RDF.Property)
            Range(Solid.UnlistedDocument)
            Label("private label index")
            Comment("Points to an unlisted label index resource.")
        }

        Property("privateTypeIndex") {
            Type(RDF.Property)
            Range(Solid.UnlistedDocument)
            Label("private type index")
            Comment("Points to an unlisted type index resource.")
        }

        Property("publicTypeIndex") {
            Type(RDF.Property)
            SubPropertyOf(Solid.typeIndex)
            Range(Solid.ListedDocument)
            Label("public type index")
            Comment("Points to a listed type index resource.")
        }

        Property("read") {
            Type(RDF.Property)
            Domain(SIOC.Post)
            Label("read")
            Comment("Indicates if a message has been read or not. This property should have a boolean datatype.")
        }

        Property("storageDescription") {
            Type(RDF.Property)
            Type(OWL.ObjectProperty)
            Label("storage description")
            Comment("Refers to the resource that provides a description of the storage containing this resource.")
        }

        Property("storageQuota") {
            Type(RDF.Property)
            Type(OWL.DatatypeProperty)
            Domain(Solid.Account)
            Label("Non-volatile memory quota")
            Comment("The quota of non-volatile memory that is available for the account (in bytes)")
        }

        Property("storageUsage") {
            Type(RDF.Property)
            Type(OWL.DatatypeProperty)
            Domain(Solid.Account)
            Label("Non-volatile memory usage")
            Comment("The amount of non-volatile memory that the account have used (in bytes)")
        }

        Property("timeline") {
            Type(RDF.Property)
            Label("timeline")
            Comment("Timeline for a given resource.")
        }

        Property("typeIndex") {
            Type(RDF.Property)
            Range(Solid.TypeIndex)
            Label("type index")
            Comment("Points to a TypeIndex resource.")
        }

        Property("where") {
            Type(RDF.Property)
            Type(OWL.FunctionalProperty)
            Type(OWL.ObjectProperty)
            Domain(Solid.Patch)
            Range(Log.Formula)
            Label("where")
            Comment("The conditions the document and the inserted and deleted triple patterns need to satisfy in order for the patch to be applied.")
        }
    }
}
