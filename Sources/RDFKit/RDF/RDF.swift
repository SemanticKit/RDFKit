import Foundation
import RDFCore
import IRIKit

/// The RDF ontology.
@Ontology
public struct RDF: Ontology {
    typealias `Class` = RDFS.Class
    typealias Label = RDFS.Label
    typealias Individual = RDFS.Individual
    typealias SubClassOf = RDFS.SubClassOf
    typealias SeeAlso = RDFS.SeeAlso

    public var content: Content {
        Prefix.rdf
        Prefix.rdfs
        Prefix.owl
        Prefix.dc

        Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#")

        Class("Alt") {
            Type(Class)
            SubClassOf(RDFS.Container)
            Label("Alt")
            Comment("The class of containers of alternatives.")
        }
        Class("Bag") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Container)
            Label("Bag")
            Comment("The class of unordered containers.")
        }
        Class("CompoundLiteral") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Resource)
            SeeAlso(
                "https://www.w3.org/TR/json-ld11/#the-rdf-compoundliteral-class-and-the-rdf-language-and-rdf-direction-properties"
            )
            Label("CompoundLiteral")
            Comment("A class representing a compound literal.")
        }
        Datatype("HTML") {
            Type(RDFS.Datatype)
            SubClassOf(RDFS.Literal)
            SeeAlso("http://www.w3.org/TR/rdf11-concepts/#section-html")
            Label("HTML")
            Comment(
                "The datatype of RDF literals storing fragments of HTML content"
            )
        }
        Datatype("JSON") {
            Type(RDFS.Datatype)
            SubClassOf(RDFS.Literal)
            SeeAlso("https://www.w3.org/TR/rdf-concepts/#section-json")
            Label("JSON")
            Comment("The datatype of RDF literals storing JSON content.")
        }
        Datatype("dirLangString") {
            Type(RDFS.Datatype)
            SubClassOf(RDFS.Literal)
            Label("dirLangString")
            Comment(
                "The datatype of directional language-tagged string values, which includes a language tag and a base direction (either 'ltr' or 'rtl')"
            )
        }
        Datatype("langString") {
            Type(RDFS.Datatype)
            SubClassOf(RDFS.Literal)
            SeeAlso(
                "http://www.w3.org/TR/rdf11-concepts/#section-Graph-Literal"
            )
            Label("langString")
            Comment("The datatype of language-tagged string values")
        }
        Class("List") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Resource)
            Label("List")
            Comment("The class of RDF Lists.")
        }
        Individual("nil") {
            Type(RDF.List)
            Label("nil")
            Comment(
                "The empty list, with no items in it. If the rest of a list is nil then the list has no more items in it."
            )
        }

        Datatype("PlainLiteral") {
            Type(RDFS.Datatype)
            SubClassOf(RDFS.Literal)
            SeeAlso("http://www.w3.org/TR/rdf-plain-literal/")
            Label("PlainLiteral")
            Comment(
                "The class of plain (i.e., untyped) literal values, as used in RIF and OWL 2.  Will not be removed until no longer needed there."
            )
            OWLDeprecated()
        }
        Class("Property") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Resource)
            Label("Property")
            Comment("The class of RDF properties.")
        }
        Class("PropositionForm") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Resource)
            SeeAlso("https://www.w3.org/TR/rdf12-interop/")
            Label("PropositionForm")
            Comment(
                "The class of abstract, atomic proposition forms. Reserved for basic encoding of propositions."
            )
        }
        Class("Seq") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Container)
            Label("Seq")
            Comment("The class of ordered containers.")
        }
        Class("Statement") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Resource)
            Label("Statement")
            Comment("The class of RDF statements.")
        }
        Property("direction") {
            Type(RDF.Property)
            Domain(RDF.CompoundLiteral)
            SeeAlso(
                "https://www.w3.org/TR/json-ld11/#the-rdf-compoundliteral-class-and-the-rdf-language-and-rdf-direction-properties"
            )
            Label("direction")
            Comment("The base direction component of a CompoundLiteral.")
        }
        Property("first") {
            Type(RDF.Property)
            Domain(RDF.List)
            Range(RDFS.Resource)
            Label("first")
            Comment("The first item in the subject RDF list.")
        }
        Property("language") {
            Type(RDF.Property)
            Domain(RDF.CompoundLiteral)
            SeeAlso(
                "https://www.w3.org/TR/json-ld11/#the-rdf-compoundliteral-class-and-the-rdf-language-and-rdf-direction-properties"
            )
            Label("language")
            Comment("The language component of a CompoundLiteral.")
        }
        Property("object") {
            Type(RDF.Property)
            Domain(RDF.Statement)
            Range(RDFS.Resource)
            Label("object")
            Comment("The object of the subject RDF statement.")
        }
        Property("predicate") {
            Type(RDF.Property)
            Domain(RDF.Statement)
            Range(RDFS.Resource)
            Label("predicate")
            Comment("The predicate of the subject RDF statement.")
        }
        Property("propositionFormObject") {
            Type(RDF.Property)
            Domain(RDF.PropositionForm)
            Range(RDFS.Resource)
            SeeAlso("https://www.w3.org/TR/rdf12-interop/")
            Label("propositionFormObject")
            Comment(
                "The object component of a proposition form. Reserved for basic encoding of propositions."
            )
        }
        Property("propositionFormPredicate") {
            Type(RDF.Property)
            Domain(RDF.PropositionForm)
            Range(RDF.Property)
            SeeAlso("https://www.w3.org/TR/rdf12-interop/")
            Label("propositionFormPredicate")
            Comment(
                "The predicate component of a proposition form. Reserved for basic encoding of propositions."
            )
        }
        Property("propositionFormSubject") {
            Type(RDF.Property)
            Domain(RDF.PropositionForm)
            Range(RDFS.Resource)
            SeeAlso("https://www.w3.org/TR/rdf12-interop/")
            Label("propositionFormSubject")
            Comment(
                "The subject component of a proposition form. Reserved for basic encoding of propositions."
            )
        }
        Property("reifies") {
            Type(RDF.Property)
            Domain(RDFS.Resource)
            Range(RDFS.Proposition)
            Label("reifies")
            Comment("The abstract proposition of a more concrete circumstance.")
        }
        Property("rest") {
            Type(RDF.Property)
            Domain(RDF.List)
            Range(RDF.List)
            Label("rest")
            Comment("The rest of the subject RDF list after the first item.")
        }
        Property("subject") {
            Type(RDF.Property)
            Domain(RDF.Statement)
            Range(RDFS.Resource)
            Label("subject")
            Comment("The subject of the subject RDF statement.")
        }
        Property("type") {
            Type(RDF.Property)
            Domain(RDFS.Resource)
            Range(RDFS.Class)
            Label("type")
            Comment("The subject is an instance of a class.")
        }
        Property("value") {
            Type(RDF.Property)
            Domain(RDFS.Resource)
            Range(RDFS.Resource)
            Label("value")
            Comment("Idiomatic property used for structured values.")
        }
        Datatype("XMLLiteral") {
            Type(RDFS.Datatype)
            SubClassOf(RDFS.Literal)
            Label("XMLLiteral")
            Comment("The datatype of XML literal values.")
        }
        Individual("version-1.0") {
            Type(RDFS.Resource)
            Label("1.0")
            Comment("Version 1.0")
        }
        Individual("version-1.1") {
            Type(RDFS.Resource)
            Label("1.1")
            Comment("Version 1.1")
        }
        Individual("version-1.2") {
            Type(RDFS.Resource)
            Label("1.2")
            Comment("Version 1.2.")
        }
        Individual("version-1.2-basic") {
            Type(RDFS.Resource)
            Label("1.2-basic")
            Comment("Version 1.2-basic")
        }
    }
}

