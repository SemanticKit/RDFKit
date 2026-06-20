import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

struct MetadataGenerator {
    static func generate(properties: [MetadataProperty]) -> String {
        let codingCases = CodingKeysGenerator.generate(properties: properties)
        let storedProps = StoredPropertyGenerator.generate(properties: properties)

        return """
            public struct Metadata: ContentMetadata {
                public typealias ID = IRI

                public enum CodingKeys: String, CodingKey, CaseIterable {
        \(codingCases)
        }
        \(storedProps)
            }
        """
    }
}
