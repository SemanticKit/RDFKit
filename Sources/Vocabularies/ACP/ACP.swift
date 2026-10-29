import RDFCore
import RDFKit

/// The Access Control Policy (ACP) vocabulary.
///
/// Namespace `http://www.w3.org/ns/solid/acp#`, declared from the vocabulary of the ACP specification (https://solid.github.io/authorization-panel/acp-specification/, `acp.ttl` in solid/authorization-panel).
///
/// Classes, properties and individuals are declared as the published
/// vocabulary declares them: their types (including `owl:FunctionalProperty`
/// and `owl:InverseFunctionalProperty`), superclasses, superproperties,
/// domains, ranges, labels and comments. `owl:inverseOf`, `owl:equivalentClass`,
/// `owl:equivalentProperty` and `owl:disjointWith` statements are not, because
/// the DSL has no annotation for them yet.
///
/// Some ACP properties are published without an `rdf:type`; they are declared
/// as properties because they have a domain, range or superproperty.
@Ontology
public struct ACP: Ontology {
    public init() {}

    public func content() -> Content {
        Namespace("http://www.w3.org/ns/solid/acp#")

        Class("AccessControl") {
            Type(RDFS.Class)
            Label("Access Control")
            Comment("All Access Controls controlling member resources access via the acp:memberAccessControl property MUST be included in the set of Access Controls linked as acp:accessControl in the effective authorization graph of a resource.")
        }

        Class("AccessControlResource") {
            Type(RDFS.Class)
            Label("Access Control Resource")
            Comment("Both the acp:resource property and its inverse acp:accessControlResource MUST be taken into account in determining the Access Control Resources controlling access to resources.")
        }

        Class("AccessGrant") {
            Type(RDFS.Class)
            Label("Access Grant")
            Comment("Instances of the Access Grant class define sets of Access Modes granted in particular Contexts.")
        }

        Class("AccessMode") {
            Type(RDFS.Class)
            Label("Access Mode")
            Comment("The ACP specification does not define specific Access Modes. Instead, any Access Mode granted is an instance of the Access Mode class. Access Modes and their granularity can be tailored to the needs of an application and Access Modes defined in other vocabularies can also be used (for example, instances of ACL Access).")
        }

        Class("AlwaysSatisfiedRestriction") {
            Type(RDFS.Class)
            Label("Always Satisfied Restriction")
            Comment("Defined instances of the Always Satisfied Restriction class are used in Matcher restrictions to indicate that the restriction is always satisfied. The default behaviour of a Matcher is to not be satisfied, so this is the only way to make a Matcher always satisfied.")
        }

        Class("Context") {
            Type(RDFS.Class)
            Label("Context")
            Comment("Instances of the Context class describe instances of resource access.")
        }

        Class("Matcher") {
            Type(RDFS.Class)
            Label("Matcher")
            Comment("A Matcher MUST be satisfied if and only if: it defines at least one attribute; and, at least one value of each defined attribute matches the Context. ACP engines MUST match the context attributes defined by this specification according to IRI equality and literal term equality.")
        }

        Class("Policy") {
            Type(RDFS.Class)
            Label("Access Policy")
            Comment("A Policy MUST be satisfied if and only if: it references at least one Matcher via an acp:allOf or acp:anyOf property; and, all of its acp:allOf Matchers are satisfied; and, at least one of its acp:anyOf Matchers is satisfied; and, none of its acp:noneOf Matchers are satisfied.")
        }

        Property("accessControl") {
            Type(RDF.Property)
            Domain(ACP.AccessControlResource)
            Range(ACP.AccessControl)
            Label("access control")
            Comment("The access control property connects ACRs to Access Controls.")
        }

        Property("accessControlResource") {
            Type(RDF.Property)
            Range(ACP.AccessControlResource)
            Label("access control resource")
            Comment("The access control resource property connects resources to ACRs controlling access to them. It is the inverse of acp:resource.")
        }

        Property("agent") {
            SubPropertyOf(ACP.attribute)
            Label("agent")
            Comment("In a Matcher, agent attributes define a set of agents, at least one of which MUST match the Context for the Matcher to be satisfied.")
        }

        Property("allOf") {
            Type(RDF.Property)
            Domain(ACP.Policy)
            Range(ACP.Matcher)
            Label("all of")
            Comment("The all of property connects Policies to a set of Matchers, all of which MUST be satisfied for the Policy to be satisfied.")
        }

        Property("allow") {
            Type(RDF.Property)
            Domain(ACP.Policy)
            Range(ACP.AccessMode)
            Label("allow")
            Comment("The allow property connects Policies to the Access Modes they allow if satisfied.")
        }

        Property("anyOf") {
            Type(RDF.Property)
            Domain(ACP.Policy)
            Range(ACP.Matcher)
            Label("any of")
            Comment("The any of property connects Policies to a set of Matchers, at least one of which MUST be satisfied for the Policy to be satisfied.")
        }

        Property("apply") {
            Type(RDF.Property)
            Domain(ACP.AccessControl)
            Range(ACP.Policy)
            Label("apply")
            Comment("The apply property connects Access Controls to the Policies they apply to resources.")
        }

        Property("attribute") {
            Type(RDF.Property)
            Domain(ACP.Context)
            Label("attribute")
            Comment("Sub-properties of ACP attribute are used to describe instances of resource access.")
        }

        Property("client") {
            SubPropertyOf(ACP.attribute)
            Label("client")
            Comment("In a Matcher, client attributes define a set of clients, at least one of which MUST match the Context for the Matcher to be satisfied.")
        }

        Property("context") {
            Domain(ACP.AccessGrant)
            Range(ACP.Context)
            Label("context")
            Comment("The context property connects Access Grants to the Contexts in which they're given.")
        }

        Property("creator") {
            SubPropertyOf(ACP.attribute)
            Label("creator")
            Comment("The creator attribute describes creators of requested resources.")
        }

        Property("deny") {
            Type(RDF.Property)
            Domain(ACP.Policy)
            Range(ACP.AccessMode)
            Label("deny")
            Comment("The deny property connects Policies to the Access Modes they deny if satisfied.")
        }

        Property("grant") {
            Domain(ACP.AccessGrant)
            Range(ACP.AccessMode)
            Label("grant")
            Comment("The grant property connects Access Grants to the Access Modes they grant.")
        }

        Property("issuer") {
            SubPropertyOf(ACP.attribute)
            Label("issuer")
            Comment("In a Matcher, issuer attributes define a set of issuers, at least one of which MUST match the Context for the Matcher to be satisfied.")
        }

        Property("memberAccessControl") {
            Type(RDF.Property)
            Domain(ACP.AccessControlResource)
            Range(ACP.AccessControl)
            Label("member access control")
            Comment("The member access control property transitively connects ACRs of member resources to Access Controls.")
        }

        Property("noneOf") {
            Type(RDF.Property)
            Domain(ACP.Policy)
            Range(ACP.Matcher)
            Label("none of")
            Comment("The none of property connects Policies to a set of Matchers, all of which MUST NOT be satisfied for the Policy to be satisfied.")
        }

        Property("owner") {
            SubPropertyOf(ACP.attribute)
            Label("owner")
            Comment("The owner attribute describes owners of requested resources.")
        }

        Property("resource") {
            Type(RDF.Property)
            Domain(ACP.AccessControlResource)
            Label("resource")
            Comment("The resource property connects ACRs to resources they control. It is the inverse of acp:accessControlResource.")
        }

        Property("target") {
            SubPropertyOf(ACP.attribute)
            Label("target")
            Comment("The target attribute describes requested resources.")
        }

        Property("vc") {
            SubPropertyOf(ACP.attribute)
            Label("vc")
            Comment("In a Matcher, vc attributes define a set of types of Verifiable Credentials (VC), at least one of which MUST match the Context for the Matcher to be satisfied. A VC type present in the Context MUST be a valid VC presented as part of the resource access request.")
        }

        Individual("AuthenticatedAgent") {
            Type(OWL.NamedIndividual)
            Label("Authenticated Agent")
            Comment("In a Matcher, agent attributes using the Authenticated Agent named individual MUST match Contexts that contain an agent.")
        }

        Individual("AuthenticatedClient") {
            Type(OWL.NamedIndividual)
            Label("Authenticated Client")
            Comment("In a Matcher, client attributes using the Authenticated Client named individual MUST match Contexts that contain a client.")
        }

        Individual("AuthenticatedIssuer") {
            Type(OWL.NamedIndividual)
            Label("Authenticated Issuer")
            Comment("In a Matcher, issuer attributes using the Authenticated Issuer named individual MUST match Contexts that contain an issuer.")
        }

        Individual("CreatorAgent") {
            Type(OWL.NamedIndividual)
            Label("Creator Agent")
            Comment("In a Matcher, agent attributes using the Creator Agent named individual MUST match Contexts where a defined creator matches the defined agent.")
        }

        Individual("OwnerAgent") {
            Type(OWL.NamedIndividual)
            Label("Owner Agent")
            Comment("In a Matcher, agent attributes using the Owner Agent named individual MUST match Contexts where a defined owner matches the defined agent.")
        }

        Individual("PublicAgent") {
            Type(OWL.NamedIndividual)
            Type(ACP.AlwaysSatisfiedRestriction)
            Label("Public Agent")
            Comment("In a Matcher, agent attributes using the Public Agent named individual MUST match all Contexts.")
        }

        Individual("PublicClient") {
            Type(OWL.NamedIndividual)
            Type(ACP.AlwaysSatisfiedRestriction)
            Label("Public Client")
            Comment("In a Matcher, client attributes using the Public Client named individual MUST match all Contexts.")
        }

        Individual("PublicIssuer") {
            Type(OWL.NamedIndividual)
            Type(ACP.AlwaysSatisfiedRestriction)
            Label("Public Issuer")
            Comment("In a Matcher, issuer attributes using the Public Issuer named individual MUST match all Contexts.")
        }
    }
}
