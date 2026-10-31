//
//  ParsedEntity.swift
//  RDFKit
//
//  Created by Charles Gardner on 6/20/26.
//

/// Parsed entity data.
public struct ParsedEntity {
    public let name: String
    public let kind: String
    public let annotations: [ParsedAnnotation]

    public init(name: String, kind: String, annotations: [ParsedAnnotation]) {
        self.name = name
        self.kind = kind
        self.annotations = annotations
    }

    public func annotationValue(named name: String) -> String {
        annotations.first { $0.name == name }?.value ?? ""
    }
}
