//
//  InitializerGenerator.swift
//  RDFKit
//
//  Created by Charles Gardner on 6/20/26.
//

import Foundation

struct InitializerGenerator {
    static func generate(properties: [MetadataProperty]) -> String {
        let parameters = properties.map { prop in
            "\(prop.name): \(prop.typeName)"
        }.joined(separator: ", ")

        let assignments = properties.map { prop in
            "            self.\(prop.name) = \(prop.name)"
        }.joined(separator: "\n")

        return """
            public init(\(parameters)) {
        \(assignments)
            }
        """
    }
}
