import RDFCore
import RDFKit

/// The W3C Linked Data Platform (LDP) vocabulary.
///
/// Namespace `http://www.w3.org/ns/ldp#`, declared from its namespace document (http://www.w3.org/ns/ldp).
///
/// Classes, properties and individuals are declared as the published
/// vocabulary declares them: their types (including `owl:FunctionalProperty`
/// and `owl:InverseFunctionalProperty`), superclasses, superproperties,
/// domains, ranges, labels and comments. `owl:inverseOf`, `owl:equivalentClass`,
/// `owl:equivalentProperty` and `owl:disjointWith` statements are not, because
/// the DSL has no annotation for them yet.
///
/// The published vocabulary types its individuals `owl:Individual` and gives
/// `ldp:pageSortOrder` the range `rdf:Resource`. Neither term is defined by OWL
/// or RDF, but both are used as classes, so RDFKit declares them as plain
/// `rdfs:Class`es in their own namespaces' ontologies, `OWL.Individual` and
/// `RDF.Resource`, and LDP uses them exactly as published. A value of
/// `ldp:pageSortOrder` is `any RDF.Resource`.
@Ontology
public struct LDP: Ontology {
    public init() {}

    public func content() -> Content {
        Namespace("http://www.w3.org/ns/ldp#")

        Class("BasicContainer") {
            Type(RDFS.Class)
            SubClassOf(LDP.Container)
            Label("BasicContainer")
            Comment("An LDPC that uses a predefined predicate to simply link to its contained resources.")
        }

        Class("Container") {
            Type(RDFS.Class)
            SubClassOf(LDP.RDFSource)
            Label("Container")
            Comment("A Linked Data Platform RDF Source (LDP-RS) that also conforms to additional patterns and conventions for managing membership. Readers should refer to the specification defining this ontology for the list of behaviors associated with it.")
        }

        Class("DirectContainer") {
            Type(RDFS.Class)
            SubClassOf(LDP.Container)
            Label("DirectContainer")
            Comment("An LDPC that is similar to a LDP-DC but it allows an indirection with the ability to list as member a resource, such as a URI representing a real-world object, that is different from the resource that is created.")
        }

        Class("IndirectContainer") {
            Type(RDFS.Class)
            SubClassOf(LDP.Container)
            Label("IndirectContainer")
            Comment("An LDPC that has the flexibility of choosing what form the membership triples take.")
        }

        Class("NonRDFSource") {
            Type(RDFS.Class)
            SubClassOf(LDP.Resource)
            Label("NonRDFSource")
            Comment("A Linked Data Platform Resource (LDPR) whose state is NOT represented as RDF.")
        }

        Class("Page") {
            Type(RDFS.Class)
            Label("Page")
            Comment("URI signifying that the resource is an in-sequence page resource, as defined by LDP Paging. Typically used on Link rel='type' response headers.")
        }

        Class("PageSortCriterion") {
            Type(RDFS.Class)
            Label("PageSortCriterion")
            Comment("Element in the list of sorting criteria used by the server to assign container members to pages.")
        }

        Class("RDFSource") {
            Type(RDFS.Class)
            SubClassOf(LDP.Resource)
            Label("RDFSource")
            Comment("A Linked Data Platform Resource (LDPR) whose state is represented as RDF.")
        }

        Class("Resource") {
            Type(RDFS.Class)
            Label("Resource")
            Comment("A HTTP-addressable resource whose lifecycle is managed by a LDP server.")
        }

        Property("constrainedBy") {
            Type(RDF.Property)
            Domain(LDP.Resource)
            Range(RDFS.Resource)
            Label("constrainedBy")
            Comment("Links a resource with constraints that the server requires requests like creation and update to conform to.")
        }

        Property("contains") {
            Type(RDF.Property)
            Domain(LDP.Container)
            Range(RDFS.Resource)
            Label("contains")
            Comment("Links a container with resources created through the container.")
        }

        Property("hasMemberRelation") {
            Type(RDF.Property)
            Domain(LDP.Container)
            Range(RDF.Property)
            Label("hasMemberRelation")
            Comment("Indicates which predicate is used in membership triples, and that the membership triple pattern is < membership-constant-URI , object-of-hasMemberRelation, member-URI >.")
        }

        Property("inbox") {
            Type(RDF.Property)
            Label("inbox")
            Comment("Links a resource to a container where notifications for the resource can be created and discovered.")
        }

        Property("insertedContentRelation") {
            Type(RDF.Property)
            Domain(LDP.Container)
            Range(RDF.Property)
            Label("insertedContentRelation")
            Comment("Indicates which triple in a creation request should be used as the member-URI value in the membership triple added when the creation request is successful.")
        }

        Property("isMemberOfRelation") {
            Type(RDF.Property)
            Domain(LDP.Container)
            Range(RDF.Property)
            Label("isMemmberOfRelation")
            Comment("Indicates which predicate is used in membership triples, and that the membership triple pattern is < member-URI , object-of-isMemberOfRelation, membership-constant-URI >.")
        }

        Property("member") {
            Type(RDF.Property)
            Domain(LDP.Resource)
            Range(RDFS.Resource)
            Label("member")
            Comment("LDP servers should use this predicate as the membership predicate if there is no obvious predicate from an application vocabulary to use.")
        }

        Property("membershipResource") {
            Type(RDF.Property)
            Domain(LDP.Container)
            Range(RDFS.Resource)
            Label("membershipResource")
            Comment("Indicates the membership-constant-URI in a membership triple. Depending upon the membership triple pattern a container uses, as indicated by the presence of ldp:hasMemberRelation or ldp:isMemberOfRelation, the membership-constant-URI might occupy either the subject or object position in membership triples.")
        }

        Property("pageSequence") {
            Type(RDF.Property)
            Label("Page")
            Comment("Link to a page sequence resource, as defined by LDP Paging. Typically used to communicate the sorting criteria used to allocate LDPC members to pages.")
        }

        Property("pageSortCollation") {
            Type(RDF.Property)
            Domain(LDP.PageSortCriterion)
            Range(RDF.Property)
            Label("pageSortCollation")
            Comment("The collation used to order the members across pages in a page sequence when comparing strings.")
        }

        Property("pageSortCriteria") {
            Type(RDF.Property)
            Domain(LDP.Page)
            Range(RDF.List)
            Label("pageSortCriteria")
            Comment("Link to the list of sorting criteria used by the server in a representation. Typically used on Link response headers as an extension link relation URI in the rel= parameter.")
        }

        Property("pageSortOrder") {
            Type(RDF.Property)
            Domain(LDP.PageSortCriterion)
            Range(RDF.Resource)
            Label("pageSortOrder")
            Comment("The ascending/descending/etc order used to order the members across pages in a page sequence.")
        }

        Property("pageSortPredicate") {
            Type(RDF.Property)
            Domain(LDP.PageSortCriterion)
            Range(RDF.Property)
            Label("pageSortPredicate")
            Comment("Predicate used to specify the order of the members across a page sequence's in-sequence page resources; it asserts nothing about the order of members in the representation of a single page.")
        }

        Individual("Ascending") {
            Type(OWL.Individual)
            Label("Ascending")
            Comment("Ascending order.")
        }

        Individual("Descending") {
            Type(OWL.Individual)
            Label("Descending")
            Comment("Descending order.")
        }

        Individual("MemberSubject") {
            Type(OWL.Individual)
            Label("MemberSubject")
            Comment("Used to indicate default and typical behavior for ldp:insertedContentRelation, where the member-URI value in the membership triple added when a creation request is successful is the URI assigned to the newly created resource.")
        }

        Individual("PreferContainment") {
            Type(OWL.Individual)
            Label("PreferContainment")
            Comment("URI identifying a LDPC's containment triples, for example to allow clients to express interest in receiving them.")
        }

        Individual("PreferEmptyContainer") {
            Type(OWL.Individual)
            Label("PreferEmptyContainer")
            Comment("Archaic alias for ldp:PreferMinimalContainer")
        }

        Individual("PreferMembership") {
            Type(OWL.Individual)
            Label("PreferMembership")
            Comment("URI identifying a LDPC's membership triples, for example to allow clients to express interest in receiving them.")
        }

        Individual("PreferMinimalContainer") {
            Type(OWL.Individual)
            Label("PreferMinimalContainer")
            Comment("URI identifying the subset of a LDPC's triples present in an empty LDPC, for example to allow clients to express interest in receiving them. Currently this excludes containment and membership triples, but in the future other exclusions might be added. This definition is written to automatically exclude those new classes of triples.")
        }
    }
}
