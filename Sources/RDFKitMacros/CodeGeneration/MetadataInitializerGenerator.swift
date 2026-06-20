import Foundation

struct MetadataInitializerGenerator {
    static func generate(properties: [MetadataProperty]) -> String {
        let assignments = properties.map { prop in
            "                \(prop.name): \(prop.value)"
        }.joined(separator: ",\n")

        return """
            public static let metadata = Metadata(
        \(assignments)
            )
        """
    }
}
