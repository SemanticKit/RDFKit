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
}
