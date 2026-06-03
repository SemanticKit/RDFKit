import Foundation

private protocol ResolvedAliasBinding {
    var resolvedPrefix: String { get }
    func resolvedNamespace() throws -> Namespace
}

extension Alias: ResolvedAliasBinding {
    fileprivate var resolvedPrefix: String { prefix }

    fileprivate func resolvedNamespace() throws -> Namespace {
        try target.aliasNamespace()
    }
}

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
        var map: [String: IRI] = [:]
        try collectAliasContent(self, into: &map)
        return map
    }
}

private func collectAliasContent(_ content: any AliasContent, into map: inout [String: IRI]) throws {
    if content is EmptyAliasContent {
        return
    }
    if let group = content as? AliasGroup {
        for element in group.elements {
            try collectAliasContent(element, into: &map)
        }
        return
    }
    guard let binding = content as? any ResolvedAliasBinding else {
        throw AliasResolutionError.unsupportedAliasContent(String(describing: type(of: content)))
    }
    let prefix = binding.resolvedPrefix
    if map[prefix] != nil {
        throw AliasResolutionError.duplicatePrefix(prefix)
    }
    map[prefix] = try binding.resolvedNamespace().iri
}
