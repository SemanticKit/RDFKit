//
//  InstancePropertyGenerator.swift
//  RDFKit
//
//  Created by Charles Gardner on 6/20/26.
//

import Foundation

struct InstancePropertyGenerator {
    static func generateStoredProperties(properties: [ParsedEntity]) -> String {
        guard !properties.isEmpty else { return "" }
        return properties.map { prop in
            let range = prop.annotationValue(named: "Range")
            let typeName = resolveType(from: range)
            return "    public let \(prop.name): \(typeName)"
        }.joined(separator: "\n")
    }

    static func generateInitializer(properties: [ParsedEntity]) -> String {
        guard !properties.isEmpty else { return "" }
        let parameters = properties.map { prop -> String in
            let range = prop.annotationValue(named: "Range")
            let typeName = resolveType(from: range)
            return "\(prop.name): \(typeName)"
        }.joined(separator: ", ")

        let assignments = properties.map { prop in
            "            self.\(prop.name) = \(prop.name)"
        }.joined(separator: "\n")

        return """
            public init(id: IRI, \(parameters)) {
                self.id = id
        \(assignments)
            }
        """
    }

    private static func resolveType(from range: String) -> String {
        switch range {
        case "RDFS.Literal": return "String"
        case "RDFS.Class", "RDFS.Resource": return "IRI"
        default: return "IRI"
        }
    }
}
