//
//  ParsedEntity.swift
//  RDFKit
//
//  Created by Charles Gardner on 6/20/26.
//

/// Parsed entity data.
struct ParsedEntity {
    let name: String
    let kind: String
    let annotations: [ParsedAnnotation]

    func annotationValue(named name: String) -> String {
        annotations.first { $0.name == name }?.value ?? ""
    }
}
