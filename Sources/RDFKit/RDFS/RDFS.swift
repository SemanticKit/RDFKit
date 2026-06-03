import Foundation

/// The RDF Schema vocabulary namespace.
public enum RDFS {
    /// The RDFS namespace IRI.
    public static let namespace = Namespace("http://www.w3.org/2000/01/rdf-schema#")

    /// rdfs:subClassOf.
    public static let subClassOf = StandardTerm(namespace: namespace, localName: "subClassOf")

    /// rdfs:subPropertyOf.
    public static let subPropertyOf = StandardTerm(namespace: namespace, localName: "subPropertyOf")

    /// rdfs:comment.
    public static let comment = StandardTerm(namespace: namespace, localName: "comment")

    /// rdfs:label.
    public static let label = StandardTerm(namespace: namespace, localName: "label")

    /// rdfs:domain.
    public static let domain = StandardTerm(namespace: namespace, localName: "domain")

    /// rdfs:range.
    public static let range = StandardTerm(namespace: namespace, localName: "range")

    /// rdfs:seeAlso.
    public static let seeAlso = StandardTerm(namespace: namespace, localName: "seeAlso")

    /// rdfs:isDefinedBy.
    public static let isDefinedBy = StandardTerm(namespace: namespace, localName: "isDefinedBy")

    /// rdfs:member.
    public static let member = StandardTerm(namespace: namespace, localName: "member")
}

public extension RDFS {
    /// rdfs:Class.
    struct Class: RDFKit.Class, VocabularyTerm {
        public static let namespace = RDFS.namespace
        public static let localName = LocalName("Class")
        public init() {}
    }

    /// rdfs:Container.
    struct Container: RDFKit.Class, VocabularyTerm {
        public static let namespace = RDFS.namespace
        public static let localName = LocalName("Container")
        public init() {}
    }

    /// rdfs:ContainerMembershipProperty.
    struct ContainerMembershipProperty: RDFKit.Class, VocabularyTerm {
        public static let namespace = RDFS.namespace
        public static let localName = LocalName("ContainerMembershipProperty")
        public init() {}
    }

    /// rdfs:Datatype.
    struct Datatype: RDFKit.Class, VocabularyTerm {
        public static let namespace = RDFS.namespace
        public static let localName = LocalName("Datatype")
        public init() {}
    }

    /// rdfs:Literal.
    struct Literal: RDFKit.Class, VocabularyTerm {
        public static let namespace = RDFS.namespace
        public static let localName = LocalName("Literal")
        public init() {}
    }

    /// rdfs:Resource.
    struct Resource: RDFKit.Class, VocabularyTerm {
        public static let namespace = RDFS.namespace
        public static let localName = LocalName("Resource")
        public init() {}
    }
}
