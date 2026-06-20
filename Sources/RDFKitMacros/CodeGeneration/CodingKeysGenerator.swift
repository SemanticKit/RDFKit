import Foundation

struct CodingKeysGenerator {
    static func generate(properties: [MetadataProperty]) -> String {
        properties.map { prop in
            "            case \(prop.name) = \"\(prop.name)\""
        }.joined(separator: "\n")
    }
}
