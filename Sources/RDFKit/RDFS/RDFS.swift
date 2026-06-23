import Foundation
import RDFCore
import IRIKit

/// The RDF Schema ontology.
@Ontology public struct RDFS: Ontology {
    typealias Property = RDF.Property
    public var content: Content {
        Prefix.rdf
        Prefix.rdfs
        Prefix.owl
        Prefix.dc

        Namespace("http://www.w3.org/2000/01/rdf-schema#")

        Class("Class") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Resource)
            Label("Class")
            Comment("The class of classes.")
        }

        Property("subClassOf") {
            Type(RDF.Property)
            Domain(RDFS.Class)
            Range(RDFS.Class)
            Label("subClassOf")
            Comment("The subject is a subclass of a class.")
        }

        Property("subPropertyOf") {
            Type(RDF.Property)
            Domain(RDF.Property)
            Range(RDF.Property)
            Label("subPropertyOf")
            Comment("The subject is a subproperty of a property.")
        }
        Property("comment") {
            Type(RDF.Property)
            Domain(RDFS.Resource)
            Range(RDFS.Literal)
            Label("comment")
            Comment("A description of the subject resource.")
        }
        Property("label") {
            Type(RDF.Property)
            Domain(RDFS.Resource)
            Range(RDFS.Literal)
            Label("label")
            Comment("A human-readable name for the subject.")
        }
        Property("domain") {
            Type(RDF.Property)
            Domain(RDF.Property)
            Range(RDFS.Class)
            Label("domain")
            Comment("A domain of the subject property.")
        }
        Property("range") {
            Type(RDF.Property)
            Domain(RDF.Property)
            Range(RDFS.Class)
            Label("range")
            Comment("A range of the subject property.")
        }
        Property("seeAlso") {
            Type(RDF.Property)
            Domain(RDFS.Resource)
            Range(RDFS.Resource)
            Label("seeAlso")
            Comment("Further information about the subject resource.")
        }
        Property("isDefinedBy") {
            Type(RDF.Property)
            SubPropertyOf(RDFS.seeAlso)
            Domain(RDFS.Resource)
            Range(RDFS.Resource)
            Label("isDefinedBy")
            Comment("The definition of the subject resource.")
        }
        Property("member") {
            Type(RDF.Property)
            Domain(RDFS.Resource)
            Range(RDFS.Resource)
            Label("member")
            Comment("A member of the subject resource.")
        }
    }
}

extension RDFS {

    public struct Class: Entity {
        public typealias ID = IRI
        public typealias Metadata = RDFMetadata

        public static let metadata = RDFMetadata(
            id: "http://www.w3.org/2000/01/rdf-schema#Class",
            name: "Class",
            type: "RDFS.Property",
            label: "Class",
            comment: "The class of classes."
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

    public struct Domain: Entity {
        public typealias ID = IRI
        public typealias Metadata = RDFMetadata

        public static let metadata = RDFMetadata(
            id: "http://www.w3.org/2000/01/rdf-schema#Domain",
            name: "Domain",
            type: "RDFS.Property",
            label: "Domain",
            comment: "A domain of the subject property."
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

    public struct Individual: Entity {
        public typealias ID = IRI
        public typealias Metadata = RDFMetadata

        public static let metadata = RDFMetadata(
            id: "http://www.w3.org/2000/01/rdf-schema#Individual",
            name: "Individual",
            type: "RDFS.Property",
            label: "Individual",
            comment: "The class of classes."
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

    public struct Label: Entity {
        public typealias ID = IRI
        public typealias Metadata = RDFMetadata

        public static let metadata = RDFMetadata(
            id: "http://www.w3.org/2000/01/rdf-schema#Label",
            name: "Label",
            type: "RDFS.Property",
            label: "Label",
            comment: "A human-readable name for the subject."
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

    public struct SeeAlso: Entity {
        public typealias ID = IRI
        public typealias Metadata = RDFMetadata

        public static let metadata = RDFMetadata(
            id: "http://www.w3.org/2000/01/rdf-schema#SeeAlso",
            name: "SeeAlso",
            type: "RDFS.Property",
            label: "SeeAlso",
            comment: "Further information about the subject resource."
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

    public struct SubClassOf: Entity {
        public typealias ID = IRI
        public typealias Metadata = RDFMetadata

        public static let metadata = RDFMetadata(
            id: "http://www.w3.org/2000/01/rdf-schema#subClassOf",
            name: "SubClassOf",
            type: "RDFS.Property",
            label: "subClassOf",
            comment: "The subject is a subclass of a class."
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

    public struct SubPropertyOf: Entity {
        public typealias ID = IRI
        public typealias Metadata = RDFMetadata

        public static let metadata = RDFMetadata(
            id: "http://www.w3.org/2000/01/rdf-schema#subPropertyOf",
            name: "SubPropertyOf",
            type: "RDFS.Property",
            label: "SubPropertyOf",
            comment: "The subject is a subproperty of a property."
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