extension RDF {
    struct Property: Entity {
        public typealias ID = IRI
        public typealias Metadata = RDFMetadata

        public static let metadata = RDFMetadata(
            id: "http://www.w3.org/2000/01/rdf-schema#Resource",
            name: "Resource",
            type: "RDFS.Class",
            label: "Resource",
            comment: "The class resource, everything."
        )

        public let id: ID
        public let name: String
        public let type: String
        public let label: String
        public let comment: String

        public init(
            id: ID,
            name: String,
            type: String,
            label: String,
            comment: String
        ) {
            self.id = id
            self.name = name
            self.type = type
            self.label = label
            self.comment = comment
        }

        public static func callAsFunction(
            _ name: String,
            @ContentBuilder _ children: () -> Content
        ) -> any ContentMetadata {
            RDFMetadata(
                id: IRI(rawValue: "\(Self.metadata.type)\(name)") ?? "",
                name: name,
                type: Self.metadata.type,
                label: name,
                comment: ""
            )
        }
    }

    public struct `Type`: Entity {
        public typealias ID = IRI
        public typealias Metadata = RDFMetadata

        public static let metadata = Metadata(
            id: "http://www.w3.org/2000/01/rdf-schema#Type",
            name: "Type",
            type: "RDFS.Class",
            label: "Type",
            comment: "The subject is an instance of a class."
        )

        public var id: ID


        public static func callAsFunction(
            _ name: String,
            @ContentBuilder _ children: () -> Content
        ) -> any ContentMetadata {
            RDFMetadata(
                id: IRI(rawValue: "\(Self.metadata.type)\(name)") ?? "",
                name: name,
                type: Self.metadata.type,
                label: name,
                comment: ""
            )
        }
    }
}
