import Foundation

enum AliasResolutionError: Error, CustomStringConvertible {
    case unsupportedAliasContent(String)
    case duplicatePrefix(String)

    var description: String {
        switch self {
        case let .unsupportedAliasContent(type):
            return "Unsupported alias content \(type)."
        case let .duplicatePrefix(prefix):
            return "Duplicate alias prefix \(prefix)."
        }
    }
}

extension AliasContent {
    func iriPrefixMap() throws -> [String: IRI] {
        guard let mappingContent = self as? any AliasMappingContent else {
            throw AliasResolutionError.unsupportedAliasContent(String(describing: type(of: self)))
        }

        var map: [String: IRI] = [:]
        try mappingContent.addIRIPrefixes(to: &map)
        return map
    }
}
