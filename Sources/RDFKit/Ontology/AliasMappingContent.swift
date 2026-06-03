import Foundation

/// Alias DSL content that contributes IRI prefix mappings.
protocol AliasMappingContent: AliasContent {
    /// Adds this content's aliases to the IRI prefix map.
    func addIRIPrefixes(to map: inout [String: IRI]) throws
}
