//
//  GeneratedStruct.swift
//  RDFKit
//
//  Created by Charles Gardner on 6/19/26.
//

public struct Class: Entity, Sendable {
    public typealias ID = IRI

    public struct Metadata: ContentMetadata {
        public typealias ID = IRI

        public enum CodingKeys: String, CodingKey, CaseIterable {
            case id = "id"
            case name = "name"
            case type = "type"
            case label = "label"
            case comment = "comment"
        }
        public let id: IRI
        public let name: String
        public let type: IRI
        public let label: String
        public let comment: String
    }

    public static let metadata = Metadata(
        id: "http://www.w3.org/2000/01/rdf-schema#Class",
        name: "Class",
        type: "RDFS.Class",
        label: "Class",
        comment: "The class of classes."
    )

    public var id: ID

//    PLEASE DO NOT DO THIS, LOOK AT WHAT THE GENERATED CODE
//    IS ACTUALLY DOING IN THE STATEMENT BELOW.
//    IF THE GENERATED TYPE IS AN RDF THING IT MAKES SENSE MAYBE
//    IF ITS SOMETHING BEING AUTHORED IN OUR DSL THEN THE GENERATED
//    THING IS SOMETHING SOMEONE IS USING AS AN ACTUAL TYPE
//    NOT USED IN OUR DSL
//    init(id: ID) {
//        self.id = Self.metadata.id
//    }

    public static func callAsFunction(
        _ name: String,
        @ContentBuilder _ children: () -> [any Node]
    ) -> Metadata {
        Metadata(
            id: "\(Self.metadata.type)\(name)",
            name: name,
            type: Self.metadata.type,
            label: name,
            comment: ""
        )
    }
}
