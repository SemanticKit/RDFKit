//
//  Class.swift
//  RDFKit
//
//  Created by Charles Gardner on 6/20/26.
//
import IRIKit

public struct Class: Entity, Sendable {
    public typealias ID = IRI

    public static let metadata = RDFMetadata(
        id: "http://www.w3.org/2000/01/rdf-schema#Class",
        name: "Class",
        type: "RDFS.Class",
        label: "Class",
        comment: "The class of classes."
    )

    // Instance properties from Property declarations whose Domain matches
    public var id: IRI
    public var name: String
    public let type: IRI          // from Property("type") Domain(RDFS.Resource) Range(RDFS.Class)
    public let label: String?     // from Property("label") Domain(RDFS.Resource) Range(RDFS.Literal)
    public let comment: String?   // from Property("comment") Domain(RDFS.Resource) Range(RDFS.Literal)

    public init(id: IRI, name: String, type: IRI, label: String?, comment: String?) {
        self.id = id
        self.name = name
        self.type = type
        self.label = label
        self.comment = comment
    }

    // MARK: DSL Support
    public static func callAsFunction(
        _ name: String,
        @ContentBuilder _ children: () -> Content
    ) -> Metadata {
        RDFMetadata(
            id: IRI(rawValue: "\(Self.metadata.type)\(name)") ?? "",
            name: name,
            type: Self.metadata.type,
            label: name,
            comment: ""
        )
    }
}
