//
//  RDFMetadata.swift
//  RDFKit
//
//  Created by Charles Gardner on 6/20/26.
//
import IRIKit

public struct RDFMetadata: ContentMetadata {
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

    public init(id: IRI, name: String, type: IRI, label: String, comment: String) {
        self.id = id
        self.name = name
        self.type = type
        self.label = label
        self.comment = comment
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(IRI.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.type = try container.decode(IRI.self, forKey: .type)
        self.label = try container.decode(String.self, forKey: .label)
        self.comment = try container.decode(String.self, forKey: .comment)
    }
}
