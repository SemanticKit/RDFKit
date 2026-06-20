//
//  Animal.swift
//  RDFKit
//
//  Created by Charles Gardner on 6/20/26.
//
import RDFCore


public struct Animal: Entity, Sendable {
    public typealias ID = IRI

    public static let metadata = RDFMetadata(
        id: "http://example.org/animals#Animal",
        name: "Animal",
        type: "RDFS.Class",
        label: "Animal",
        comment: "A living organism."
    )

    public var id: IRI
    public var name: String
    public let species: String

    public init(id: IRI, name: String, species: String) {
        self.id = id
        self.name = name
        self.species = species
    }

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
