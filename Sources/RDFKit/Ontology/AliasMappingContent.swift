import Foundation

/// DSL content that contributes IRI prefix mappings.
protocol AliasMappingContent: Content {
    /// Adds this content's aliases to the IRI prefix map.
    func addIRIPrefixes(to map: inout [String: IRI]) throws
}

extension ContentGroup: AliasMappingContent {
    /// Adds aliases contributed by grouped content.
    func addIRIPrefixes(to map: inout [String: IRI]) throws {
        for element in elements {
            if let mappingContent = element as? any AliasMappingContent {
                try mappingContent.addIRIPrefixes(to: &map)
            } else if element is any AliasContent {
                throw AliasResolutionError.unsupportedAliasContent(String(describing: type(of: element)))
            }
        }
    }
}
