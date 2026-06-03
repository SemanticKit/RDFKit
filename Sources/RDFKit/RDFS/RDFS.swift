import Foundation

/// The RDF Schema vocabulary namespace.
public enum RDFS {
    /// The RDFS namespace IRI.
    public static let namespace = Namespace("http://www.w3.org/2000/01/rdf-schema#")

    /// rdfs:subClassOf.
    public static var subClassOf: SubClassOf { SubClassOf() }

    /// rdfs:subPropertyOf.
    public static var subPropertyOf: SubPropertyOf { SubPropertyOf() }

    /// rdfs:comment.
    public static var comment: Comment { Comment() }

    /// rdfs:label.
    public static var label: Label { Label() }

    /// rdfs:domain.
    public static var domain: Domain { Domain() }

    /// rdfs:range.
    public static var range: Range { Range() }

    /// rdfs:seeAlso.
    public static var seeAlso: SeeAlso { SeeAlso() }

    /// rdfs:isDefinedBy.
    public static var isDefinedBy: IsDefinedBy { IsDefinedBy() }

    /// rdfs:member.
    public static var member: Member { Member() }
}

public extension RDFS {
    /// rdfs:subClassOf.
    struct SubClassOf: RDFKit.Property, VocabularyTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        public static let namespace = RDFS.namespace
        public static let localName = LocalName("subClassOf")
        public static let domains = [RDFS.Class.iri]
        public static let ranges = [RDFS.Class.iri]
        public init() {}
    }

    /// rdfs:subPropertyOf.
    struct SubPropertyOf: RDFKit.Property, VocabularyTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        public static let namespace = RDFS.namespace
        public static let localName = LocalName("subPropertyOf")
        public static let domains = [RDF.Property.iri]
        public static let ranges = [RDF.Property.iri]
        public init() {}
    }

    /// rdfs:comment.
    struct Comment: RDFKit.Property, VocabularyTerm, AnnotationProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        public static let namespace = RDFS.namespace
        public static let localName = LocalName("comment")
        public static let domains = [RDFS.Resource.iri]
        public static let ranges = [RDFS.Literal.iri]
        public init() {}
    }

    /// rdfs:label.
    struct Label: RDFKit.Property, VocabularyTerm, AnnotationProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        public static let namespace = RDFS.namespace
        public static let localName = LocalName("label")
        public static let domains = [RDFS.Resource.iri]
        public static let ranges = [RDFS.Literal.iri]
        public init() {}
    }

    /// rdfs:domain.
    struct Domain: RDFKit.Property, VocabularyTerm, DomainConstrainedProperty, RangeConstrainedProperty {
        public static let namespace = RDFS.namespace
        public static let localName = LocalName("domain")
        public static let domains = [RDF.Property.iri]
        public static let ranges = [RDFS.Class.iri]
        public init() {}
    }

    /// rdfs:range.
    struct Range: RDFKit.Property, VocabularyTerm, DomainConstrainedProperty, RangeConstrainedProperty {
        public static let namespace = RDFS.namespace
        public static let localName = LocalName("range")
        public static let domains = [RDF.Property.iri]
        public static let ranges = [RDFS.Class.iri]
        public init() {}
    }

    /// rdfs:seeAlso.
    struct SeeAlso: RDFKit.Property, VocabularyTerm, AnnotationProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        public static let namespace = RDFS.namespace
        public static let localName = LocalName("seeAlso")
        public static let domains = [RDFS.Resource.iri]
        public static let ranges = [RDFS.Resource.iri]
        public init() {}
    }

    /// rdfs:isDefinedBy.
    struct IsDefinedBy: RDFKit.Property, VocabularyTerm, AnnotationProperty, DomainConstrainedProperty, RangeConstrainedProperty, SubpropertyAwareProperty {
        public static let namespace = RDFS.namespace
        public static let localName = LocalName("isDefinedBy")
        public static let domains = [RDFS.Resource.iri]
        public static let ranges = [RDFS.Resource.iri]
        public static let superproperties = [RDFS.SeeAlso.iri]
        public init() {}
    }

    /// rdfs:member.
    struct Member: RDFKit.Property, VocabularyTerm, RelationshipProperty, DomainConstrainedProperty, RangeConstrainedProperty {
        public static let namespace = RDFS.namespace
        public static let localName = LocalName("member")
        public static let domains = [RDFS.Resource.iri]
        public static let ranges = [RDFS.Resource.iri]
        public init() {}
    }

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
