//
//  ParsedAnnotation.swift
//  RDFKit
//
//  Created by Charles Gardner on 6/20/26.
//

/// Parsed annotation data.
public struct ParsedAnnotation {
    public let name: String
    public let value: String

    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}
