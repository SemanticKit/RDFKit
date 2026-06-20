import Foundation

struct StoredPropertyGenerator {
    static func generate(properties: [MetadataProperty]) -> String {
        properties.map { prop in
            "            public let \(prop.name): \(prop.typeName)"
        }.joined(separator: "\n")
    }
}
